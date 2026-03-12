class MoviesController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]

  PLATFORM_IDS = {
    "Netflix" => 8,
    "DisneyPlus" => 337,
    "AmazonPrime" => 119,
    "CanalPlus" => 381,
    "HBO" => 384
  }.freeze

  PLATFORM_URLS = {
  "Netflix" => "https://www.netflix.com/search?q=",
  "Disney+" => "https://www.disneyplus.com/search?q=",
  "Prime Video" => "https://www.primevideo.com/search/ref=atv_nb_sr?phrase=",
  "Canal+" => "https://www.canalplus.com/recherche/?q=",
  "HBO Max" => "https://www.hbomax.com/search?q="
  }.freeze

  MOVIE_GENRES = {
  "Action" => 28,
  "Animation" => 16,
  "Aventure" => 12,
  "Comédie" => 35,
  "Documentaire" => 99,
  "Drame" => 18,
  "Familial" => 10751,
  "Fantastique" => 14,
  "Guerre" => 10752,
  "Historique" => 36,
  "Horreur" => 27,
  "Musique" => 10402,
  "Mystère" => 9648,
  "Policier" => 80,
  "Romance" => 10749,
  "Science Fiction" => 878,
  "Show télé" => 10770,
  "Thriller" => 53,
  "Western" => 37
}.freeze

TV_GENRES = {
  "Action & Aventure" => 10759,
  "Animation" => 16,
  "Comédie" => 35,
  "Policier" => 80,
  "Documentaire" => 99,
  "Drame" => 18,
  "Familial" => 10751,
  "Enfants" => 10762,
  "Mystère" => 9648,
  "News" => 10763,
  "Reality show" => 10764,
  "Science Fiction & Fantasie" => 10765,
  "Soap" => 10766,
  "Show télé" => 10767,
  "Guerre & Politique" => 10768,
  "Western" => 37
}.freeze

  def index
    type = params[:serie] == "1" ? "tv" : "movie"
    genre_id = tmdb_genre_id(params[:genre], type)
    max_duration      = parse_duration(params[:duration], type)
    user_provider_ids = user_platforms
    without_genres    = excluded_genres(params[:company])
    seen_tmdb_ids     = current_user&.movies&.pluck(:tmdb_id)&.compact || []
    sort_options      = %w[popularity.desc vote_count.desc revenue.desc primary_release_date.desc]

    tmdb_query = {
      language: "fr-FR",
      with_genres: genre_id,
      without_genres: without_genres,
      sort_by: sort_options.sample,
      watch_region: "FR",
      "vote_count.gte" => 20,
      page: rand(1..20)
    }

    if user_provider_ids.present?
      tmdb_query[:with_watch_providers] = user_provider_ids
      tmdb_query[:with_watch_monetization_types] = "flatrate"
    end

    if max_duration
      tmdb_query["with_runtime.lte"] = max_duration
      tmdb_query["with_runtime.gte"] = 30
    end

    tmdb_results = fetch_tmdb_results(type, tmdb_query, seen_ids: seen_tmdb_ids)

    if tmdb_results.empty?
      tmdb_results = fetch_tmdb_results(
        type,
        tmdb_query.merge(page: 1, sort_by: "popularity.desc"),
        seen_ids: seen_tmdb_ids
      )
    end

    @movies = tmdb_results.first(10).shuffle.map { |result| upsert_movie(result, type) }

    render :swipe
  end

  def show
    @movie = Movie.find(params[:id])

    type = @movie.media_type.presence || "movie"

    enrich_movie_from_tmdb!(@movie, type: type)
    @movie.save!

    @actors = parse_actors(@movie.actors)
    @platforms = parse_platforms(@movie.platform)

    return unless @platforms.present?

    @watch_url = platform_watch_url(@platforms.first, @movie.title)
  end

  def swipe
    @movie = Movie.find(params[:id])
    if params[:decision] == "like"
      Historic.create!(user: current_user, movie: @movie)
      current_user.check_for_badges
    end
    head :ok
  end

  def surprise
    @movie = Movie.order("RANDOM()").first
  end

  def recommended
    # Films likés par l'utilisateur
    liked_review_ids = current_user.user_reviews.pluck(:review_id)
    liked_movie_ids = Review.where(id: liked_review_ids).pluck(:movie_id)

    # Films vus (à exclure)
    seen_ids = current_user.historics.pluck(:movie_id)

    # Utilisateurs qui ont liké les mêmes films
    similar_users = UserReview.where(review_id: liked_review_ids)
                              .where.not(user_id: current_user.id)
                              .pluck(:user_id)

    # Films likés par ces utilisateurs
    similar_movies = Movie.joins(reviews: :user_reviews)
                          .where(user_reviews: { user_id: similar_users })
                          .where.not(id: seen_ids)
                          .distinct

    # Films populaires non vus
    popular_unseen = Movie.left_joins(:reviews)
                          .where.not(id: seen_ids)
                          .group("movies.id")
                          .order("COUNT(reviews.id) DESC")
                          .limit(20)

    # Fusion intelligente
    @movies = (similar_movies + popular_unseen).uniq
  end

  def platform_watch_url(platform, title)
    base = PLATFORM_URLS[platform]
    return nil unless base

    "#{base}#{CGI.escape(title)}"
  end

  private

  def tmdb_get(path, query = {})
    HTTParty.get(
      "https://api.themoviedb.org/3/#{path}",
      headers: {
        "Authorization" => "Bearer #{ENV["TMDB_API_TOKEN"]}",
        "Content-Type" => "application/json"
      },
      query: query
    )
  end

  def fetch_tmdb_results(type, query, seen_ids: [])
    response = tmdb_get("discover/#{type}", query)
    (response["results"] || []).reject { |r| seen_ids.include?(r["id"]) }
  end

  def upsert_movie(result, type)
    movie = Movie.find_or_initialize_by(tmdb_id: result["id"])

    movie.assign_attributes(
      title: result["title"] || result["name"],
      synopsis: result["overview"],
      year: (result["release_date"] || result["first_air_date"])&.split("-")&.first&.to_i,
      rating: (result["vote_average"].to_f / 2).round(1),
      poster_url: result["poster_path"].present? ? "https://image.tmdb.org/t/p/w500#{result["poster_path"]}" : nil,
      category: params[:genre].presence || "Suggestion",
      media_type: type
    )

    enrich_movie_from_tmdb!(movie, type: type)
    movie.save!
    movie
  end

  def enrich_movie_from_tmdb!(movie, type: "movie")
    details = tmdb_get(
      "#{type}/#{movie.tmdb_id}",
      language: "fr-FR",
      append_to_response: "credits,videos"
    )

    watch_providers = tmdb_get("#{type}/#{movie.tmdb_id}/watch/providers")

    movie.actors = extract_top_actors(details)
    movie.trailer = extract_trailer_key(details)
    movie.platform = extract_french_platforms(watch_providers)

    if type == "movie"
      movie.duration = details["runtime"] if details["runtime"].present?
    elsif type == "tv"
      episode_times = details["episode_run_time"] || []
      movie.duration = episode_times.first if episode_times.any?
    end
  end

  def extract_top_actors(details)
    cast = details.dig("credits", "cast") || []

    cast.first(4).map do |actor|
      {
        "name" => actor["name"],
        "character" => actor["character"],
        "photo_url" => actor["profile_path"].present? ? "https://image.tmdb.org/t/p/w185#{actor['profile_path']}" : nil
      }
    end.to_json
  end

  def extract_trailer_key(details)
    videos = details.dig("videos", "results") || []

    trailer =
      videos.find { |video| video["site"] == "YouTube" && video["type"] == "Trailer" && video["official"] == true } ||
      videos.find { |video| video["site"] == "YouTube" && video["type"] == "Trailer" } ||
      videos.find { |video| video["site"] == "YouTube" && video["type"] == "Teaser" }

    trailer&.dig("key")
  end

  def extract_french_platforms(watch_providers)
    france = watch_providers.dig("results", "FR")
    return nil if france.blank?

    providers = Array(france["flatrate"])
    return nil if providers.blank?

    providers
      .map { |provider| normalize_platform(provider["provider_name"]) }
      .compact
      .uniq
      .join(", ")
  end

  def normalize_platform(name)
    case name
    when /Netflix/i
      "Netflix"
    when /Disney/i
      "Disney+"
    when /Prime/i
      "Prime Video"
    when /Canal/i
      "Canal+"
    when /HBO/i
      "HBO Max"
    else
      name
    end
  end

  def parse_actors(actors_data)
    return [] if actors_data.blank?

    parsed = JSON.parse(actors_data)
    parsed.is_a?(Array) ? parsed : []
  rescue JSON::ParserError
    []
  end

  def parse_platforms(platform_string)
    return [] if platform_string.blank?

    platform_string.split(",").map(&:strip)
  end

  def user_platforms
    return "" unless current_user

    PLATFORM_IDS
      .select { |platform, _| current_user.public_send(platform) }
      .values
      .join("|")
  end

  def parse_duration(duration, type)
    return nil if type == "tv"

    case duration
    when "1h30"  then 90
    when "2h"    then 120
    when "2h30+" then 999
    end
  end

  def excluded_genres(company)
    case company
    when "famille" then ""
    when "potes"   then "10751"
    when "seul"    then "10751,16"
    else ""
    end
  end

  def tmdb_genre_id(genre, type)
    type == "tv" ? TV_GENRES[genre] : MOVIE_GENRES[genre]
  end

end

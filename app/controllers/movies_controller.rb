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

  def index
    genre_id          = tmdb_genre_id(params[:genre])
    type              = params[:serie] == "1" ? "tv" : "movie"
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

    enrich_movie_from_tmdb!(@movie)
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
      # Vérification automatique des badges après un like
      current_user.check_for_badges
    end
    head :ok
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
        "Authorization" => "Bearer #{ENV.fetch('TMDB_API_TOKEN', nil)}",
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
      poster_url: result["poster_path"].present? ? "https://image.tmdb.org/t/p/w500#{result['poster_path']}" : nil,
      category: params[:genre].presence || "Suggestion"
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

    movie.actors  = extract_top_actors(details)
    movie.trailer = extract_trailer_key(details)
    movie.platform = extract_french_platforms(watch_providers)

    return unless type == "movie" && details["runtime"].present?

    movie.duration = details["runtime"]
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

    names = providers.map { |provider| normalize_platform(provider["provider_name"]) }

    names.compact.uniq.join(", ")
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

  def tmdb_genre_id(genre)
    {
      "Action" => 28,
      "Comédie" => 35,
      "Drame" => 18,
      "Thriller" => 53,
      "Science Fiction" => 878,
      "Horreur" => 27,
      "Romance" => 10_749,
      "Fantasy" => 14
    }[genre]
  end
end

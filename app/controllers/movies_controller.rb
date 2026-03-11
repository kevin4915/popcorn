class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  PLATFORM_IDS = {
    "Netflix" => 8,
    "DisneyPlus" => 337,
    "AmazonPrime" => 119,
    "CanalPlus" => 381,
    "HBO" => 384
  }.freeze

  def show
    @movie  = Movie.find(params[:id])
    credits = tmdb_get("movie/#{@movie.tmdb_id}/credits", language: "fr-FR")
    @actors = credits["cast"]&.first(4) || []
  end

  def index
    genre_id          = tmdb_genre_id(params[:genre])
    type              = params[:serie] == "1" ? "tv" : "movie"
    max_duration      = parse_duration(params[:duration], type)
    user_provider_ids = user_platforms
    without_genres    = excluded_genres(params[:company])
    seen_tmdb_ids     = current_user.movies.pluck(:tmdb_id).compact
    sort_options      = %w[popularity.desc vote_count.desc revenue.desc primary_release_date.desc]

    tmdb_query = {
      language: "fr-FR",
      with_genres: genre_id,
      without_genres: without_genres,
      sort_by: sort_options.sample,
      with_watch_providers: user_provider_ids,
      watch_region: "FR",
      "vote_count.gte" => 20,
      page: rand(1..20)
    }

    if max_duration
      tmdb_query["with_runtime.lte"] = max_duration
      tmdb_query["with_runtime.gte"] = 30
    end

    tmdb_results = fetch_tmdb_results(type, tmdb_query, seen_tmdb_ids)

    if tmdb_results.empty?
      tmdb_results = fetch_tmdb_results(
        type,
        tmdb_query.merge(page: 1, sort_by: "popularity.desc"),
        seen_tmdb_ids
      )
    end

    @movies = tmdb_results.first(10).shuffle.map { |result| upsert_movie(result) }

    render :swipe
  end

  def swipe
    @movie = Movie.find(params[:id])
    Historic.create!(user: current_user, movie: @movie) if params[:decision] == "like"
    head :ok
  end

  def surprise
    @movie = Movie.order("RANDOM()").first
  end

  def recommended
    # Films que l'utilisateur a vus
    seen_ids = current_user.historics.pluck(:movie_id)

    # Utilisateurs qui ont vu les mêmes films
    similar_users = Historic.where(movie_id: seen_ids)
                            .where.not(user_id: current_user.id)
                            .pluck(:user_id)

    # Films vus par ces utilisateurs (mais pas encore vus par toi)
    similar_movies = Movie.joins(:historics)
                          .where(historics: { user_id: similar_users })
                          .where.not(id: seen_ids)
                          .distinct

    # Films populaires (beaucoup de reviews), non vus
    popular_unseen = Movie.left_joins(:reviews)
                          .where.not(id: seen_ids)
                          .group("movies.id")
                          .order("COUNT(reviews.id) DESC")
                          .limit(20)

    # Fusion intelligente
    @movies = (similar_movies + popular_unseen).uniq
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

  def fetch_tmdb_results(type, query, seen_ids)
    response = tmdb_get("discover/#{type}", query)
    (response["results"] || []).reject { |r| seen_ids.include?(r["id"]) }
  end

  def upsert_movie(result)
    Movie.find_or_create_by!(tmdb_id: result["id"]) do |movie|
      movie.title     = result["title"] || result["name"]
      movie.synopsis  = result["overview"]
      movie.year      = (result["release_date"] || result["first_air_date"])&.split("-")&.first&.to_i
      movie.rating    = (result["vote_average"].to_f / 2).round(1)
      movie.poster_url = "https://image.tmdb.org/t/p/w500#{result['poster_path']}"
      movie.category  = params[:genre]
      movie.platform  = "TMDB"
    end
  end

  def user_platforms
    PLATFORM_IDS
      .select { |platform, _| current_user.send(platform) }
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

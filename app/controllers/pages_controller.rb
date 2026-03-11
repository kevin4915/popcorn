class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @top_day = fetch_trending_day_movies
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

  def fetch_trending_day_movies
    response = tmdb_get("trending/movie/day", language: "fr-FR")
    results = response["results"] || []

    results.first(10).map { |result| upsert_movie(result) }
  end

  def upsert_movie(result)
    movie = Movie.find_or_initialize_by(tmdb_id: result["id"])

    movie.assign_attributes(
      title: result["title"],
      synopsis: result["overview"],
      year: result["release_date"]&.split("-")&.first&.to_i,
      rating: (result["vote_average"].to_f / 2).round(1),
      poster_url: result["poster_path"].present? ? "https://image.tmdb.org/t/p/w500#{result['poster_path']}" : nil,
      category: "Tendance du jour"
    )

    enrich_movie_from_tmdb!(movie)
    movie.save!
    movie
  end

  def enrich_movie_from_tmdb!(movie)
    details = tmdb_get(
      "movie/#{movie.tmdb_id}",
      language: "fr-FR",
      append_to_response: "credits,videos"
    )

    watch_providers = tmdb_get("movie/#{movie.tmdb_id}/watch/providers")

    movie.actors   = extract_top_actors(details)
    movie.trailer  = extract_trailer_key(details)
    movie.duration = details["runtime"] if details["runtime"].present?
    movie.platform = extract_french_platforms(watch_providers)
  end

  def extract_top_actors(details)
    cast = details.dig("credits", "cast") || []
    cast.first(5).map { |actor| actor["name"] }.join(", ")
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

    providers.map { |provider| provider["provider_name"] }.uniq.join(", ")
  end
end

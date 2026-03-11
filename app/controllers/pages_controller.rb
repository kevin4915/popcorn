class PagesController < ApplicationController
  before_action :authenticate_user!, only: %i[home calendar]

  def home
    @top_day = fetch_trending_day_movies
  end

  def calendar
    upcoming_raw = fetch_upcoming_movies_france

    @upcoming_by_date = upcoming_raw
                        .select { |item| item[:release_date].present? }
                        .group_by { |item| item[:release_date] }
                        .sort
                        .to_h
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

    results.first(10).map { |result| upsert_movie(result, "Tendance du jour") }
  end

  def fetch_now_playing_movies
    response = tmdb_get("movie/now_playing", language: "fr-FR", page: 1)
    results = response["results"] || []

    results.first(10).map do |result|
      movie = upsert_movie(result, "Sortie du moment")
      build_movie_calendar_item(movie, "film", result["release_date"])
    end
  end

  def fetch_airing_today_series
    response = tmdb_get("tv/airing_today", language: "fr-FR", page: 1)
    results = response["results"] || []

    results.first(10).map do |result|
      build_series_calendar_item(result)
    end
  end

  def fetch_upcoming_movies_france
    today = Date.current.strftime("%Y-%m-%d")
    results = []

    (1..2).each do |page|
      response = tmdb_get(
        "discover/movie",
        language: "fr-FR",
        region: "FR",
        sort_by: "release_date.asc",
        "release_date.gte" => today,
        "with_release_type" => "2|3",
        page: page
      )

      results.concat(response["results"] || [])
    end

    results
      .select do |result|
        result["release_date"].present? && result["release_date"] >= today
      end
      .uniq { |result| result["id"] }
      .first(40)
      .map do |result|
        movie = upsert_movie(result, "À venir")

        {
          id: movie.id,
          title: movie.title,
          synopsis: movie.synopsis,
          poster_url: movie.poster_url,
          rating: movie.rating,
          release_date: result["release_date"],
          platform: movie.platform
        }
      end
  end

  def upsert_movie(result, category_label)
    movie = Movie.find_or_initialize_by(tmdb_id: result["id"])

    movie.assign_attributes(
      title: result["title"],
      synopsis: result["overview"],
      year: result["release_date"]&.split("-")&.first&.to_i,
      rating: (result["vote_average"].to_f / 2).round(1),
      poster_url: result["poster_path"].present? ? "https://image.tmdb.org/t/p/w500#{result['poster_path']}" : nil,
      category: category_label
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

  def build_movie_calendar_item(movie, media_type, release_date = nil)
    {
      id: movie.id,
      tmdb_id: movie.tmdb_id,
      title: movie.title,
      synopsis: movie.synopsis,
      poster_url: movie.poster_url,
      rating: movie.rating,
      release_date: release_date,
      raw_release_date: release_date,
      platform: movie.platform,
      media_type: media_type
    }
  end

  def build_series_calendar_item(result)
    {
      id: nil,
      tmdb_id: result["id"],
      title: result["name"],
      synopsis: result["overview"],
      poster_url: result["poster_path"].present? ? "https://image.tmdb.org/t/p/w500#{result['poster_path']}" : nil,
      rating: (result["vote_average"].to_f / 2).round(1),
      release_date: result["first_air_date"],
      raw_release_date: result["first_air_date"],
      platform: nil,
      media_type: "série"
    }
  end

  def fetch_movie_release_date(tmdb_id)
    details = tmdb_get("movie/#{tmdb_id}", language: "fr-FR")
    details["release_date"]
  end

  def formatted_date(_year, tmdb_id)
    fetch_movie_release_date(tmdb_id)
  end
end

require "net/http"
require "json"

class TmdbService
  BASE_URL   = "https://api.themoviedb.org/3"
  IMAGE_BASE = "https://image.tmdb.org/t/p/w500"

  def self.api_key
    ENV.fetch("TMDB_API_KEY", nil)
  end

  # ------------------------------------
  # 🔍 Recherche + infos complètes (FR)
  # ------------------------------------
  def self.full_movie_info(title)
    return nil if title.blank? || api_key.blank?

    # Recherche FR
    search_url = URI("#{BASE_URL}/search/movie?api_key=#{api_key}&query=#{URI.encode_www_form_component(title)}&language=fr-FR")
    search_data = JSON.parse(Net::HTTP.get(search_url))
    return nil if search_data["results"].nil? || search_data["results"].empty?

    movie = search_data["results"].first
    movie_id = movie["id"]

    # Détails FR
    details_url = URI("#{BASE_URL}/movie/#{movie_id}?api_key=#{api_key}&language=fr-FR")
    details = JSON.parse(Net::HTTP.get(details_url))

    # Casting FR
    credits_url = URI("#{BASE_URL}/movie/#{movie_id}/credits?api_key=#{api_key}&language=fr-FR")
    credits = JSON.parse(Net::HTTP.get(credits_url))

    # 🎥 Trailers FR
    videos_url = URI("#{BASE_URL}/movie/#{movie_id}/videos?api_key=#{api_key}&language=fr-FR")
    videos = JSON.parse(Net::HTTP.get(videos_url))

    # On récupère le trailer YouTube FR
    trailer = videos["results"]&.find { |v| v["site"] == "YouTube" && v["type"] == "Trailer" }

    {
      title: details["title"],
      overview: details["short_overview"],
      release_year: details["release_date"]&.split("-")&.first,
      runtime: details["runtime"],
      rating: details["vote_average"],
      genres: details["genres"]&.map { |g| g["name"] },
      poster_url: movie["poster_path"] ? "#{IMAGE_BASE}#{movie['poster_path']}" : nil,
      cast: credits["cast"]&.first(5)&.map { |c| c["name"] },
      trailer_url: trailer ? "https://www.youtube.com/watch?v=#{trailer['key']}" : nil
    }
  rescue StandardError => e
    Rails.logger.error "TMDB ERROR: #{e.message}"
    nil
  end
end

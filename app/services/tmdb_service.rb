require "net/http"
require "json"

class TmdbService
  BASE_URL = "https://api.themoviedb.org/3"
  IMAGE_BASE = "https://image.tmdb.org/t/p/w500"

  def self.search_movie(title)
    return nil if title.nil? || title.strip.empty?

    api_key = ENV.fetch("TMDB_API_KEY", nil)
    return nil unless api_key

    # 1) Première tentative : titre brut
    movie = fetch_movie(title, api_key)

    # 2) Deuxième tentative : titre simplifié
    if movie.nil?
      simplified = title.gsub(/[^a-zA-Z0-9 ]/, "")
      movie = fetch_movie(simplified, api_key)
    end

    return nil if movie.nil?

    poster_path = movie["poster_path"]
    poster_url = poster_path ? "#{IMAGE_BASE}#{poster_path}" : nil

    {
      poster_url: poster_url,
      tmdb_id: movie["id"],
      title: movie["title"]
    }
  end

  def self.fetch_movie(query, api_key)
    url = URI("#{BASE_URL}/search/movie?api_key=#{api_key}&query=#{URI.encode_www_form_component(query)}")

    begin
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
      return nil if data["results"].nil? || data["results"].empty?

      data["results"].first
    rescue StandardError => e
      Rails.logger.error "TMDB ERROR: #{e.message}"
      nil
    end
  end
end

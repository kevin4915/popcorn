require "net/http"
require "json"

class TmdbService
  BASE_URL = "https://api.themoviedb.org/3"
  IMAGE_BASE = "https://image.tmdb.org/t/p/w500"

  def self.search_movie(title)
    return nil if title.nil? || title.strip.empty?

    api_key = ENV.fetch("TMDB_API_KEY", nil)
    return nil unless api_key

    url = URI("#{BASE_URL}/search/movie?api_key=#{api_key}&query=#{URI.encode_www_form_component(title)}")

    begin
      response = Net::HTTP.get(url)
      data = JSON.parse(response)
    rescue StandardError => e
      Rails.logger.error "TMDB ERROR: #{e.message}"
      return nil
    end

    return nil if data["results"].nil? || data["results"].empty?

    movie = data["results"].first

    poster_path = movie["poster_path"]
    poster_url = poster_path ? "#{IMAGE_BASE}#{poster_path}" : nil

    {
      poster_url: poster_url,
      tmdb_id: movie["id"],
      title: movie["title"]
    }
  end
end

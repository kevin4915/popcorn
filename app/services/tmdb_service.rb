require "net/http"
require "json"

class TmdbService
  BASE_URL   = "https://api.themoviedb.org/3"
  IMAGE_BASE = "https://image.tmdb.org/t/p/w500"

  class << self
    def api_token
      ENV["TMDB_API_TOKEN"]
    end

    def full_movie_info(title)
      return nil if title.blank? || api_token.blank?

      search_results = search_movie(title)
      return nil if search_results.blank?

      movie = search_results.first
      movie_id = movie["id"]
      return nil if movie_id.blank?

      details = get_json("/movie/#{movie_id}", language: "fr-FR")
      credits = get_json("/movie/#{movie_id}/credits", language: "fr-FR")
      videos  = get_json("/movie/#{movie_id}/videos", language: "fr-FR")

      trailer = pick_trailer(videos["results"])

      result = {
        tmdb_id: movie_id,
        title: details["title"] || movie["title"],
        overview: details["overview"],
        short_overview: truncate_text(details["overview"], 180),
        release_year: extract_year(details["release_date"] || movie["release_date"]),
        runtime: details["runtime"],
        rating: normalize_rating(details["vote_average"]),
        genres: Array(details["genres"]).map { |genre| genre["name"] },
        poster_url: poster_url_for(details["poster_path"] || movie["poster_path"]),
        cast: Array(credits["cast"]).first(5).map { |cast_member| cast_member["name"] },
        trailer_url: trailer.present? ? "https://www.youtube.com/watch?v=#{trailer['key']}" : nil
      }

      Rails.logger.info("TMDB RESULT => #{result.inspect}")
      result
    rescue StandardError => e
      Rails.logger.error("TMDB ERROR: #{e.class} - #{e.message}")
      nil
    end

    private

    def search_movie(title)
      # 1er essai en français
      response = get_json("/search/movie", query: title, language: "fr-FR", include_adult: false)
      results = response["results"] || []
      return results if results.any?

      # fallback en anglais si rien trouvé
      fallback = get_json("/search/movie", query: title, language: "en-US", include_adult: false)
      fallback["results"] || []
    end

    def get_json(path, params = {})
      uri = URI("#{BASE_URL}#{path}")
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{api_token}"
      request["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "TMDB request failed (#{response.code}) for #{uri}"
      end

      JSON.parse(response.body)
    end

    def pick_trailer(results)
      videos = Array(results)

      videos.find { |video| video["site"] == "YouTube" && video["type"] == "Trailer" && video["official"] == true } ||
        videos.find { |video| video["site"] == "YouTube" && video["type"] == "Trailer" } ||
        videos.find { |video| video["site"] == "YouTube" && video["type"] == "Teaser" }
    end

    def poster_url_for(path)
      return nil if path.blank?

      "#{IMAGE_BASE}#{path}"
    end

    def extract_year(date)
      return nil if date.blank?

      date.to_s.split("-").first.to_i
    end

    def normalize_rating(vote_average)
      return nil if vote_average.blank?

      (vote_average.to_f / 2).round(1)
    end

    def truncate_text(text, max_length = 180)
      return nil if text.blank?
      return text if text.length <= max_length

      "#{text[0...max_length].rstrip}..."
    end
  end

  def self.quick_movie_info(title)
    return nil if title.blank? || api_token.blank?

    results = search_movie(title)
    return nil if results.blank?

    movie = results.first

    {
      tmdb_id: movie["id"],
      title: movie["title"],
      synopsis: truncate_text(movie["overview"], 180),
      year: extract_year(movie["release_date"]),
      rating: normalize_rating(movie["vote_average"]),
      poster_url: poster_url_for(movie["poster_path"])
    }
  rescue StandardError => e
    Rails.logger.error("TMDB QUICK ERROR: #{e.class} - #{e.message}")
    nil
  end
end

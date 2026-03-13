require "net/http"
require "json"

class TmdbService
  BASE_URL = "https://api.themoviedb.org/3"

  def self.search_movie(title)
    url = URI("#{BASE_URL}/search/movie?api_key=#{ENV.fetch('TMDB_API_KEY', nil)}&query=#{URI.encode(title)}")

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    return nil if data["results"].empty?

    movie = data["results"].first

    {
      poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}",
      tmdb_id: movie["id"]
    }
  end
end

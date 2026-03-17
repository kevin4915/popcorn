class MovieRecommendationService
  require "net/http"
  require "json"

  def self.call(query)
    # 1) Appel à ton endpoint IA
    uri = URI("https://ton-endpoint-ia.com/recommend")
    response = Net::HTTP.post(uri, { query: query }.to_json, "Content-Type" => "application/json")

    # 2) Parse JSON → Hash Ruby
    movies = JSON.parse(response.body)

    # 3) Ajout optionnel des posters TMDB
    movies.map do |movie|
      poster = fetch_poster(movie["title"])
      movie.merge("poster_url" => poster)
    end
  end

  def self.fetch_poster(title)
    api_key = ENV.fetch("TMDB_API_KEY", nil)
    url = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{URI.encode(title)}")

    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    if data["results"] && data["results"].any?
      "https://image.tmdb.org/t/p/w500#{data['results'][0]['poster_path']}"
    else
      nil
    end
  end
end

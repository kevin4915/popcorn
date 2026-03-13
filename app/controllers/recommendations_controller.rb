class RecommendationsController < ApplicationController
  def create
    query = params[:query]

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: "Tu es un expert cinéma. Donne-moi 5 films similaires à : #{query}. Réponds uniquement en JSON : [ { \"title\": \"\", \"year\": \"\", \"genre\": \"\", \"summary\": \"\" } ]"
          }
        ]
      }
    )

    raw = response.dig("choices", 0, "message", "content")
    cleaned = raw[/

\[[\s\S]*\]

/]

    begin
      movies = JSON.parse(cleaned)
    rescue StandardError
      movies = []
    end

    # Ajout des affiches TMDB
    @movies = movies.map do |movie|
      tmdb = TmdbService.search_movie(movie["title"])
      movie.merge("poster_url" => tmdb&.dig(:poster_url))
    end

    render :results
  end
end

class RecommendationsController < ApplicationController
  def index
    redirect_to new_recommendation_path
    @recommendations = RecommendationService.call
    @movies = MovieService.call(params[:query])
  end

  def new
  end

  def create
    query = params[:query]

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: <<~PROMPT
              Tu es un expert cinéma.
              Donne-moi exactement 5 films similaires à : #{query}.
              Réponds STRICTEMENT avec un JSON valide, sans texte avant ni après.
              Format :
              [
                { "title": "", "year": "", "genre": "", "summary": "" }
              ]
            PROMPT
          }
        ]
      }
    )

    raw = response.dig("choices", 0, "message", "content")
    puts "RAW RESPONSE:"
    puts raw

    json_match = raw.match(/

\[[\s\S]*\]

/)
    cleaned = json_match ? json_match[0] : "[]"

    begin
      movies = JSON.parse(cleaned)
    rescue StandardError
      movies = []
    end

    # Ajout des affiches TMDB
    @movies = movies.map do |movie|
      begin
        tmdb = TmdbService.search_movie(movie["title"])
        poster = tmdb && tmdb[:poster_url] ? tmdb[:poster_url] : nil
      rescue StandardError
        poster = nil
      end

      movie.merge("poster_url" => poster)
    end

    render :results
  end
end

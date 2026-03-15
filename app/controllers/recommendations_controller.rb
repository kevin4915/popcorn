class RecommendationsController < ApplicationController
  def index
    redirect_to new_recommendation_path and return
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

              Donne-moi EXACTEMENT 5 films similaires à : "#{query}".

              Règles STRICTES :
              - Utilise UNIQUEMENT les titres EXACTS tels qu'ils apparaissent sur TMDB.
              - Pas d'apostrophes, pas de guillemets spéciaux, pas de variantes.
              - Pas de texte avant ou après le JSON.
              - Le JSON doit être parfaitement valide.
              - Le résumé doit être en français.
              - L'année doit être un nombre (pas une string).

              Réponds UNIQUEMENT avec ce JSON :
              [
                {
                  "title": "",
                  "year": 0,
                  "genre": "",
                  "summary": ""
                }
              ]
            PROMPT
          }
        ]
      }
    )

    raw = response.dig("choices", 0, "message", "content")
    puts "RAW RESPONSE:"
    puts raw

    begin
      movies = JSON.parse(raw)
    rescue JSON::ParserError
      movies = []
    end

    @movies = movies.map do |movie|
      begin
        tmdb = TmdbService.search_movie(movie["title"])
        poster = tmdb && tmdb[:poster_url] ? tmdb[:poster_url] : nil
      rescue StandardError
        poster = nil
      end

      movie.merge("poster_url" => poster)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :results }
    end
  end
end

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
              - Réponds UNIQUEMENT avec un JSON.
              - Le JSON doit être un TABLEAU contenant 5 objets.
              - Pas de texte avant ou après.
              - Pas de commentaires.
              - Pas d'objet seul : toujours un tableau de 5 éléments.
              - Utilise UNIQUEMENT les titres EXACTS tels qu'ils apparaissent sur TMDB.
              - Le résumé doit être en français.
              - L'année doit être un nombre (pas une string).

              Format OBLIGATOIRE :
              [
                {
                  "title": "Titre exact TMDB",
                  "year": 2000,
                  "genre": "Genre",
                  "summary": "Résumé en français"
                },
                {
                  "title": "Titre exact TMDB",
                  "year": 2000,
                  "genre": "Genre",
                  "summary": "Résumé en français"
                },
                {
                  "title": "Titre exact TMDB",
                  "year": 2000,
                  "genre": "Genre",
                  "summary": "Résumé en français"
                },
                {
                  "title": "Titre exact TMDB",
                  "year": 2000,
                  "genre": "Genre",
                  "summary": "Résumé en français"
                },
                {
                  "title": "Titre exact TMDB",
                  "year": 2000,
                  "genre": "Genre",
                  "summary": "Résumé en français"
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

    # -----------------------------
    #  PARSING ROBUSTE DU JSON
    # -----------------------------
    begin
      movies = JSON.parse(raw)

      # Si OpenAI renvoie un objet seul → on le transforme en tableau
      movies = [movies] if movies.is_a?(Hash)

      # Si OpenAI renvoie moins de 5 films → on complète
      if movies.length < 5
        missing = 5 - movies.length
        movies += Array.new(missing) do
          {
            "title" => "Film manquant",
            "year" => 0,
            "genre" => "",
            "summary" => ""
          }
        end
      end

      # Si OpenAI renvoie plus de 5 films → on coupe
      movies = movies.first(5)
    rescue JSON::ParserError
      # JSON cassé → on renvoie 5 placeholders
      movies = Array.new(5) do
        {
          "title" => "Film introuvable",
          "year" => 0,
          "genre" => "",
          "summary" => ""
        }
      end
    end

    # -----------------------------
    #  ENRICHISSEMENT TMDB COMPLET
    # -----------------------------
    @movies = movies.map do |movie|
      tmdb = TmdbService.full_movie_info(movie["title"])

      movie.merge(
        "poster_url" => tmdb&.dig(:poster_url),
        "rating" => tmdb&.dig(:rating),
        "runtime" => tmdb&.dig(:runtime),
        "genres" => tmdb&.dig(:genres),
        "overview" => tmdb&.dig(:short_overview),
        "release_year" => tmdb&.dig(:release_year),
        "trailer_url" => tmdb&.dig(:trailer_url)
      )
    end

    Rails.logger.info "DEBUG FINAL => #{@movies.first.inspect}"

    render :results
  end
end

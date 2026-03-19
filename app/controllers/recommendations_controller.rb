class RecommendationsController < ApplicationController
  def index
    redirect_to new_recommendation_path
  end

  def new
  end

  def create
    query = params[:query].to_s.strip

    if query.blank?
      @movies = []
      flash.now[:alert] = "Entre un film pour lancer la recherche."
      render :new and return
    end

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: <<~PROMPT
              Tu es un expert cinéma.

              Donne-moi EXACTEMENT 5 films similaires à "#{query}".

              Règles STRICTES :
              - Réponds UNIQUEMENT avec un JSON
              - Le JSON doit être un TABLEAU de 5 objets
              - Pas de texte avant ou après
              - Chaque objet doit contenir uniquement :
                - "title"

              Format :
              [
                { "title": "Titre exact TMDB" }
              ]
            PROMPT
          }
        ]
      }
    )

    raw = response.dig("choices", 0, "message", "content").to_s.strip
    raw = raw.gsub(/\A```json\s*/i, "").gsub(/\A```\s*/i, "").gsub(/```$/, "").strip

    begin
      movies = JSON.parse(raw)
      movies = [movies] if movies.is_a?(Hash)

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

      movies = movies.first(5)
    rescue JSON::ParserError
      movies = Array.new(5) do
        {
          "title" => "Film introuvable",
          "year" => 0,
          "genre" => "",
          "summary" => ""
        }
      end
    end

  @movies = movies.map do |movie|
    next if movie["title"].blank?

    tmdb = TmdbService.quick_movie_info(movie["title"])

    if tmdb.present? && tmdb[:tmdb_id].present?
      record = Movie.find_or_initialize_by(tmdb_id: tmdb[:tmdb_id])

      record.assign_attributes(
        title: tmdb[:title].presence || movie["title"],
        synopsis: tmdb[:synopsis].presence || movie["summary"],
        year: tmdb[:year].presence || movie["year"],
        rating: tmdb[:rating],
        poster_url: tmdb[:poster_url],
        category: movie["genre"],
        media_type: "movie"
      )

      record.save!
      record
    else
      # fallback : on affiche quand même quelque chose
      Movie.new(
        title: movie["title"],
        synopsis: movie["summary"],
        year: movie["year"],
        category: movie["genre"],
        media_type: "movie"
      )
    end
  end.compact

    render :new
  end
end

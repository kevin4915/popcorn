class RecommendationService
  def self.call(query)
    client = RubyLLM::Client.new

    prompt = <<~PROMPT
      Tu es un expert cinéma. Réponds uniquement en JSON.
      Donne-moi 5 films similaires à : "#{query}"

      Format attendu :
      [
        { "title": "...", "year": "...", "genre": "...", "summary": "..." },
        ...
      ]
    PROMPT

    response = client.chat(
      model: "gpt-4.1-mini",
      messages: [
        { role: "user", content: prompt }
      ]
    )

    JSON.parse(response)
  rescue StandardError => e
    Rails.logger.error "RecommendationService ERROR: #{e.message}"
    []
  end
end

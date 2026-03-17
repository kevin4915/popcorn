class OpenaiService
  def self.recommend_movies(query)
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: "gpt-4.1",
        messages: [
          { role: "system", content: "Tu es un expert cinéma." },
          { role: "user", content: "Donne-moi 5 films similaires à : #{query}" }
        ]
      }
    )

    content = response.dig("choices", 0, "message", "content")
    JSON.parse(content)
  end
end

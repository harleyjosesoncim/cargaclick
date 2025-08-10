# app/services/gpt_service.rb
require 'openai'

class GptService
  def self.generate_content(prompt)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    begin
      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.7
        }
      )

      if response.dig('choices', 0, 'message', 'content').present?
        return response.dig('choices', 0, 'message', 'content').strip
      else
        puts "❌ Erro: Resposta vazia da API OpenAI"
        puts response
        return "Erro: A resposta da IA veio vazia."
      end

    rescue => e
      puts "❌ Erro ao conectar com a API OpenAI: #{e.message}"
      return "Erro de conexão com a IA."
    end
  end
end


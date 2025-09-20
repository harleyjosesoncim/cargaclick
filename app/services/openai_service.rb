require 'net/http'
require 'uri'
require 'json'

class OpenaiService
  def initialize(prompt)
    @prompt = prompt
    @api_key = ENV['OPENAI_API_KEY']
  end

  def call
    uri = URI.parse("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{@api_key}"
    }

    body = {
      model: "gpt-3.5-turbo",
      messages: [
        { role: "user", content: @prompt }
      ],
      temperature: 0.7
    }.to_json

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      return json["choices"][0]["message"]["content"].strip
    else
      Rails.logger.error "Erro OpenAI: #{response.code} - #{response.body}"
      return "Erro ao gerar proposta. Tente novamente mais tarde."
    end
  rescue => e
    Rails.logger.error "Exceção OpenAI: #{e.message}"
    "Erro na IA. Tente novamente."
  end
end

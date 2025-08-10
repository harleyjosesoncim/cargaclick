class MarketingController < ApplicationController
  before_action :authenticate_admin_master!

  require 'net/http'
  require 'json'

  def gerar_post_instagram
    prompt = "Crie um post chamativo e profissional para Instagram, convidando empresas a contratarem fretes com a plataforma CargaClick. O texto deve ser curto, com emojis e uma chamada para ação."

    resultado = chamar_openai(prompt)
    render json: { resultado: resultado }
  end

  def gerar_email_marketing
    prompt = "Crie um template de e-mail marketing para a CargaClick, focado em atrair novos clientes para simular fretes. O texto deve ser objetivo, persuasivo e conter uma chamada para ação com link."

    resultado = chamar_openai(prompt)
    render json: { resultado: resultado }
  end

  def gerar_proposta_comercial
    prompt = "Gere uma proposta comercial formal para uma empresa interessada em contratar fretes recorrentes via CargaClick. Destaque economia, agilidade e gestão simplificada."

    resultado = chamar_openai(prompt)
    render json: { resultado: resultado }
  end

  private

  def authenticate_admin_master!
    unless current_cliente&.email == 'admin@cargaclick.com'
      render json: { resultado: 'Acesso restrito.' }, status: :unauthorized
    end
  end

  def chamar_openai(prompt)
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}"
    }

    body = {
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.7
    }.to_json

    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = body

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      json = JSON.parse(response.body)
      json['choices'][0]['message']['content'].strip
    else
      "Erro ao gerar resposta: #{response.code}"
    end
  rescue => e
    "Erro de conexão com IA: #{e.message}"
  end
end


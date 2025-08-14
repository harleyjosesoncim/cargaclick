# frozen_string_literal: true
class AiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :chat

  rescue_from JSON::ParserError do
    render json: { message: "JSON inválido" }, status: :bad_request
  end

  def test
    text = call_ai(prompt: "Diga 'ok' em PT-BR.")
    render json: { ok: text.present?, text: text }
  end

  # aceita:
  # - { "prompt": "..." }
  # - { "messages": [{role, content}, ...], "temperature": 0.2 }
  def chat
    temperature = (params[:temperature].presence || 0.3).to_f

    if params[:messages].present?
      messages = normalize_messages(params[:messages])
      text     = call_ai(messages: messages, temperature: temperature)
    else
      prompt = params[:prompt].to_s
      return render(json: { message: "prompt obrigatório" }, status: :bad_request) if prompt.blank?
      text = call_ai(prompt: prompt, temperature: temperature)
    end

    return render(json: { message: "IA indisponível" }, status: :service_unavailable) if text.blank?
    render json: { text: text }
  end

  private

  def call_ai(prompt: nil, messages: nil, temperature: 0.3)
    GptService.new(prompt: prompt, messages: messages, temperature: temperature).call
  rescue => e
    Rails.logger.error("AI controller error: #{e.class} - #{e.message}")
    nil
  end

  def normalize_messages(arr)
    Array(arr).map do |m|
      if m.is_a?(Hash)
        { role: m[:role].to_s.presence || "user", content: m[:content].to_s }
      else
        { role: "user", content: m.to_s }
      end
    end
  end
end


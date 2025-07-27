class RastreamentoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rastreamento_#{params[:frete_id]}"
  end
end

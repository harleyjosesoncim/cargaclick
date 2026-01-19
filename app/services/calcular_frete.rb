# app/services/calcular_frete.rb
class CalcularFrete
  PRECO_BASE_KM = 2.50 # R$/km
  TAXA_MINIMA   = 30.0 # R$

  # Interface pública
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    params ||= {}

    @origem       = params[:origem].to_s.strip
    @destino      = params[:destino].to_s.strip
    @peso         = params[:peso].to_f
    @tipo_veiculo = params[:tipo_veiculo].to_s.strip
  end

  # ==================================================
  # Execução principal
  # ==================================================
  def call
    erros = validar_parametros
    return erro("Parâmetros inválidos", erros) if erros.any?

    distancia_km = calcular_distancia_estimada
    valor        = calcular_valor(distancia_km)

    sucesso(
      origem: @origem,
      destino: @destino,
      distancia_km: distancia_km.round(2),
      valor: valor.round(2)
    )
  rescue StandardError => e
    Rails.logger.error(
      "[CalcularFrete][FATAL] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    )
    erro("Erro interno ao simular frete")
  end

  private

  # ==================================================
  # Validação (NÃO levanta exception)
  # ==================================================
  def validar_parametros
    erros = []
    erros << "Origem inválida"  if @origem.blank?
    erros << "Destino inválido" if @destino.blank?
    erros << "Peso inválido"    if @peso <= 0
    erros
  end

  # ==================================================
  # Distância (placeholder seguro)
  # ==================================================
  # Substituir futuramente por OpenRouteService / Google Maps
  def calcular_distancia_estimada
    # heurística simples e determinística para MVP
    base_km = 20 + rand(30..90)
    base_km + (@peso / 10.0)
  end

  # ==================================================
  # Valor
  # ==================================================
  def calcular_valor(distancia_km)
    valor = distancia_km * PRECO_BASE_KM
    valor < TAXA_MINIMA ? TAXA_MINIMA : valor
  end

  # ==================================================
  # Helpers de retorno (contrato fixo)
  # ==================================================
  def sucesso(payload = {})
    {
      sucesso: true,
      mensagem: "Simulação realizada com sucesso",
      **payload
    }
  end

  def erro(mensagem, detalhes = nil)
    {
      sucesso: false,
      mensagem: mensagem,
      detalhes: detalhes
    }
  end
end

# app/services/calcular_frete.rb
class CalcularFrete
  # ============================
  # CONSTANTES DE NEGÓCIO
  # ============================
  PRECO_BASE_KM = 2.50 # R$/km
  TAXA_MINIMA   = 30.0 # R$

  # ============================
  # INTERFACE PÚBLICA (ESTÁVEL)
  # ============================
  def self.call(params)
    new(params).call
  end

  # ============================
  # INICIALIZAÇÃO DEFENSIVA
  # ============================
  def initialize(params)
    params ||= {}

    @origem       = normalizar_texto(params[:origem])
    @destino      = normalizar_texto(params[:destino])
    @peso         = normalizar_numero(params[:peso])
    @tipo_veiculo = normalizar_texto(params[:tipo_veiculo])
  end

  # ============================
  # EXECUÇÃO PRINCIPAL
  # ============================
  def call
    erros = validar_parametros
    return resposta_erro("Parâmetros inválidos", erros) if erros.any?

    distancia_km = calcular_distancia_estimada
    breakdown    = calcular_breakdown(distancia_km)

    resposta_sucesso(
      origem: @origem,
      destino: @destino,
      distancia_km: distancia_km.round(2),
      valor: breakdown[:valor_final],
      breakdown: breakdown
    )
  rescue StandardError => e
    log_erro_fatal(e)
    resposta_erro("Erro interno ao simular frete")
  end

  private

  # ==================================================
  # NORMALIZAÇÃO DE DADOS (ANTI-SURPRESA)
  # ==================================================
  def normalizar_texto(valor)
    valor.to_s.strip
  end

  def normalizar_numero(valor)
    Float(valor)
  rescue StandardError
    0.0
  end

  # ==================================================
  # VALIDAÇÃO DE CONTRATO
  # ==================================================
  def validar_parametros
    erros = []

    erros << "Origem inválida"  if @origem.blank?
    erros << "Destino inválido" if @destino.blank?
    erros << "Peso inválido"    if @peso <= 0

    erros
  end

  # ==================================================
  # DISTÂNCIA (FALLBACK SEGURO)
  # ==================================================
  # OBS: aqui entra ORS futuramente
  def calcular_distancia_estimada
    distancia_placeholder
  rescue StandardError => e
    Rails.logger.warn("[CalcularFrete][DISTANCIA][FALLBACK] #{e.message}")
    distancia_placeholder
  end

  def distancia_placeholder
    base_km = 20 + rand(30..90)
    (base_km + (@peso / 10.0)).to_f
  end

  # ==================================================
  # BREAKDOWN DO CÁLCULO (AUDITÁVEL)
  # ==================================================
  def calcular_breakdown(distancia_km)
    valor_por_km = distancia_km * PRECO_BASE_KM
    valor_base   = [valor_por_km, TAXA_MINIMA].max

    # Reservado para regras futuras
    ajuste_fidelidade   = 0.0
    comissao_plataforma = 0.0

    {
      preco_por_km: PRECO_BASE_KM,
      distancia_km: distancia_km.round(2),
      valor_por_km: valor_por_km.round(2),
      taxa_minima: TAXA_MINIMA,
      ajuste_fidelidade: ajuste_fidelidade,
      comissao_plataforma: comissao_plataforma,
      valor_final: (valor_base + ajuste_fidelidade + comissao_plataforma).round(2)
    }
  end

  # ==================================================
  # RESPOSTAS PADRONIZADAS
  # ==================================================
  def resposta_sucesso(payload = {})
    {
      sucesso: true,
      mensagem: "Simulação realizada com sucesso",
      **payload
    }
  end

  def resposta_erro(mensagem, detalhes = nil)
    {
      sucesso: false,
      mensagem: mensagem,
      detalhes: detalhes
    }
  end

  # ==================================================
  # LOGGING DE PRODUÇÃO (CONTROLADO)
  # ==================================================
  def log_erro_fatal(exception)
    Rails.logger.error(
      "[CalcularFrete][FATAL] #{exception.class}: #{exception.message}\n" \
      "#{exception.backtrace&.first(5)&.join("\n")}"
    )
  end
end

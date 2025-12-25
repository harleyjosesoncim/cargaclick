# frozen_string_literal: true

# Smoke test do CargaClick:
# - Cria (ou reaproveita) 1 Cliente e 1 Transportador
# - Cria 1 Frete, 1 Cotação e 1 Pagamento (pendente)
# - Não mexe em layout; serve para validar amarrações de modelo/banco
#
# Observação: o model Transportador tem validações obrigatórias (cidade, tipo_documento, documento, etc).
# Este task preenche tudo de forma "fake porém válida" para não travar o fluxo.
namespace :cargaclick do
  desc "Smoke test: cria cliente/transportador fake e valida fluxo mínimo"
  task smoke: :environment do
    puts "== CargaClick smoke test =="

    require "securerandom"

    senha = "Teste@123456"

    # Gera CPF válido (11 dígitos) para passar validação do model Transportador
    gerar_cpf = lambda do
      base = Array.new(9) { rand(0..9) }
      soma1 = base.each_with_index.sum { |d, i| d * (10 - i) }
      d1 = soma1 % 11
      d1 = d1 < 2 ? 0 : 11 - d1
      base2 = base + [d1]
      soma2 = base2.each_with_index.sum { |d, i| d * (11 - i) }
      d2 = soma2 % 11
      d2 = d2 < 2 ? 0 : 11 - d2
      (base2 + [d2]).join
    end

    cpf_unico = nil
    30.times do
      cand = gerar_cpf.call
      next if Transportador.exists?(documento: cand)
      cpf_unico = cand
      break
    end
    raise "Não consegui gerar CPF único para smoke test" if cpf_unico.blank?

    chave_pix_unica = nil
    30.times do
      cand = "smoke_#{SecureRandom.hex(10)}"
      next if Transportador.exists?(chave_pix: cand)
      chave_pix_unica = cand
      break
    end
    raise "Não consegui gerar chave_pix única para smoke test" if chave_pix_unica.blank?

    cliente = Cliente.find_or_initialize_by(email: "cliente.teste@cargaclick.com")
    if cliente.new_record?
      cliente.nome = "Cliente Teste"
      cliente.password = senha if cliente.respond_to?(:password=)
      cliente.password_confirmation = senha if cliente.respond_to?(:password_confirmation=)
      cliente.telefone = "15999990000" if cliente.respond_to?(:telefone=)
      cliente.cep = "18000-000" if cliente.respond_to?(:cep=)
      cliente.save!
      puts "Cliente criado: #{cliente.email}"
    else
      puts "Cliente OK: #{cliente.email}"
    end

    transportador = Transportador.find_or_initialize_by(email: "transportador.teste@cargaclick.com")
    if transportador.new_record?
      transportador.nome = "Transportador Teste"
      transportador.password = senha
      transportador.password_confirmation = senha

      transportador.cidade = "Sorocaba" if transportador.respond_to?(:cidade=)
      transportador.tipo_documento = "CPF" if transportador.respond_to?(:tipo_documento=)
      transportador.documento = cpf_unico if transportador.respond_to?(:documento=)

      transportador.tipo_veiculo = "Carro" if transportador.respond_to?(:tipo_veiculo=)
      transportador.carga_maxima = 500 if transportador.respond_to?(:carga_maxima=)
      transportador.valor_km = 2.50 if transportador.respond_to?(:valor_km=)
      transportador.chave_pix = chave_pix_unica if transportador.respond_to?(:chave_pix=)
      transportador.status = "ativo" if transportador.respond_to?(:status=)

      # Confirmable (se existir)
      if transportador.respond_to?(:confirmed_at=) && transportador.confirmed_at.blank?
        transportador.confirmed_at = Time.current
      end

      transportador.save!
      puts "Transportador criado: #{transportador.email} (CPF=#{cpf_unico})"
    else
      # garante confirmação em dev/test
      if transportador.respond_to?(:confirmed_at=) && transportador.confirmed_at.blank?
        transportador.update!(confirmed_at: Time.current)
      end

      # garante campos obrigatórios (se alguém editou manualmente e ficou inválido)
      updates = {}
      updates[:cidade] = "Sorocaba" if transportador.respond_to?(:cidade) && transportador.cidade.blank?
      updates[:tipo_documento] = "CPF" if transportador.respond_to?(:tipo_documento) && transportador.tipo_documento.blank?
      updates[:documento] = cpf_unico if transportador.respond_to?(:documento) && transportador.documento.blank?
      updates[:chave_pix] = chave_pix_unica if transportador.respond_to?(:chave_pix) && transportador.chave_pix.blank?
      transportador.update!(updates) if updates.any?

      puts "Transportador OK: #{transportador.email}"
    end

    # Cria frete "mínimo" (usa colunas reais e aliases do model)
    frete = Frete.create!(
      cliente: cliente,
      origem: "18000-000",
      destino: "01000-000",
      peso_aproximado: 10,
      valor_estimado: 200,
      status: "pendente"
    )
    puts "Frete criado: ##{frete.id} (#{frete.origem} -> #{frete.destino})"

    cotacao = Cotacao.create!(
      frete: frete,
      transportador: transportador,
      valor: 220
    )
    puts "Cotação criada: ##{cotacao.id} valor=#{cotacao.valor}"

    # Simula aceite
    frete.update!(transportador: transportador, status: "aceito", valor_final: cotacao.valor)

    taxa = if defined?(Taxas::Calculadora)
             Taxas::Calculadora.taxa_para(transportador)
           else
             BigDecimal("0.06")
           end

    pagamento = Pagamento.create!(
      frete: frete,
      transportador: transportador,
      cliente: cliente,
      valor_total: cotacao.valor,
      taxa: taxa,
      status: "pendente"
    )
    pagamento.reload

    puts "Pagamento criado: ##{pagamento.id} total=#{pagamento.valor_total} comissao=#{pagamento.comissao_cargaclick} liquido=#{pagamento.valor_liquido}"
    puts "SMOKE OK"
  rescue => e
    puts "SMOKE FALHOU: #{e.class} - #{e.message}"
    puts e.backtrace.first(20).join("\n")
    exit 1
  end
end

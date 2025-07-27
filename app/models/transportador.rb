class Transportador < ApplicationRecord
  # Define o nome da tabela no banco de dados.
  self.table_name = "transportadores"

  # Associações:
  has_many :fretes
  # A associação `modal_transportadores` é a tabela de junção.
  # `dependent: :destroy` garante que os registros da tabela de junção sejam excluídos
  # quando o transportador for excluído.
  has_many :modal_transportadores, dependent: :destroy
  # A associação `modals` é a forma principal de interagir com os modais de transporte.
  has_many :modals, through: :modal_transportadores

  # REMOVIDO: accepts_nested_attributes_for :modal_transportadores, allow_destroy: true
  # Não é mais necessário, pois o formulário agora envia `modal_ids` diretamente.

  # REMOVIDO: Atributos virtuais 'modais' (Getter e Setter) e sua dependência de 'tipo_veiculo'.
  # Se a coluna 'tipo_veiculo' no banco de dados era usada APENAS para isso,
  # você pode considerá-la redundante e removê-la com uma migração.

  # --- Validações de Dados ---
  # Validações essenciais para a integridade e qualidade dos dados.

  # Nome: Obrigatório, com tamanho entre 3 e 100 caracteres.
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }

  # CPF:
  # 1. Obrigatório e deve ser único.
  # 2. Formato básico de 11 dígitos numéricos.
  # 3. Validação de lógica de CPF (dígitos verificadores).
  validates :cpf, presence: true, uniqueness: true, format: { with: /\A\d{11}\z/, message: "deve conter exatamente 11 dígitos numéricos." }
  validate :cpf_valido # Chama o método de validação customizado para a lógica do CPF.

  # Telefone: Obrigatório, com 10 ou 11 dígitos numéricos.
  validates :telefone, presence: true, format: { with: /\A\d{10,11}\z/, message: "deve conter 10 ou 11 dígitos numéricos." }

  # Endereço: Obrigatório.
  validates :endereco, presence: true

  # CEP: Obrigatório, aceita formato de 8 dígitos ou 5-3 (com hífen).
  validates :cep, presence: true, format: { with: /\A\d{8}\z|\A\d{5}-\d{3}\z/, message: "inválido. Use o formato 12345678 ou 12345-678." }

  # Cidade: Obrigatório.
  validates :cidade, presence: true

  # Carga Máxima: Numérico e maior ou igual a zero (pode ser nulo).
  # Adicionada a opção `allow_blank: true` para lidar com campos vazios corretamente.
  validates :carga_maxima, numericality: { greater_than_or_equal_to: 0, allow_nil: true, allow_blank: true }

  private

  # Método de validação customizado para a lógica do CPF.
  def cpf_valido
    # Remove caracteres não numéricos do CPF antes da validação.
    cleaned_cpf = cpf.gsub(/\D/, '')

    # Verifica se o CPF tem 11 dígitos numéricos
    unless cleaned_cpf =~ /^\d{11}$/
      errors.add(:cpf, "deve conter exatamente 11 dígitos numéricos.")
      return
    end

    numeros = cleaned_cpf.chars.map(&:to_i)

    # Verifica CPFs com todos os dígitos iguais (considerados inválidos)
    return errors.add(:cpf, "inválido") if numeros.uniq.length == 1

    # Cálculo do primeiro dígito verificador
    soma1 = (0..8).sum { |i| numeros[i] * (10 - i) }
    resto1 = soma1 % 11
    digito1 = (resto1 < 2) ? 0 : (11 - resto1)

    # Cálculo do segundo dígito verificador
    soma2 = (0..9).sum { |i| numeros[i] * (11 - i) }
    resto2 = soma2 % 11
    digito2 = (resto2 < 2) ? 0 : (11 - resto2)

    # Compara os dígitos calculados com os dígitos do CPF fornecido
    unless digito1 == numeros[9] && digito2 == numeros[10]
      errors.add(:cpf, "inválido")
    end
  end
end

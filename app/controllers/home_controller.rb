# frozen_string_literal: true

class HomeController < ApplicationController
  # Páginas públicas — nunca exigir autenticação aqui
  skip_before_action :authenticate_cliente!, raise: false
  skip_before_action :authenticate_transportador!, raise: false

  # Landing page
  def index
  end

  # Página institucional
  def about
  end

  # Página de contato
  def contato
  end

  # Programa de fidelidade
  def fidelidade
  end

  # Relatórios públicos (se forem privados, mover depois)
  def relatorios
  end
end



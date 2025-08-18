# app/controllers/clientes/sessions_controller.rb
class Clientes::SessionsController < Devise::SessionsController
  # Configura os formatos de resposta suportados
  respond_to :html, :turbo_stream

  # Exibe o formulário de login
  def new
    super
  rescue StandardError => e
    Rails.logger.error "Erro ao carregar página de login: #{e.message}"
    redirect_to new_cliente_session_path, alert: t('devise.failure.unexpected_error')
  end

  # Processa o login
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource), notice: t('devise.sessions.signed_in') }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'devise/shared/flash_messages'),
          turbo_stream.redirect(after_sign_in_path_for(resource))
        ]
      end
    end
  rescue StandardError => e
    Rails.logger.error "Erro de autenticação: #{e.message} - #{e.backtrace.join('\n')}"
    flash.now[:alert] = t('devise.failure.invalid', authentication_keys: resource&.class&.authentication_keys&.join('/') || 'email')
    respond_to do |format|
      format.html { render :new }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'devise/shared/flash_messages'),
          turbo_stream.replace('session_form', partial: 'devise/sessions/new')
        ]
      end
    end
  end

  # Processa o logout
  def destroy
    signed_out = Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    respond_to do |format|
      format.html { redirect_to after_sign_out_path_for(resource_name), notice: t('devise.sessions.signed_out') }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('flash', partial: 'devise/shared/flash_messages'),
          turbo_stream.redirect(after_sign_out_path_for(resource_name))
        ]
      end
    end
  end

  protected

  # Configura opções de autenticação
  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  private

  # Garante que as traduções estejam disponíveis
  def t(key, options = {})
    I18n.t(key, **options.merge(scope: 'devise'))
  rescue I18n::MissingTranslationData
    Rails.logger.warn "Tradução ausente para: #{key}"
    key.to_s.humanize
  end
end
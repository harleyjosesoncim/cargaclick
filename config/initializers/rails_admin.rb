# frozen_string_literal: true
# Só configura se a gem estiver carregada (seguro no precompile/build).
if defined?(RailsAdmin)
  RailsAdmin.config do |config|
    # Use Sprockets só se existir (não quebra setups sem sprockets-rails)
    config.asset_source = :sprockets if defined?(Sprockets) && Rails.application.config.respond_to?(:assets)

    # Ações padrão
    config.actions do
      dashboard
      index
      new
      export
      bulk_delete
      show
      edit
      delete
      show_in_app
    end
  end
end

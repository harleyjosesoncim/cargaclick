class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.com.br")
  layout "mailer"
end

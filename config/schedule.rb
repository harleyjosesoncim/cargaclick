# config/schedule.rb
# Log das execuções do cron (opcional)
set :output, "log/cron.log"

# Ambiente do Rails
set :environment, ENV.fetch("RAILS_ENV", "production")

# Garante que o cron veja o Ruby/Bundler/Node do seu PATH atual
env :PATH, ENV["PATH"]

# IMPORTANTE: cron roda no fuso do servidor (geralmente UTC).
# America/Sao_Paulo (UTC-3) -> ajuste o horário se necessário.

# 1) Gera o sitemap diariamente (sem ping, o Google descontinuou)
every 1.day, at: "3:00 am" do
  rake "sitemap:refresh:no_ping"
end

# 2) (Opcional) Limpa logs antigos 1x por semana
every :sunday, at: "4:00 am" do
  command "find #{path}/log -type f -name '*.log' -mtime +14 -delete"
end

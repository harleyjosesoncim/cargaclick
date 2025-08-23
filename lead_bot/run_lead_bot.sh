#!/bin/bash
# 🚀 Execução simples do Lead Bot - CargaClick (para cron)

cd "$(dirname "$0")"

# Ativar venv
source .venv/bin/activate

# Executar bot
python bot.py

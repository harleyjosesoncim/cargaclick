#!/bin/bash
# 🚀 Setup e execução do Lead Bot - CargaClick

cd "$(dirname "$0")"

echo "=== Ativando ambiente virtual ==="
if [ ! -d ".venv" ]; then
  echo "Criando venv..."
  python3 -m venv .venv
fi

source .venv/bin/activate

echo "=== Instalando dependências ==="
pip install -r requirements.txt

echo "=== Executando o Lead Bot ==="
python bot.py

#!/bin/bash

# Nome do ZIP com data
NOME_ZIP="CargaClick_TOP5_INPUT_$(date +%Y%m%d_%H%M%S).zip"

# Caminho para salvar
DESTINO="$HOME/Downloads/$NOME_ZIP"

# Caminho do projeto atual (ajuste se necessário)
PROJETO_DIR="$HOME/projects/Cargaclick"

# Criar o zip ignorando pastas pesadas e desnecessárias
cd "$PROJETO_DIR" || exit

zip -r "$DESTINO" . \
  -x "node_modules/*" \
  -x "log/*" \
  -x "tmp/*" \
  -x "storage/*" \
  -x "*.log" \
  -x ".git/*" \
  -x "*.DS_Store" \
  -x "coverage/*" \
  -x "public/assets/*" \
  -x "vendor/*" \
  -x "*.sqlite3"

echo "✅ ZIP gerado em: $DESTINO"

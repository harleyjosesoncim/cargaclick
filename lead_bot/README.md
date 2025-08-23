# 🤖 Lead Bot - CargaClick

Robô AI que identifica potenciais clientes e transportadores (ex.: OLX, classificados) e os convida para usar o CargaClick.

## Como rodar

### 1. Criar e ativar ambiente virtual (recomendado)
```bash
cd lead_bot

# criar ambiente virtual isolado
python3 -m venv .venv

# ativar (Linux/WSL)
source .venv/bin/activate

# ativar (Windows PowerShell)
.venv\Scripts\Activate.ps1
```

### 2. Instalar dependências
```bash
pip install -r requirements.txt
```

### 3. Executar o robô
```bash
python bot.py
```

Para sair do ambiente virtual:
```bash
deactivate
```

## Integração
- Salva leads na tabela `leads` do PostgreSQL do CargaClick.
- Dispara convite automático (hoje apenas `print`, mas pode ser Twilio/SendGrid).

## Automação
Agendar execução 2x ao dia (Linux/WSL):
```bash
crontab -e
```
Adicionar:
```
0 9,18 * * * cd /app/lead_bot && /usr/bin/python3 bot.py >> /var/log/lead_bot.log 2>&1
```

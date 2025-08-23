# 🤖 Lead Bot Marketing - CargaClick

Este pacote expande o Lead Bot para suportar **envios reais** via E-mail (SendGrid) e WhatsApp (Twilio).

## 🔹 Como usar

1. Copie `.env.example` para `.env` e preencha as chaves reais.
2. Rode a migration para adicionar o campo `canal` em `leads`:
   ```bash
   bin/rails db:migrate
   ```
3. Execute o bot normalmente:
   ```bash
   cd lead_bot
   source .venv/bin/activate
   python bot.py
   ```

- Sem API keys → Modo **mock** (simulado).
- Com `SENDGRID_API_KEY` → Envia **E-mails reais**.
- Com `TWILIO_SID` + `TWILIO_TOKEN` + `TWILIO_WHATSAPP_NUMBER` → Envia **WhatsApp real**.

## 🔹 Migration

Cria a coluna `canal` na tabela leads para indicar origem do envio (mock, email, whatsapp).

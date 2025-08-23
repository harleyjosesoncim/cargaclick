import os
from datetime import datetime

# Mock atual
def send_invite(nome, contato, tipo):
    msg = f"Olá {nome}, o https://www.cargaclick.com.br "
    if tipo == "cliente":
        msg += "encontra os melhores fretes 🚚. Faça sua cotação agora!"
    else:
        msg += "tem clientes prontos aguardando transportadores como você. Cadastre-se!"

    print(f"[ENVIADO] Para: {contato} -> {msg}")

# Integração SendGrid
def send_email(to, subject, body):
    import sendgrid
    from sendgrid.helpers.mail import Mail
    api_key = os.getenv("SENDGRID_API_KEY")
    if not api_key:
        print("[MOCK] SendGrid não configurado, envio simulado.")
        return
    sg = sendgrid.SendGridAPIClient(api_key=api_key)
    mail = Mail(
        from_email="contato@cargaclick.com.br",
        to_emails=to,
        subject=subject,
        plain_text_content=body
    )
    response = sg.send(mail)
    print(f"[EMAIL] Para {to} -> Status {response.status_code}")

# Integração Twilio WhatsApp
def send_whatsapp(to, body):
    from twilio.rest import Client
    sid = os.getenv("TWILIO_SID")
    token = os.getenv("TWILIO_TOKEN")
    number = os.getenv("TWILIO_WHATSAPP_NUMBER")
    if not sid or not token or not number:
        print("[MOCK] Twilio não configurado, envio simulado.")
        return
    client = Client(sid, token)
    message = client.messages.create(
        from_=f"whatsapp:{number}",
        body=body,
        to=f"whatsapp:{to}"
    )
    print(f"[WHATSAPP] Para {to} -> SID {message.sid}")

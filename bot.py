import discord
import requests
import os

TOKEN = os.getenv("DISCORD_BOT_TOKEN")
API_URL = "http://localhost:3001/api/transportadores/optin"

intents = discord.Intents.default()
intents.message_content = True
bot = discord.Client(intents=intents)

estado = {}

@bot.event
async def on_ready():
    print(f"Bot conectado como {bot.user}")

@bot.event
async def on_message(message):
    if message.author.bot:
        return

    uid = message.author.id
    txt = message.content.strip().lower()

    if txt == "!quero-trabalhar":
        estado[uid] = {"step": 1}
        await message.channel.send("Qual seu nome completo?")
        return

    if uid not in estado:
        return

    step = estado[uid]["step"]

    if step == 1:
        estado[uid]["nome"] = message.content
        estado[uid]["step"] = 2
        await message.channel.send("Qual sua cidade?")
    elif step == 2:
        estado[uid]["cidade"] = message.content
        estado[uid]["step"] = 3
        await message.channel.send("Qual tipo de veículo? (moto / van / caminhão)")
    elif step == 3:
        estado[uid]["tipo_veiculo"] = message.content
        estado[uid]["step"] = 4
        await message.channel.send("Você autoriza o uso dos dados para cadastro no CargaClick? (sim/não)")
    elif step == 4:
        if message.content.lower() != "sim":
            await message.channel.send("Cadastro cancelado.")
            estado.pop(uid)
            return

        payload = {
            "nome": estado[uid]["nome"],
            "cidade": estado[uid]["cidade"],
            "tipo_veiculo": estado[uid]["tipo_veiculo"],
            "telefone": f"discord:{uid}",
            "origem": "discord",
            "consentimento": "sim"
        }

        try:
            r = requests.post(API_URL, data=payload, timeout=5)
            if r.status_code == 201:
                await message.channel.send("✅ Cadastro realizado com sucesso!")
            else:
                await message.channel.send("⚠️ Erro ao cadastrar. Tente depois.")
        except Exception as e:
            await message.channel.send("❌ Erro de conexão com o servidor.")

        estado.pop(uid)

bot.run(TOKEN)

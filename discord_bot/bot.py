import discord
from discord.ext import commands

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.command()
async def cadastrar(ctx):
    await ctx.send(
        "🚚 Cadastre-se no CargaClick\n"
        "👉 https://cargaclick.com.br/transportadores/cadastro"
    )

bot.run("SEU_TOKEN_DISCORD")

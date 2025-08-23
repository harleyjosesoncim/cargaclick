from scraper import scrape_clients
from transporters import scrape_transporters
from notifier import send_invite

def run_bot():
    clientes = scrape_clients()
    for c in clientes:
        send_invite(c["nome"], c["contato"], "cliente")

    transporters = scrape_transporters()
    for t in transporters:
        send_invite(t["nome"], t["contato"], "transportador")

if __name__ == "__main__":
    run_bot()

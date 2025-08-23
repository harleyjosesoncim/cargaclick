from database import save_lead

def scrape_transporters():
    transporters = [
        {"nome": "João Caminhoneiro", "contato": "11-99999-9999", "origem": "SP", "destino": "BR", "detalhes": "Truck 3/4 disponível"}
    ]
    for t in transporters:
        save_lead("transportador", t["nome"], t["contato"], t["origem"], t["destino"], t["detalhes"])
    return transporters

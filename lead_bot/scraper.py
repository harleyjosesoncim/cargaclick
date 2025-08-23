from database import save_lead

def scrape_clients():
    # Mock de scraping — substituir por OLX, etc.
    leads = [
        {"nome": "Carlos", "contato": "carlos@email.com", "origem": "Sorocaba", "destino": "SP", "detalhes": "Procuro frete para mudança"}
    ]
    for c in leads:
        save_lead("cliente", c["nome"], c["contato"], c["origem"], c["destino"], c["detalhes"])
    return leads

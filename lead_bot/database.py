from sqlalchemy import create_engine, text
from config import DATABASE_URL

engine = create_engine(DATABASE_URL)

def save_lead(tipo, nome, contato, origem, destino, detalhes):
    with engine.begin() as conn:
        conn.execute(
            text("""
                INSERT INTO leads (tipo, nome, contato, origem, destino, detalhes, created_at, updated_at)
                VALUES (:tipo, :nome, :contato, :origem, :destino, :detalhes, NOW(), NOW())
            """),
            {"tipo": tipo, "nome": nome, "contato": contato, "origem": origem, "destino": destino, "detalhes": detalhes}
        )

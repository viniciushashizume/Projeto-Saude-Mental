from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import random # Simulando o ML

app = FastAPI()

# Modelo de dados que virá do App
class DiarioEntrada(BaseModel):
    user_id: str
    humor_score: int  # 1 a 5
    texto_diario: Optional[str] = None
    tags: list[str] = []

# --- Simulação do seu Modelo de ML ---
def analisar_risco_ml(texto: str, humor: int):
    # AQUI entraria seu: model.predict([texto])
    # Exemplo lógico: Se humor baixo e texto contém palavras chave
    score_risco = 0.0
    if humor <= 2:
        score_risco += 0.4
    if texto and "triste" in texto.lower():
        score_risco += 0.3
    
    return score_risco # 0.0 a 1.0

@app.post("/registrar_diario")
async def registrar_entrada(entrada: DiarioEntrada):
    # 1. Receber dados
    print(f"Recebido de {entrada.user_id}: Humor {entrada.humor_score}")
    
    # 2. Processar pelo ML
    risco = analisar_risco_ml(entrada.texto_diario or "", entrada.humor_score)
    
    # 3. Retornar feedback e dados de gamificação
    xp_ganho = 10 if entrada.texto_diario else 5
    
    return {
        "status": "sucesso",
        "analise_ml": {
            "risco_detectado": risco,
            "mensagem": "Registro salvo com sucesso. Continue assim!"
        },
        "gamificacao": {
            "xp_ganho": xp_ganho,
            "mensagem_motivacional": "Sua planta cresceu um pouco hoje! 🌱"
        }
    }

# Para rodar: uvicorn main:app --reload --host 0.0.0.0
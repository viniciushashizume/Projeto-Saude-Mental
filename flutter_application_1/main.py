from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware # <--- Importante
from pydantic import BaseModel
import json

app = FastAPI()

# --- CONFIGURAÇÃO DO CORS (PARA O CHROME FUNCIONAR) ---
origins = ["*"] # Libera para qualquer origem (Web, Mobile, etc)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# -----------------------------------------------------

class DiarioItem(BaseModel):
    texto: str
    sono_nivel: int
    humor_oscilacao: bool

KEYWORDS_RISK = ["die", "kill", "suicide", "end", "anxious", "panic", "blood"]
KEYWORDS_NORMAL = ["good", "love", "morning", "happy", "work"]

@app.post("/analisar")
async def analisar_dados(item: DiarioItem):
    risk_score = 0
    
    texto_lower = item.texto.lower()
    for word in KEYWORDS_RISK:
        if word in texto_lower:
            risk_score += 2
            
    for word in KEYWORDS_NORMAL:
        if word in texto_lower:
            risk_score -= 1

    if item.sono_nivel < 2:
        risk_score += 2
    if item.humor_oscilacao:
        risk_score += 1

    status = "Normal"
    if risk_score > 3:
        status = "Alerta: Risco Elevado"
    elif risk_score > 0:
        status = "Atenção: Sinais de Estresse"

    return {
        "resultado": status,
        "pontos_gamificacao": 10,
        "mensagem": "Registro salvo! Planta regada com sucesso. 🌿"
    }
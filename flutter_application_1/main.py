from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import json
from datetime import datetime

app = FastAPI()

# --- Configuração CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Modelo de Dados Atualizado ---
class DiarioItem(BaseModel):
    user_id: str  # <--- NOVO CAMPO: Identificação do usuário
    texto: str
    sono_nivel: int
    humor_oscilacao: bool

# Palavras-chave (Simulação do seu ML)
KEYWORDS_RISK = ["die", "kill", "suicide", "end", "anxious", "panic", "blood"]
KEYWORDS_NORMAL = ["good", "love", "morning", "happy", "work"]

@app.post("/analisar")
async def analisar_dados(item: DiarioItem):
    # 1. Análise de Risco (ML)
    risk_score = 0
    texto_lower = item.texto.lower()
    
    for word in KEYWORDS_RISK:
        if word in texto_lower: risk_score += 2
    for word in KEYWORDS_NORMAL:
        if word in texto_lower: risk_score -= 1
    if item.sono_nivel < 2: risk_score += 2
    if item.humor_oscilacao: risk_score += 1

    status = "Normal"
    if risk_score > 3: status = "Alerta: Risco Elevado"
    elif risk_score > 0: status = "Atenção: Sinais de Estresse"

    # 2. SALVAR NO ARQUIVO (A parte nova)
    # Cria a pasta 'banco_de_dados' se não existir
    if not os.path.exists('banco_de_dados'):
        os.makedirs('banco_de_dados')

    # Define o nome do arquivo baseado no usuário (ex: diario_joao.json)
    nome_arquivo = f"banco_de_dados/diario_{item.user_id.lower()}.json"
    
    # Cria o dicionário do registro atual com data e hora
    novo_registro = {
        "data": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "texto": item.texto,
        "sono": item.sono_nivel,
        "resultado_ml": status,
        "risk_score": risk_score
    }

    # Lógica de Leitura e Escrita
    registros_antigos = []
    if os.path.exists(nome_arquivo):
        with open(nome_arquivo, "r", encoding="utf-8") as f:
            try:
                registros_antigos = json.load(f)
            except json.JSONDecodeError:
                registros_antigos = [] # Se der erro, começa lista vazia

    registros_antigos.append(novo_registro)

    with open(nome_arquivo, "w", encoding="utf-8") as f:
        json.dump(registros_antigos, f, indent=4, ensure_ascii=False)

    return {
        "resultado": status,
        "pontos_gamificacao": 10,
        "mensagem": f"Salvo no diário de {item.user_id}!"
    }
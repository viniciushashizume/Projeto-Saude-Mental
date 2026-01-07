# backend/ml_model.py
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
import joblib

# 1. Simulação de dados baseados no seu projeto (NLP)
# No projeto real, você carregaria seu csv 'mental_health_dataset.csv'
data = {
    'text': [
        'I feel happy and good today morning', 'I love my job', 'good morning world', # Normal
        'I want to kill myself', 'I feel depressed and sad', 'ending my life',      # Suicidal/Depression
        'I am anxious about work', 'stress is killing me', 'panic attack'           # Stress/Anxiety
    ],
    'label': ['Normal', 'Normal', 'Normal', 'Risk', 'Risk', 'Risk', 'Stress', 'Stress', 'Stress']
}
df = pd.read_csv('mental_health_dataset.csv') # Se tiver o arquivo real, use-o
# Para o exemplo funcionar sem o arquivo, usaremos o dicionário acima:
df = pd.DataFrame(data)

# 2. Pipeline de Treinamento (TF-IDF + Regressão Logística)
# Semelhante ao usado no seu notebook "Projeto Final - AM"
model = make_pipeline(
    TfidfVectorizer(),
    LogisticRegression()
)

model.fit(df['text'], df['label'])

# 3. Salvar o modelo treinado
joblib.dump(model, 'mental_health_model.pkl')
print("Modelo treinado e salvo com sucesso!")
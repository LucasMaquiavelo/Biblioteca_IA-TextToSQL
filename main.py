import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Importamos la función real conectada a Groq desde agent.py
from agent import pregunta_a_sql

def ejecutar_agente(pregunta_usuario: str):
    """
    Orquesta el flujo: recibe la pregunta, llama al agente (agent.py) 
    para generar el SQL, ejecuta en MySQL usando SQLAlchemy y muestra los datos.
    """
    # 1. Cargamos las credenciales desde el .env
    load_dotenv()
    
    # 2. Generamos el SQL puro llamando a nuestro archivo agent.py
    sql_generado = pregunta_a_sql(pregunta_usuario)
    
    print("\n" + "="*60)
    print(f"❓ Pregunta del usuario: {pregunta_usuario}")
    print(f"💻 SQL Generado por el Agente:\n{sql_generado}")
    print("="*60)
    
    if sql_generado.startswith("--"):
        print(sql_generado)
        return

    # 3. Armamos el motor de conexión con SQLAlchemy para evitar los warnings de Pandas
    usuario = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "3306")
    db_name = os.getenv("DB_NAME")
    
    try:
        engine = create_engine(f"mysql+mysqlconnector://{usuario}:{password}@{host}:{port}/{db_name}")
        
        # 4. Ejecutamos el SQL y lo cargamos en un DataFrame de Pandas
        df = pd.read_sql(sql_generado, engine)
        
        print("\n📊 Resultados obtenidos de la base de datos:")
        if df.empty:
            print("No se encontraron registros en el sistema.")
        else:
            # to_string() hace que en la consola se vea como una hermosa tablita
            print(df.to_string(index=False))
            
    except Exception as e:
        print(f"❌ Error al conectar o ejecutar en MySQL: {e}")

# --- BLOQUE DE EJECUCIÓN DIRECTA DESDE TERMINAL ---
if __name__ == "__main__":
    # Una prueba rápida para cuando ejecutes: 'python main.py'
    consulta_prueba = "¿Cuáles son los títulos de los libros que tenemos en la biblioteca?"
    ejecutar_agente(consulta_prueba)
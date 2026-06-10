import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from groq import Groq

# Importamos la función real conectada a Groq desde agent.py para la opción 1
from agent import pregunta_a_sql

# 1. Cargamos las credenciales globales desde el .env al iniciar el sistema
load_dotenv()

# Inicializamos el cliente de Groq para las recomendaciones de la opción 2
API_KEY_GROQ = os.getenv("API_KEY_GROQ")
client = Groq(api_key=API_KEY_GROQ)

def obtener_motor_db():
    """Helper para construir el motor de SQLAlchemy usando tus variables de entorno."""
    usuario = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "3306")
    db_name = os.getenv("DB_NAME")
    return create_engine(f"mysql+mysqlconnector://{usuario}:{password}@{host}:{port}/{db_name}")

def ejecutar_agente(pregunta_usuario: str):
    """Tu función original: Orquesta el flujo de traducción Text-to-SQL y muestra la tabla."""
    sql_generado = pregunta_a_sql(pregunta_usuario)
    
    print("\n" + "="*60)
    print(f"❓ Pregunta del usuario: {pregunta_usuario}")
    print(f"💻 SQL Generado por el Agente:\n{sql_generado}")
    print("="*60)
    
    if sql_generado.startswith("--"):
        print(sql_generado)
        return
    
    try:
        engine = obtener_motor_db()
        df = pd.read_sql(sql_generado, engine)
        
        print("\n📊 Resultados obtenidos de la base de datos:")
        if df.empty:
            print("No se encontraron registros en el sistema.")
        else:
            print(df.to_string(index=False))
            
    except Exception as e:
        print(f"❌ Error al conectar o ejecutar en MySQL: {e}")

# =====================================================================
# 🧠 LÓGICA INTERNA DEL COMPONENTE DE RECOMENDACIONES (PUNTOS 12 AL 15)
# =====================================================================

def buscar_socio_por_id_o_dni(valor_busqueda: int):
    """
    Busca un socio en la base de datos ya sea por su ID o por su DNI.
    Devuelve una tupla (id_socio, nombre) o None si no existe.
    """
    engine = obtener_motor_db()
    with engine.connect() as conn:
        query = text("""
            SELECT id_socio, nombre 
            FROM socio 
            WHERE id_socio = :valor OR dni = :valor
            LIMIT 1;
        """)
        result = conn.execute(query, {"valor": valor_busqueda}).fetchone()
        return result if result else None

def obtener_recomendaciones_personales(id_socio: int):
    """
    Puntos 12 y 13: Extrae el contexto de lectura del socio y busca libros
    disponibles del mismo género/autor que nunca haya leído.
    """
    engine = obtener_motor_db()
    with engine.connect() as conn:
        # 12. Consultar géneros y autores que el socio ha leído previamente
        query_historial = text("""
            SELECT DISTINCT la.id_autor, lg.id_genero
            FROM prestamo p
            JOIN ejemplar e ON p.id_ejemplar = e.id_ejemplar
            LEFT JOIN libro_autor la ON e.isbn = la.isbn
            LEFT JOIN libro_genero lg ON e.isbn = lg.isbn
            WHERE p.id_socio = :id_socio
        """)
        df_historial = pd.read_sql(query_historial, conn, params={"id_socio": id_socio})
        
        if df_historial.empty:
            return None
            
        autores_leidos = [str(x) for x in df_historial['id_autor'].dropna().unique()]
        generos_leidos = [str(x) for x in df_historial['id_genero'].dropna().unique()]
        
        str_autores = ", ".join(autores_leidos) if autores_leidos else "-1"
        str_generos = ", ".join(generos_leidos) if generos_leidos else "-1"
        
        # 13. Obtener libros disponibles usando inyección limpia para el IN de MySQL
        query_sugerencias = text(f"""
            SELECT DISTINCT l.isbn, l.titulo, l.stock_disponible
            FROM libro l
            LEFT JOIN libro_autor la ON l.isbn = la.isbn
            LEFT JOIN libro_genero lg ON l.isbn = lg.isbn
            WHERE l.stock_disponible > 0
              AND (la.id_autor IN ({str_autores})
                   OR lg.id_genero IN ({str_generos}))
              AND l.isbn NOT IN (
                  SELECT DISTINCT e2.isbn 
                  FROM prestamo p2
                  JOIN ejemplar e2 ON p2.id_ejemplar = e2.id_ejemplar
                  WHERE p2.id_socio = :id_socio
              )
            LIMIT 3;
        """)
        
        df_sugeridos = pd.read_sql(query_sugerencias, conn, params={"id_socio": id_socio})
        return df_sugeridos

def generar_explicacion_ia(titulo_libro: str):
    """Punto 14 y 15: Envía el contexto al LLM omitiendo nombres propios de forma fluida."""
    prompt = f"""
    Eres el sistema de recomendación inteligente de la biblioteca de la UTN FRCU.
    Se ha seleccionado una recomendación automática del libro titulado: '{titulo_libro}'.
    Escribe una breve justificación (máximo 3 líneas) de por qué el socio debería leer este libro basándote en que comparte autores o géneros con sus lecturas anteriores (las cuales ya tiene registradas en su historial).
    
    REGLA CRUCIAL DE DISEÑO: NO uses nombres propios de personas (como 'Mia' o 'Lucas'), NO uses saludos genéricos repetitivos (como '¡Hola!' o 'Querido socio'). Dirígete al lector de manera directa, fluida, entusiasta y profesional (ejemplo: 'Te sugerimos este título ya que anteriormente has disfrutado de...').
    """
    try:
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )
        return completion.choices[0].message.content.strip()
    except Exception as e:
        return f"Te sugerimos este libro en base a tus preferencias habituales de lectura en el sistema. (Error IA: {e})"

def obtener_recomendacion_colaborativa(id_socio: int):
    """
    BONUS: Identifica socios con patrones de lectura similares (mismos géneros en el mismo período)
    y recomienda libros que esos lectores afines han leído pero el socio actual no.
    """
    engine = obtener_motor_db()
    with engine.connect() as conn:
        query_bonus = text("""
            WITH generos_propios AS (
                SELECT DISTINCT lg.id_genero, p.fecha_prestamo
                FROM prestamo p
                JOIN ejemplar e ON p.id_ejemplar = e.id_ejemplar
                JOIN libro_genero lg ON e.isbn = lg.isbn
                WHERE p.id_socio = :id_socio
            ),
            lectores_afines AS (
                SELECT DISTINCT p2.id_socio
                FROM prestamo p2
                JOIN ejemplar e2 ON p2.id_ejemplar = e2.id_ejemplar
                JOIN libro_genero lg2 ON e2.isbn = lg2.isbn
                JOIN generos_propios gp ON lg2.id_genero = gp.id_genero
                WHERE p2.id_socio <> :id_socio
                  AND p2.fecha_prestamo BETWEEN DATE_SUB(gp.fecha_prestamo, INTERVAL 3 MONTH) 
                                            AND DATE_ADD(gp.fecha_prestamo, INTERVAL 3 MONTH)
            )
            SELECT DISTINCT l.isbn, l.titulo
            FROM prestamo p3
            JOIN ejemplar e3 ON p3.id_ejemplar = e3.id_ejemplar
            JOIN libro l ON e3.isbn = l.isbn
            WHERE p3.id_socio IN (SELECT id_socio FROM lectores_afines)
              AND l.stock_disponible > 0
              AND l.isbn NOT IN (
                  SELECT DISTINCT e4.isbn 
                  FROM prestamo p4
                  JOIN ejemplar e4 ON p4.id_ejemplar = e4.id_ejemplar
                  WHERE p4.id_socio = :id_socio
              )
            LIMIT 2;
        """)
        df_bonus = pd.read_sql(query_bonus, conn, params={"id_socio": id_socio})
        return df_bonus

def menu_recomendaciones():
    """Módulo interactivo pulido para calcular recomendaciones soportando ID o DNI de forma limpia."""
    print("\n" + "="*50)
    print(" 🤖 SISTEMA DE RECOMENDACIONES INTELIGENTES (IA) ")
    print("="*50)
    
    try:
        valor_input = int(input("👉 Ingrese el ID o DNI del Socio para analizar: "))
    except ValueError:
        print("❌ Error: Debe ingresar un número válido.")
        return

    socio_info = buscar_socio_por_id_o_dni(valor_input)
    if not socio_info:
        print("❌ Error: No se encontró ningún socio en el sistema con ese ID o DNI.")
        return
        
    id_socio, nombre_socio = socio_info[0], socio_info[1]
    
    # 🌟 SALUDO ÚNICO AL INICIO DE LA SESIÓN
    print("\n" + "="*50)
    print(f"👋 ¡Hola {nombre_socio}! (Socio ID: {id_socio})")
    print("Aquí tienes tus sugerencias personalizadas para hoy:")
    print("="*50)
    
    # --- PUNTOS 12 Y 13: RECOMENDACIONES BASADAS EN PREFERENCIAS ---
    libros_sugeridos = obtener_recomendaciones_personales(id_socio)
    
    print("\n" + "-"*45)
    print(" 📚 RECOMENDACIONES PERSONALIZADAS (AUTOR/GÉNERO) ")
    print("-"*45)
    
    if isinstance(libros_sugeridos, pd.DataFrame) and not libros_sugeridos.empty:
        for idx, row in libros_sugeridos.iterrows():
            print(f"\n📘 [ Libro: {row['titulo']} | ISBN: {row['isbn']} ]")
            # Volamos el cartel de "Generando..." para que aparezca fluido
            explicacion = generar_explicacion_ia(row['titulo'])
            print(f"✨ Motivo: {explicacion}")
    else:
        print(f"ℹ️ No se registran lecturas suficientes o no quedan unidades disponibles de tus géneros favoritos.")

    # --- BONUS: RECOMENDACIÓN COLABORATIVA ---
    print("\n" + "-"*45)
    print(" 🤝 BONUS: RECOMENDACIÓN COLABORATIVA ")
    print("-"*45)
    print("🔍 Buscando títulos leídos por lectores afines en el mismo período...")
    
    libros_colaborativos = obtener_recomendacion_colaborativa(id_socio)
    
    if isinstance(libros_colaborativos, pd.DataFrame) and not libros_colaborativos.empty:
        print("") # Espacio estético
        for idx, row in libros_colaborativos.iterrows():
            print(f"⭐ Lectores con gustos similares también leyeron: '{row['titulo']}'")
            print("   👉 ¡Te sugerimos darle una oportunidad ya que no lo has leído aún!")
    else:
        print("ℹ️ No se encontraron patrones compartidos con otros lectores en este período.")
    print("\n" + "="*50 + "\n")

# =====================================================================
# 🎮 MENÚ PRINCIPAL DE CONSOLA
# =====================================================================

def main():
    while True:
        print("\n" + "="*45)
        print(" 🏛️ SISTEMA BIBLIO-IA - UTN FRCU 2026 ")
        print("="*45)
        print("1. Probar Agente Text-to-SQL (Pregunta Individual)")
        print("2. Ejecutar Módulo de Recomendaciones e IA (Socio)")
        print("3. Salir")
        print("="*45)
        
        opcion = input("Seleccione una opción: ").strip()
        
        if opcion == "1":
            pregunta = input("\n❓ Ingrese su pregunta en lenguaje natural: ")
            ejecutar_agente(pregunta)
            
        elif opcion == "2":
            menu_recomendaciones()
            
        elif opcion == "3":
            print("\n👋 ¡Gracias por usar Biblio-IA! Cerrando sistema...")
            break
        else:
            print("❌ Opción inválida. Intente de nuevo.\n")

if __name__ == "__main__":
    main()
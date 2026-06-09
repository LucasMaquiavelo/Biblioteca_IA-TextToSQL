import os

OPENAI_KEY = os.getenv("OPENAI_API_KEY")
USE_OPENAI = OPENAI_KEY is not None

try:
    import openai
except ImportError:
    openai = None
    USE_OPENAI = False

if USE_OPENAI and openai is not None:
    openai.api_key = OPENAI_KEY

SCHEMA_DESCRIPTION = """
Tablas disponibles:
- libros(id, titulo, autor, genero, año_publicacion)
- prestamos(id, libro_id, usuario, fecha_prestamo, fecha_devolucion)
"""

PROMPT_TEMPLATE = """
Eres un generador de consultas SQL para una base de datos de biblioteca.
Devuelve únicamente una consulta SQL válida de tipo SELECT.
No incluyas explicaciones, solo la consulta SQL final.
Si la pregunta no puede traducirse a SQL, devuelve una consulta SELECT que no da resultados.
{schema}

Pregunta: "{pregunta}"
"""


def _normalize_sql(sql: str) -> str:
    text = sql.strip()
    if text.startswith("```") and text.endswith("```"):
        text = text[3:-3].strip()
    if "```" in text:
        parts = text.split("```")
        if len(parts) > 1:
            text = parts[1].strip()
    return text


def pregunta_a_sql(pregunta: str) -> str:
    pregunta = pregunta.strip()

    if USE_OPENAI and openai is not None:
        prompt = PROMPT_TEMPLATE.format(schema=SCHEMA_DESCRIPTION, pregunta=pregunta)
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}],
            temperature=0,
            max_tokens=300,
        )
        sql = _normalize_sql(response.choices[0].message.content)
        return sql

    # Fallback simple rule-based generator
    lower = pregunta.lower()
    if "cien años de soledad" in lower:
        return "SELECT * FROM libros WHERE titulo = 'Cien años de soledad';"
    if "gabriel garcía márquez" in lower or "garcía márquez" in lower:
        return "SELECT * FROM libros WHERE autor = 'Gabriel García Márquez';"
    if "libros" in lower and "misterio" in lower:
        return "SELECT * FROM libros WHERE genero = 'Misterio';"
    if "prestamos" in lower or "prestado" in lower:
        return "SELECT prestamos.*, libros.titulo FROM prestamos JOIN libros ON prestamos.libro_id = libros.id;"
    if "usuarios" in lower or "persona" in lower:
        return "SELECT * FROM prestamos;"

    return "SELECT * FROM libros LIMIT 10;"

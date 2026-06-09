import os
from dotenv import load_dotenv
from groq import Groq

load_dotenv()

API_KEY_GROQ = os.getenv("API_KEY_GROQ")
client = Groq(api_key=API_KEY_GROQ)

PROMPT_SISTEMA = """
Eres un asistente experto en bases de datos relacionales de MySQL. 
Tu única tarea es traducir preguntas en lenguaje natural (español) a consultas SQL válidas basadas exclusivamente en este esquema:

Tablas del sistema:
- autor (id_autor, nombre, apellido, nacionalidad)
- genero (id_genero, nombre, descripcion)
- libro (isbn, titulo, anio_publicacion, stock_total, stock_disponible)
- libro_autor (isbn, id_autor)
- libro_genero (isbn, id_genero)
- ejemplar (id_ejemplar, isbn, nro_ejemplar, estado_fisico)
- socio (id_socio, dni, nombre, apellido, email, fecha_alta, estado)
- prestamo (id_prestamo, id_socio, id_ejemplar, fecha_prestamo, fecha_vencimiento, fecha_devolucion, estado)
- sancion (id_sancion, id_socio, tipo, fecha_inicio, fecha_fin, motivo)

Reglas de Negocio Cruciales:
1. Para saber si un préstamo está vencido, debes consultar la tabla `prestamo` filtrando por `estado = 'VENCIDO'`. NO uses la tabla sancion para esto a menos que se pida explícitamente.
2. Si se piden datos de los socios, une `socio` con `prestamo` usando `id_socio`.
3. Los únicos valores posibles para la columna `estado` en la tabla `socio` son 'ACTIVO' o 'SUSPENDIDO'. Si te piden socios suspendidos, usa exactamente 'SUSPENDIDO'.
4. Responde ÚNICAMENTE con la consulta SQL pura. NO uses bloques de código Markdown (```sql), ni agregues texto extra. Solo el texto del SELECT.
5. Si te piden libros con préstamos simultáneos o solapados en el tiempo, debes hacer un Autocruce (Self-Join) de la tabla `prestamo` (p1 y p2) cruzando con sus respectivos ejemplares (e1 y e2) para igualar el ISBN del libro (e1.isbn = e2.isbn) y asegurar que sean ejemplares diferentes (p1.id_ejemplar <> p2.id_ejemplar). Para resolver esto NO uses bajo ningún concepto cláusulas `GROUP BY` ni `HAVING`, utiliza simplemente `SELECT DISTINCT e1.id_ejemplar, l.titulo` para evitar conflictos con el modo ONLY_FULL_GROUP_BY de MySQL. La condición temporal estricta de simultaneidad es: (p1.fecha_prestamo <= p2.fecha_devolucion AND p1.fecha_devolucion >= p2.fecha_prestamo).
"""

def pregunta_a_sql(pregunta_usuario: str) -> str:
    try:
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": PROMPT_SISTEMA},
                {"role": "user", "content": pregunta_usuario}
            ],
            temperature=0.0
        )
        return completion.choices[0].message.content.strip()
    except Exception as e:
        return f"-- Error al procesar la solicitud con la IA: {e}"
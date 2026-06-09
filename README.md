# Agente Text-to-SQL - Sistema de Biblioteca Inteligente

Este proyecto implementa un agente de Inteligencia Artificial capaz de traducir preguntas en lenguaje natural (español) a consultas SQL puras, ejecutarlas de forma segura en un motor relacional MySQL y retornar los datos estructurados en tablas dinámicas.

## Arquitectura del Sistema

El núcleo del proyecto utiliza el modelo de lenguaje **Llama 3.3 70b** a través de la infraestructura de **Groq**, garantizando respuestas en milisegundos sin restricciones regionales. La integración de datos y la orquestación del agente se gestionan mediante un entorno interactivo en Jupyter Notebook.

## 📁 Estructura del Repositorio

- **`nombre.ipynb`**: Notebook de Jupyter principal con la lógica del agente, la configuración del prompt del sistema con reglas de negocio y las demostraciones interactivas.
- **`schema.sql`**: Script de definición de datos (DDL), utilizando tipos de datos idóneos (`VARCHAR` para llaves lógicas como ISBN) y restricciones de integridad relacional.
- **`requirements.txt`**: Archivo de dependencias optimizado con las librerías estrictamente necesarias para la ejecución.
- **`.env.example`**: Plantilla de configuración para las variables de entorno locales.
- **`agent.py` y `main.py`**: Scripts base con la lógica modularizada del agente.

## 🛠️ Requisitos e Instalación

1. Instala las dependencias del proyecto ejecutando en la terminal:
   ```bash
   pip install -r requirements.txt


2. Configura tus variables de entorno locales creando un archivo .env en la raíz del proyecto basándote en 
.env.ejemplo:

DB_HOST=localhost
DB_PORT=3306
DB_USER=tu_usuario_mysql
DB_PASSWORD=tu_contraseña_mysql
DB_NAME=final
API_KEY_GROQ=gsk_tu_clave_de_groq_aqui



🗄️ Base de Datos (MySQL)
Para levantar el entorno de datos de prueba (que cumple con los mínimos de la cátedra de 20 libros, 10 autores, 30 socios y 50 préstamos), sigue estos pasos en tu cliente de base de datos (DBeaver / MySQL Workbench):

Crea la base de datos con el nombre **final**.

Ejecuta el script de estructura **schema.sql** para generar las tablas con soporte ISBN alfanumérico.

Inserta el set de datos de prueba correspondiente para poblar el sistema.

💻 Ejecución y Demostración
Abre el archivo **nombre.ipynb** en tu entorno de Visual Studio Code:

Ejecuta la celda inicial de imports y declaración de la función del agente orquestador agente_responder().

Utiliza la función pasando cualquier consulta en lenguaje natural.

Ejemplos de uso validados en el Agente:
Python
# Consulta cruzada de múltiples tablas (Joins N:M)
agente_responder("¿Qué libros escribió el autor Isaac Asimov?")

# Filtro estricto por estados lógicos del negocio
agente_responder("¿Qué socios tienen préstamos vencidos actualmente? Mostrame sus nombres y apellidos")

# Funciones de agregación y agrupamiento
agente_responder("¿Cuántos libros hay de cada género en la biblioteca?")
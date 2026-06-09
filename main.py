from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from agent import pregunta_a_sql
from database import ejecutar_sql, init_db, is_select_query

app = FastAPI(title="Biblioteca AI SQL API")

class QueryRequest(BaseModel):
    question: str

@app.on_event("startup")
def startup_event():
    init_db()

@app.get("/")
def root():
    return {
        "message": "API de biblioteca lista. Envía POST /query con {question}."
    }

@app.post("/query")
def query(body: QueryRequest):
    sql = pregunta_a_sql(body.question)

    if not is_select_query(sql):
        raise HTTPException(status_code=400, detail="Solo se permiten consultas SELECT simples sin punto y coma.")

    try:
        resultados = ejecutar_sql(sql)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Error al ejecutar SQL: {exc}")

    return {"sql": sql, "result": resultados}

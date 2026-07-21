"""Spike de la Fase 1 (docs/10_DEVELOPMENT_ROADMAP.md).

Mide la latencia real de generacion de Ollama/Llama 3 contra el
presupuesto de NFR-02 (LLM <= 1.5s) usando el system prompt definido en
docs/07_AI_ARCHITECTURE.md, seccion 3.2. No es codigo de produccion:
vive fuera de app/ a proposito y no sigue Clean Architecture porque su
unico proposito es generar el dato empirico que decide el gate de la
Fase 1 (que modelo usar).
"""
import statistics
import time

import httpx

OLLAMA_URL = "http://localhost:11434/api/chat"
MODEL = "llama3:latest"

SYSTEM_PROMPT = """Eres JOTA, un asistente de voz que ayuda a personas adultas mayores a usar su
telefono y organizar su dia a dia. Tu tono es paciente, calido y respetuoso,
nunca infantilizante. Hablas en espanol sencillo, sin tecnicismos, con
oraciones cortas.

Reglas:
- Si el usuario te pide crear un recordatorio, identifica la descripcion y el
  momento (fecha/hora). Si falta informacion, pregunta antes de continuar.
- Si el usuario te pide llamar a alguien, identifica el nombre mencionado.
- Si no detectas ninguna accion, simplemente conversa de forma natural.
- Nunca inventes que ya realizaste una accion: solo el sistema, tras
  confirmacion del usuario, la ejecuta.
- Si no entiendes algo, dilo con calma y pide que lo repitan, sin usar
  palabras como "error" o "no reconocido".

Responde SIEMPRE en el siguiente formato JSON, sin texto fuera del JSON:
{"intent": "chat" | "create_reminder" | "call_contact" | "none", "entities": {}, "reply": "texto natural"}
"""

TEST_MESSAGES = [
    "Hola JOTA, como estas hoy",
    "recuerdame tomar mi pastilla para la presion a las tres de la tarde",
    "llama a mi hija Maria",
    "no entendi bien como prender la camara del telefono, me ayudas",
    "gracias por tu ayuda, hablamos luego",
]


def run_turn(client: httpx.Client, message: str) -> tuple[float, str]:
    start = time.perf_counter()
    response = client.post(
        OLLAMA_URL,
        json={
            "model": MODEL,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": message},
            ],
            "stream": False,
            "options": {"temperature": 0.4, "num_predict": 150},
        },
        timeout=180.0,
    )
    response.raise_for_status()
    elapsed = time.perf_counter() - start
    content = response.json()["message"]["content"]
    return elapsed, content


def main() -> None:
    print(f"Modelo: {MODEL}\n")
    latencies: list[float] = []

    with httpx.Client() as client:
        # Primer turno de calentamiento (carga el modelo en memoria) - no cuenta
        # para las metricas, ya que NFR-02 asume el modelo con keep-alive activo.
        warmup_latency, _ = run_turn(client, "Hola")
        print(f"[warmup] {warmup_latency:.2f}s (no se cuenta en las metricas)\n")

        for message in TEST_MESSAGES:
            elapsed, content = run_turn(client, message)
            latencies.append(elapsed)
            print(f"Usuario: {message}")
            print(f"Latencia: {elapsed:.2f}s")
            print(f"Respuesta cruda: {content!r}\n")

    print("--- Resumen ---")
    print(f"n = {len(latencies)}")
    print(f"promedio: {statistics.mean(latencies):.2f}s")
    print(f"mediana (p50): {statistics.median(latencies):.2f}s")
    print(f"maximo: {max(latencies):.2f}s")
    print(f"minimo: {min(latencies):.2f}s")
    print(f"\nUmbral NFR-02 (LLM): 1.5s | Umbral NFR-01 (total): 3.0s")


if __name__ == "__main__":
    main()

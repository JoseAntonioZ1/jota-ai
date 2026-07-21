"""Spike de la Fase 1: mide latencia de transcripcion (STT) con faster-whisper.

IMPORTANTE: el audio de prueba (sample_es.wav) se genero con una voz
sintetica de Windows (SAPI, es-MX), NO con la voz de un adulto mayor real.
Este script solo valida la latencia de computo de Whisper en este
hardware (NFR-01/NFR-02). La precision real (WER, NFR-05) contra el
publico objetivo solo se puede medir con grabaciones humanas reales en
la Fase 9 (validacion de usabilidad) o con muestras que aporte el autor.
"""
import time

from faster_whisper import WhisperModel

AUDIO_PATH = "spikes/sample_es.wav"
MODEL_SIZE = "small"


def main() -> None:
    print(f"Cargando modelo Whisper '{MODEL_SIZE}' (CPU)...")
    load_start = time.perf_counter()
    model = WhisperModel(MODEL_SIZE, device="cpu", compute_type="int8")
    load_elapsed = time.perf_counter() - load_start
    print(f"Modelo cargado en {load_elapsed:.2f}s (una sola vez al iniciar el backend)\n")

    for i in range(3):
        start = time.perf_counter()
        segments, info = model.transcribe(AUDIO_PATH, language="es")
        text = " ".join(segment.text for segment in segments)
        elapsed = time.perf_counter() - start
        print(f"[intento {i + 1}] Latencia: {elapsed:.2f}s")
        print(f"Idioma detectado: {info.language} (prob {info.language_probability:.2f})")
        print(f"Transcripcion: {text!r}\n")

    print("Umbral NFR-02 (STT): 1.0s")


if __name__ == "__main__":
    main()

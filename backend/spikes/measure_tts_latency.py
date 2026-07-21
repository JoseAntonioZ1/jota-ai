"""Spike de la Fase 1: mide latencia de sintesis de voz (TTS) con Piper."""
import time
import wave

from piper import PiperVoice

MODEL_PATH = "spikes/piper_voices/es_ES-davefx-medium.onnx"
OUTPUT_PATH = "spikes/tts_output.wav"

TEST_REPLIES = [
    "Claro, te recordare tomar tu pastilla a las tres de la tarde.",
    "Buenos dias, como estas hoy.",
    "No pude escucharte bien, puedes repetir por favor.",
]


def main() -> None:
    print("Cargando voz Piper...")
    load_start = time.perf_counter()
    voice = PiperVoice.load(MODEL_PATH)
    print(f"Modelo cargado en {time.perf_counter() - load_start:.2f}s (una sola vez al iniciar)\n")

    for text in TEST_REPLIES:
        start = time.perf_counter()
        with wave.open(OUTPUT_PATH, "wb") as wav_file:
            voice.synthesize_wav(text, wav_file)
        elapsed = time.perf_counter() - start
        print(f"Texto: {text!r}")
        print(f"Latencia: {elapsed:.2f}s\n")

    print("Umbral NFR-02 (TTS): 0.8s")


if __name__ == "__main__":
    main()

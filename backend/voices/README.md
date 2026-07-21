# Modelos de voz (Piper TTS)

Los archivos `.onnx` / `.onnx.json` de este directorio no se versionan (son binarios grandes, ver `.gitignore`). Para descargar la voz usada por el MVP (`docs/adr/0008-modelo-llm-local-para-mvp.md`):

```bash
python -m piper.download_voices --download-dir backend/voices es_ES-davefx-medium
```

La ruta resultante debe coincidir con `PIPER_VOICE_PATH` en `backend/.env` (ver `backend/.env.example`).

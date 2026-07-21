import uuid
from dataclasses import dataclass
from typing import Any

from app.exceptions import NotFoundError
from app.repositories.conversation_repository import ConversationRepository
from app.services.ai_providers.base import AIProvider, ConversationTurn, SpeechToTextProvider, TextToSpeechProvider
from app.services.prompts import SYSTEM_PROMPT_JOTA

# docs/07_AI_ARCHITECTURE.md seccion 4: ventana de contexto de sesion
# (6 turnos ~ 3 intercambios), no memoria persistente entre sesiones.
CONTEXT_WINDOW_TURNS = 6


@dataclass
class TurnResult:
    conversation_id: uuid.UUID
    reply: str
    intent: str
    entities: dict[str, Any]


@dataclass
class VoiceTurnResult(TurnResult):
    transcript: str
    audio: bytes


class ConversationService:
    def __init__(
        self,
        ai_provider: AIProvider,
        stt_provider: SpeechToTextProvider,
        tts_provider: TextToSpeechProvider,
        conversation_repo: ConversationRepository,
    ) -> None:
        self._ai_provider = ai_provider
        self._stt_provider = stt_provider
        self._tts_provider = tts_provider
        self._conversation_repo = conversation_repo

    def handle_text_turn(
        self, user_id: uuid.UUID, conversation_id: uuid.UUID | None, message: str
    ) -> TurnResult:
        conversation = self._get_or_create_conversation(user_id, conversation_id, channel="text")
        result = self._run_turn(conversation.id, message)
        return TurnResult(
            conversation_id=conversation.id,
            reply=result.reply,
            intent=result.intent,
            entities=result.entities,
        )

    def handle_voice_turn(
        self, user_id: uuid.UUID, conversation_id: uuid.UUID | None, audio: bytes
    ) -> VoiceTurnResult:
        transcript = self._stt_provider.transcribe(audio)

        if not transcript.strip():
            # docs/04_USE_CASES.md UC-03, flujo alternativo 2a: no se llama
            # al LLM ni se persiste nada si no hubo habla reconocible.
            reply = "No pude escucharte bien, ¿puedes repetir?"
            conversation = self._get_or_create_conversation(user_id, conversation_id, "voice")
            return VoiceTurnResult(
                conversation_id=conversation.id,
                reply=reply,
                intent="none",
                entities={},
                transcript="",
                audio=self._tts_provider.synthesize(reply),
            )

        conversation = self._get_or_create_conversation(user_id, conversation_id, channel="voice")
        result = self._run_turn(conversation.id, transcript)
        audio_reply = self._tts_provider.synthesize(result.reply)

        return VoiceTurnResult(
            conversation_id=conversation.id,
            reply=result.reply,
            intent=result.intent,
            entities=result.entities,
            transcript=transcript,
            audio=audio_reply,
        )

    def _get_or_create_conversation(
        self, user_id: uuid.UUID, conversation_id: uuid.UUID | None, channel: str
    ):
        if conversation_id is None:
            return self._conversation_repo.create_conversation(user_id, channel)

        conversation = self._conversation_repo.get_conversation(conversation_id, user_id)
        if conversation is None:
            raise NotFoundError("No se encontro la conversacion solicitada.")
        return conversation

    def _run_turn(self, conversation_id: uuid.UUID, message: str):
        history_messages = self._conversation_repo.get_recent_messages(
            conversation_id, CONTEXT_WINDOW_TURNS
        )
        history = [ConversationTurn(role=m.role, content=m.content) for m in history_messages]

        result = self._ai_provider.generate_response(SYSTEM_PROMPT_JOTA, history, message)

        self._conversation_repo.add_message(conversation_id, role="user", content=message)
        self._conversation_repo.add_message(
            conversation_id,
            role="assistant",
            content=result.reply,
            intent=result.intent,
            entities=result.entities,
        )
        return result

/// docs/09_API_DESIGN.md seccion 4.2.
class TurnResult {
  const TurnResult({
    required this.conversationId,
    required this.reply,
    required this.intent,
    required this.entities,
  });

  final String conversationId;
  final String reply;
  final String intent;
  final Map<String, dynamic> entities;
}

class VoiceTurnResult extends TurnResult {
  const VoiceTurnResult({
    required super.conversationId,
    required super.reply,
    required super.intent,
    required super.entities,
    required this.transcript,
    required this.audioBytes,
  });

  final String transcript;
  final List<int> audioBytes;
}

abstract class ConversationRepository {
  Future<TurnResult> sendTextMessage({required String? conversationId, required String message});

  Future<VoiceTurnResult> sendVoiceMessage({
    required String? conversationId,
    required List<int> audioBytes,
  });
}

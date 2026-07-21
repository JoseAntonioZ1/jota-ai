import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<TurnResult> sendTextMessage({
    required String? conversationId,
    required String message,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/conversations/text-turn',
        data: {'conversation_id': conversationId, 'message': message},
      );
      return _turnResultFromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<VoiceTurnResult> sendVoiceMessage({
    required String? conversationId,
    required List<int> audioBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (conversationId != null) 'conversation_id': conversationId,
        'audio': MultipartFile.fromBytes(audioBytes, filename: 'audio.wav'),
      });
      final response = await _apiClient.dio.post('/conversations/voice-turn', data: formData);
      final data = response.data as Map<String, dynamic>;
      return VoiceTurnResult(
        conversationId: data['conversation_id'] as String,
        reply: data['reply'] as String,
        intent: data['intent'] as String,
        entities: Map<String, dynamic>.from(data['entities'] as Map),
        transcript: data['transcript'] as String,
        audioBytes: base64Decode(data['audio_base64'] as String),
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  TurnResult _turnResultFromJson(Map<String, dynamic> data) {
    return TurnResult(
      conversationId: data['conversation_id'] as String,
      reply: data['reply'] as String,
      intent: data['intent'] as String,
      entities: Map<String, dynamic>.from(data['entities'] as Map),
    );
  }
}

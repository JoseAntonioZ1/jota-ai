import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/action_log_entry.dart';
import '../domain/conversation_summary.dart';
import '../domain/history_message.dart';
import '../domain/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ConversationSummary>> listConversations() async {
    try {
      final response = await _apiClient.dio.get('/conversations');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items
          .map(
            (item) => _conversationFromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<List<HistoryMessage>> getConversationMessages(String conversationId) async {
    try {
      final response = await _apiClient.dio.get('/conversations/$conversationId/messages');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => _messageFromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<List<ActionLogEntry>> listActionLogs() async {
    try {
      final response = await _apiClient.dio.get('/action-logs');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => _actionLogFromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  ConversationSummary _conversationFromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String,
      channel: json['channel'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
    );
  }

  HistoryMessage _messageFromJson(Map<String, dynamic> json) {
    return HistoryMessage(
      role: json['role'] == 'assistant' ? HistoryMessageRole.assistant : HistoryMessageRole.user,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ActionLogEntry _actionLogFromJson(Map<String, dynamic> json) {
    return ActionLogEntry(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

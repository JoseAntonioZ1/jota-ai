import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../data/history_repository_impl.dart';
import '../domain/action_log_entry.dart';
import '../domain/conversation_summary.dart';
import '../domain/history_message.dart';
import '../domain/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final conversationsListProvider = FutureProvider.autoDispose<List<ConversationSummary>>((ref) {
  return ref.watch(historyRepositoryProvider).listConversations();
});

final actionLogsListProvider = FutureProvider.autoDispose<List<ActionLogEntry>>((ref) {
  return ref.watch(historyRepositoryProvider).listActionLogs();
});

final conversationMessagesProvider = FutureProvider.autoDispose
    .family<List<HistoryMessage>, String>((ref, conversationId) {
      return ref.watch(historyRepositoryProvider).getConversationMessages(conversationId);
    });

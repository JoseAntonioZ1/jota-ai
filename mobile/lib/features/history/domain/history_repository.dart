import 'action_log_entry.dart';
import 'conversation_summary.dart';
import 'history_message.dart';

/// docs/04_USE_CASES.md UC-11: vista de solo lectura, sin mutaciones.
abstract class HistoryRepository {
  Future<List<ConversationSummary>> listConversations();

  Future<List<HistoryMessage>> getConversationMessages(String conversationId);

  Future<List<ActionLogEntry>> listActionLogs();
}

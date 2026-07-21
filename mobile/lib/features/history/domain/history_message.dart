enum HistoryMessageRole { user, assistant }

class HistoryMessage {
  const HistoryMessage({required this.role, required this.content, required this.createdAt});

  final HistoryMessageRole role;
  final String content;
  final DateTime createdAt;
}

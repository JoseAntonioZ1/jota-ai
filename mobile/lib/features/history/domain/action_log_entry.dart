class ActionLogEntry {
  const ActionLogEntry({
    required this.id,
    required this.actionType,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String actionType;
  final String description;
  final DateTime createdAt;
}

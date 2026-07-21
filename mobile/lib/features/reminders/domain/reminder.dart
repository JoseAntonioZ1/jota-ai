/// docs/08_DATABASE_DESIGN.md seccion 3.3 (reminder_type, reminder_status).
enum ReminderType { medication, event, activity }

enum ReminderStatus { pending, completed, cancelled }

class Reminder {
  const Reminder({
    required this.id,
    required this.description,
    required this.reminderType,
    required this.scheduledAt,
    required this.status,
  });

  final String id;
  final String description;
  final ReminderType reminderType;
  final DateTime scheduledAt;
  final ReminderStatus status;
}

extension ReminderTypeLabel on ReminderType {
  String get apiValue => name;

  String get label => switch (this) {
    ReminderType.medication => 'Medicamento',
    ReminderType.event => 'Evento',
    ReminderType.activity => 'Actividad',
  };

  static ReminderType fromApiValue(String value) =>
      ReminderType.values.firstWhere((v) => v.name == value);
}

extension ReminderStatusLabel on ReminderStatus {
  String get apiValue => name;

  static ReminderStatus fromApiValue(String value) =>
      ReminderStatus.values.firstWhere((v) => v.name == value);
}

import 'reminder.dart';

/// docs/09_API_DESIGN.md seccion 4.3.
abstract class ReminderRepository {
  Future<List<Reminder>> listReminders();

  Future<Reminder> createReminder({
    required String description,
    required ReminderType reminderType,
    required DateTime scheduledAt,
  });

  Future<Reminder> updateReminder({
    required String id,
    String? description,
    ReminderType? reminderType,
    DateTime? scheduledAt,
    ReminderStatus? status,
  });

  Future<void> deleteReminder(String id);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/notifications/reminder_notification_service.dart';
import '../../../core/notifications/reminder_notification_service_provider.dart';
import '../data/reminder_repository_impl.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final remindersControllerProvider =
    StateNotifierProvider<RemindersController, AsyncValue<List<Reminder>>>((ref) {
      return RemindersController(
        ref.watch(reminderRepositoryProvider),
        ref.watch(reminderNotificationServiceProvider),
      );
    });

class RemindersController extends StateNotifier<AsyncValue<List<Reminder>>> {
  RemindersController(this._repository, this._notifications) : super(const AsyncValue.loading()) {
    _load();
  }

  final ReminderRepository _repository;
  final ReminderNotificationService _notifications;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.listReminders();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => _load();

  Future<Reminder> create({
    required String description,
    required ReminderType reminderType,
    required DateTime scheduledAt,
  }) async {
    final reminder = await _repository.createReminder(
      description: description,
      reminderType: reminderType,
      scheduledAt: scheduledAt,
    );
    await _notifications.scheduleForReminder(
      reminderId: reminder.id,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
    );
    await _load();
    return reminder;
  }

  Future<void> update({
    required String id,
    String? description,
    ReminderType? reminderType,
    DateTime? scheduledAt,
  }) async {
    final reminder = await _repository.updateReminder(
      id: id,
      description: description,
      reminderType: reminderType,
      scheduledAt: scheduledAt,
    );
    await _notifications.cancelForReminder(id);
    await _notifications.scheduleForReminder(
      reminderId: reminder.id,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
    );
    await _load();
  }

  Future<void> delete(String id) async {
    await _repository.deleteReminder(id);
    await _notifications.cancelForReminder(id);
    await _load();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reminder_notification_service.dart';

final reminderNotificationServiceProvider = Provider<ReminderNotificationService>((ref) {
  final service = ReminderNotificationService();
  service.initialize();
  return service;
});

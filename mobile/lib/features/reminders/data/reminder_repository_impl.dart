import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/reminder.dart';
import '../domain/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Reminder>> listReminders() async {
    try {
      final response = await _apiClient.dio.get('/reminders');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => _fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Reminder> createReminder({
    required String description,
    required ReminderType reminderType,
    required DateTime scheduledAt,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/reminders',
        data: {
          'description': description,
          'reminder_type': reminderType.apiValue,
          'scheduled_at': scheduledAt.toIso8601String(),
        },
      );
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Reminder> updateReminder({
    required String id,
    String? description,
    ReminderType? reminderType,
    DateTime? scheduledAt,
    ReminderStatus? status,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/reminders/$id',
        data: {
          if (description != null) 'description': description,
          if (reminderType != null) 'reminder_type': reminderType.apiValue,
          if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
          if (status != null) 'status': status.apiValue,
        },
      );
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      await _apiClient.dio.delete('/reminders/$id');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Reminder _fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      description: json['description'] as String,
      reminderType: ReminderTypeLabel.fromApiValue(json['reminder_type'] as String),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: ReminderStatusLabel.fromApiValue(json['status'] as String),
    );
  }
}

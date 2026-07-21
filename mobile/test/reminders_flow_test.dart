import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jota_ai/core/notifications/reminder_notification_service.dart';
import 'package:jota_ai/core/notifications/reminder_notification_service_provider.dart';
import 'package:jota_ai/features/reminders/domain/reminder.dart';
import 'package:jota_ai/features/reminders/domain/reminder_repository.dart';
import 'package:jota_ai/features/reminders/presentation/reminder_form_screen.dart';
import 'package:jota_ai/features/reminders/presentation/reminders_controller.dart';
import 'package:jota_ai/features/reminders/presentation/reminders_list_screen.dart';

class _FakeReminderRepository implements ReminderRepository {
  final List<Reminder> _items = [];
  var _nextId = 1;

  @override
  Future<List<Reminder>> listReminders() async => List.unmodifiable(_items);

  @override
  Future<Reminder> createReminder({
    required String description,
    required ReminderType reminderType,
    required DateTime scheduledAt,
  }) async {
    final reminder = Reminder(
      id: 'reminder-${_nextId++}',
      description: description,
      reminderType: reminderType,
      scheduledAt: scheduledAt,
      status: ReminderStatus.pending,
    );
    _items.add(reminder);
    return reminder;
  }

  @override
  Future<Reminder> updateReminder({
    required String id,
    String? description,
    ReminderType? reminderType,
    DateTime? scheduledAt,
    ReminderStatus? status,
  }) async {
    throw UnimplementedError('No usado en este test');
  }

  @override
  Future<void> deleteReminder(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

void main() {
  testWidgets('crear un recordatorio lo agrega a la lista tras confirmar', (
    WidgetTester tester,
  ) async {
    final fakeRepository = _FakeReminderRepository();
    final router = GoRouter(
      initialLocation: '/reminders',
      routes: [
        GoRoute(
          path: '/reminders',
          builder: (context, state) => const RemindersListScreen(),
        ),
        GoRoute(
          path: '/reminders/new',
          builder: (context, state) => const ReminderFormScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderRepositoryProvider.overrideWithValue(fakeRepository),
          // Evita que la app real de notificaciones (plugin nativo) se
          // inicialice durante el test.
          reminderNotificationServiceProvider.overrideWithValue(ReminderNotificationService()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes recordatorios. Puedes decirme "recuérdame..." '
        'o tocar "Nuevo recordatorio".'), findsOneWidget);

    await tester.tap(find.text('Nuevo recordatorio'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Tomar mi pastilla');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Paso de confirmacion (ConfirmationCard).
    expect(find.text('¿Es correcto?'), findsOneWidget);
    expect(find.textContaining('Tomar mi pastilla'), findsOneWidget);

    await tester.tap(find.text('Sí, confirmar'));
    await tester.pumpAndSettle();

    // Vuelve a la lista y muestra el recordatorio creado.
    expect(find.text('Tomar mi pastilla'), findsOneWidget);
  });
}

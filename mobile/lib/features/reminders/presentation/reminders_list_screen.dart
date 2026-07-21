import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/reminder.dart';
import 'reminders_controller.dart';

/// docs/04_USE_CASES.md UC-05.
class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: remindersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'No pude cargar tus recordatorios. Intenta de nuevo.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (reminders) {
                  if (reminders.isEmpty) {
                    return Center(
                      child: Text(
                        'Aún no tienes recordatorios. Puedes decirme "recuérdame..." '
                        'o tocar "Nuevo recordatorio".',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: reminders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.spacingBetweenTargets),
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return _ReminderTile(
                        reminder: reminder,
                        onTap: () => context.push(
                          '/reminders/${reminder.id}/edit',
                          extra: reminder,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/reminders/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo recordatorio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder, required this.onTap});

  final Reminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.description, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${reminder.reminderType.label} · ${formatReminderDateTime(reminder.scheduledAt)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, semanticLabel: 'Editar'),
            ],
          ),
        ),
      ),
    );
  }
}

String formatReminderDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.day)}/${two(dt.month)} ${two(dt.hour)}:${two(dt.minute)}';
}

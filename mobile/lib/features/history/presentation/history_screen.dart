import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/emergency_button.dart';
import '../domain/action_log_entry.dart';
import '../domain/conversation_summary.dart';
import 'history_providers.dart';

/// docs/04_USE_CASES.md UC-11. Flujo principal: conversaciones (Should).
/// Flujo alternativo 2a: acciones realizadas (Could, FR-06.2).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial'),
          actions: const [EmergencyButton()],
          bottom: const TabBar(
            tabs: [Tab(text: 'Conversaciones'), Tab(text: 'Acciones')],
          ),
        ),
        body: const TabBarView(
          children: [_ConversationsTab(), _ActionLogsTab()],
        ),
      ),
    );
  }
}

class _ConversationsTab extends ConsumerWidget {
  const _ConversationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'No pude cargar tu historial. Intenta de nuevo.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Text(
                'Aún no tienes conversaciones guardadas.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.spacingBetweenTargets),
            itemBuilder: (context, index) =>
                _ConversationTile(conversation: conversations[index]),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ConversationSummary conversation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/history/${conversation.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                conversation.channel == 'voice' ? Icons.mic : Icons.chat_bubble_outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDateTime(conversation.startedAt),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _ActionLogsTab extends ConsumerWidget {
  const _ActionLogsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(actionLogsListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'No pude cargar tus acciones. Intenta de nuevo.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Text(
                'Aún no hay acciones registradas.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.spacingBetweenTargets),
            itemBuilder: (context, index) => _ActionLogTile(entry: logs[index]),
          );
        },
      ),
    );
  }
}

class _ActionLogTile extends StatelessWidget {
  const _ActionLogTile({required this.entry});

  final ActionLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(_formatDateTime(entry.createdAt), style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

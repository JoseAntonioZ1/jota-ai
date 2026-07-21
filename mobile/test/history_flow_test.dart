import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jota_ai/features/history/domain/action_log_entry.dart';
import 'package:jota_ai/features/history/domain/conversation_summary.dart';
import 'package:jota_ai/features/history/domain/history_message.dart';
import 'package:jota_ai/features/history/domain/history_repository.dart';
import 'package:jota_ai/features/history/presentation/conversation_detail_screen.dart';
import 'package:jota_ai/features/history/presentation/history_providers.dart';
import 'package:jota_ai/features/history/presentation/history_screen.dart';

class _FakeHistoryRepository implements HistoryRepository {
  @override
  Future<List<ConversationSummary>> listConversations() async {
    return [
      ConversationSummary(
        id: 'conv-1',
        channel: 'text',
        startedAt: DateTime(2026, 7, 20, 15, 0),
      ),
    ];
  }

  @override
  Future<List<HistoryMessage>> getConversationMessages(String conversationId) async {
    return [
      HistoryMessage(
        role: HistoryMessageRole.user,
        content: 'Hola JOTA',
        createdAt: DateTime(2026, 7, 20, 15, 0),
      ),
      HistoryMessage(
        role: HistoryMessageRole.assistant,
        content: 'Hola, ¿en qué puedo ayudarte?',
        createdAt: DateTime(2026, 7, 20, 15, 0, 5),
      ),
    ];
  }

  @override
  Future<List<ActionLogEntry>> listActionLogs() async => const [];
}

void main() {
  testWidgets('tocar una conversacion muestra su contenido completo', (
    WidgetTester tester,
  ) async {
    final fakeRepository = _FakeHistoryRepository();
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
        GoRoute(
          path: '/history/:id',
          builder: (context, state) =>
              ConversationDetailScreen(conversationId: state.pathParameters['id']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyRepositoryProvider.overrideWithValue(fakeRepository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('20/07/2026 15:00'), findsOneWidget);

    await tester.tap(find.text('20/07/2026 15:00'));
    await tester.pumpAndSettle();

    expect(find.text('Hola JOTA'), findsOneWidget);
    expect(find.text('Hola, ¿en qué puedo ayudarte?'), findsOneWidget);
  });
}

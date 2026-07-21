import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jota_ai/features/conversation/domain/conversation_repository.dart';
import 'package:jota_ai/features/conversation/presentation/conversation_controller.dart';
import 'package:jota_ai/features/conversation/presentation/home_screen.dart';

class _FakeConversationRepository implements ConversationRepository {
  String? lastMessage;

  @override
  Future<TurnResult> sendTextMessage({
    required String? conversationId,
    required String message,
  }) async {
    lastMessage = message;
    return TurnResult(
      conversationId: conversationId ?? 'conv-1',
      reply: 'Hola, soy JOTA (respuesta de prueba)',
      intent: 'chat',
      entities: const {},
    );
  }

  @override
  Future<VoiceTurnResult> sendVoiceMessage({
    required String? conversationId,
    required List<int> audioBytes,
  }) async {
    throw UnimplementedError('No usado en este test');
  }
}

void main() {
  testWidgets('enviar un mensaje de texto muestra la pregunta y la respuesta', (
    WidgetTester tester,
  ) async {
    final fakeRepository = _FakeConversationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [conversationRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hola JOTA');
    await tester.tap(find.byIcon(Icons.send));
    // No se usa pumpAndSettle: AvatarWidget tiene una animacion de pulso
    // continua (deliberada, ver docs/05_UX_UI_DESIGN.md 6.1) que nunca
    // "asienta". Se hacen pumps acotados para dejar que el Future del
    // repositorio falso se resuelva.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(fakeRepository.lastMessage, 'Hola JOTA');
    expect(find.text('Hola JOTA'), findsOneWidget);
    expect(find.text('Hola, soy JOTA (respuesta de prueba)'), findsOneWidget);
  });
}

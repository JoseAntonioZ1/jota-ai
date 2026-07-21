import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jota_ai/features/contacts/domain/contact.dart';
import 'package:jota_ai/features/contacts/domain/contact_repository.dart';
import 'package:jota_ai/features/contacts/presentation/contacts_controller.dart';
import 'package:jota_ai/features/conversation/domain/conversation_repository.dart';
import 'package:jota_ai/features/conversation/presentation/conversation_controller.dart';
import 'package:jota_ai/features/conversation/presentation/home_screen.dart';

class _FakeConversationRepository implements ConversationRepository {
  @override
  Future<TurnResult> sendTextMessage({
    required String? conversationId,
    required String message,
  }) async {
    return TurnResult(
      conversationId: conversationId ?? 'conv-1',
      reply: '¿Quieres que llame a Maria?',
      intent: 'call_contact',
      entities: const {'contact_name': 'Maria'},
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

class _FakeContactRepository implements ContactRepository {
  bool loggedCall = false;

  @override
  Future<List<Contact>> listContacts() async {
    return const [
      Contact(id: 'contact-1', name: 'Maria González', phoneNumber: '+51987654321'),
    ];
  }

  @override
  Future<Contact> createContact({required String name, required String phoneNumber}) async {
    throw UnimplementedError('No usado en este test');
  }

  @override
  Future<Contact> updateContact({required String id, String? name, String? phoneNumber}) async {
    throw UnimplementedError('No usado en este test');
  }

  @override
  Future<bool> deleteContact(String id) async {
    throw UnimplementedError('No usado en este test');
  }

  @override
  Future<void> logCall(String contactId, {String callType = 'frequent'}) async {
    loggedCall = true;
  }
}

void main() {
  testWidgets('detectar "llama a Maria" muestra ConfirmationCard y registra la llamada', (
    WidgetTester tester,
  ) async {
    final fakeContacts = _FakeContactRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(_FakeConversationRepository()),
          contactRepositoryProvider.overrideWithValue(fakeContacts),
          // Sin canal de plataforma para url_launcher en los tests: se
          // sustituye el "dialer" real por uno que no hace nada.
          conversationControllerProvider.overrideWith(
            (ref) => ConversationController(
              ref.watch(conversationRepositoryProvider),
              ref.watch(contactRepositoryProvider),
              ref,
              dialer: (uri) async {},
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'llama a Maria');
    await tester.tap(find.byIcon(Icons.send));
    // Sin pumpAndSettle: ver home_screen_test.dart (animacion continua del avatar).
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('¿Llamar a Maria González?'), findsOneWidget);

    await tester.tap(find.text('Sí, llamar'));
    await tester.pump();
    await tester.pump();

    expect(fakeContacts.loggedCall, isTrue);
    expect(find.text('¿Llamar a Maria González?'), findsNothing);
  });
}

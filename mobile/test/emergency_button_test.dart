import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:jota_ai/features/contacts/domain/contact.dart';
import 'package:jota_ai/features/contacts/domain/contact_repository.dart';
import 'package:jota_ai/features/contacts/presentation/contacts_controller.dart';
import 'package:jota_ai/features/emergency/domain/emergency_repository.dart';
import 'package:jota_ai/features/emergency/presentation/emergency_providers.dart';
import 'package:jota_ai/shared/widgets/emergency_button.dart';

class _FakeEmergencyRepository implements EmergencyRepository {
  Contact? current;

  @override
  Future<Contact?> getEmergencyContact() async => current;

  @override
  Future<Contact> setEmergencyContact(String contactId) async {
    throw UnimplementedError('No usado en este test');
  }
}

class _FakeContactRepository implements ContactRepository {
  String? loggedCallType;

  @override
  Future<List<Contact>> listContacts() async => const [];

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
    loggedCallType = callType;
  }
}

Widget _buildTestApp({
  required _FakeEmergencyRepository emergencyRepo,
  required _FakeContactRepository contactRepo,
}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => Scaffold(
          appBar: AppBar(actions: [EmergencyButton(dialer: (uri) async {})]),
        ),
      ),
      GoRoute(
        path: '/settings/emergency-contact',
        builder: (context, state) => const Scaffold(body: Text('Configurar emergencia')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      emergencyRepositoryProvider.overrideWithValue(emergencyRepo),
      contactRepositoryProvider.overrideWithValue(contactRepo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('sin contacto de emergencia configurado, redirige a configurarlo', (
    WidgetTester tester,
  ) async {
    final emergencyRepo = _FakeEmergencyRepository();
    final contactRepo = _FakeContactRepository();

    await tester.pumpWidget(
      _buildTestApp(emergencyRepo: emergencyRepo, contactRepo: contactRepo),
    );

    await tester.tap(find.byIcon(Icons.emergency));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Configurar emergencia'), findsOneWidget);
  });

  testWidgets('con contacto configurado, confirma y registra la llamada de emergencia', (
    WidgetTester tester,
  ) async {
    final emergencyRepo = _FakeEmergencyRepository()
      ..current = const Contact(id: 'contact-1', name: 'José (hijo)', phoneNumber: '+51999888777');
    final contactRepo = _FakeContactRepository();

    await tester.pumpWidget(
      _buildTestApp(emergencyRepo: emergencyRepo, contactRepo: contactRepo),
    );

    await tester.tap(find.byIcon(Icons.emergency));
    await tester.pump();
    await tester.pump();

    expect(find.text('¿Llamar ahora a José (hijo)?'), findsOneWidget);

    await tester.tap(find.text('Sí, llamar'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(contactRepo.loggedCallType, 'emergency');
  });
}

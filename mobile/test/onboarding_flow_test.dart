import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jota_ai/features/onboarding/domain/onboarding_repository.dart';
import 'package:jota_ai/features/onboarding/domain/user_profile.dart';
import 'package:jota_ai/features/onboarding/presentation/onboarding_providers.dart';
import 'package:jota_ai/main.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  UserProfile? _profile;
  String? completedWithName;

  @override
  Future<UserProfile?> getExistingProfile() async => _profile;

  @override
  Future<UserProfile> registerDevice() async {
    _profile = const UserProfile(userId: 'test-user', name: null, onboardingCompleted: false);
    return _profile!;
  }

  @override
  Future<UserProfile> completeOnboarding({required String name}) async {
    completedWithName = name;
    _profile = UserProfile(userId: 'test-user', name: name, onboardingCompleted: true);
    return _profile!;
  }
}

void main() {
  testWidgets('completa el onboarding y llega a la pantalla principal', (
    WidgetTester tester,
  ) async {
    final fakeRepository = _FakeOnboardingRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const JotaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Paso 1: bienvenida.
    expect(find.text('Hola, soy JOTA'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Paso 2: permiso de microfono.
    expect(find.text('Necesito tu permiso'), findsOneWidget);
    await tester.tap(find.text('Permitir y continuar'));
    await tester.pumpAndSettle();

    // Paso 3: nombre (el boton "Continuar" empieza deshabilitado).
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    final continueButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continuar'));
    expect(continueButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Rosa');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Paso 4: nota de contacto de emergencia (pospuesto) + finalizar.
    expect(find.text('Contacto de emergencia'), findsOneWidget);
    await tester.tap(find.text('Empezar'));
    // Sin pumpAndSettle: HomeScreen incluye AvatarWidget con una animacion
    // de pulso continua que nunca "asienta" (ver home_screen_test.dart).
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(fakeRepository.completedWithName, 'Rosa');
    // Llega a /home (AppBar de HomeScreen).
    expect(find.text('JOTA'), findsOneWidget);
  });
}

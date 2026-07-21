import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jota_ai/features/onboarding/domain/onboarding_repository.dart';
import 'package:jota_ai/features/onboarding/domain/user_profile.dart';
import 'package:jota_ai/features/onboarding/presentation/onboarding_providers.dart';
import 'package:jota_ai/main.dart';

/// Repositorio en memoria: evita que el widget test dependa de un backend
/// real corriendo (docs/09_API_DESIGN.md).
class _FakeOnboardingRepository implements OnboardingRepository {
  UserProfile? _profile;

  @override
  Future<UserProfile?> getExistingProfile() async => _profile;

  @override
  Future<UserProfile> registerDevice() async {
    _profile = const UserProfile(userId: 'test-user', name: null, onboardingCompleted: false);
    return _profile!;
  }

  @override
  Future<UserProfile> completeOnboarding({required String name}) async {
    _profile = UserProfile(userId: 'test-user', name: name, onboardingCompleted: true);
    return _profile!;
  }
}

void main() {
  testWidgets('JotaApp arranca y muestra el primer paso del onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(_FakeOnboardingRepository()),
        ],
        child: const JotaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configuración inicial'), findsOneWidget);
    expect(find.text('Hola, soy JOTA'), findsOneWidget);
  });
}

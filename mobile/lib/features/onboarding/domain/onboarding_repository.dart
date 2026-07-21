import 'user_profile.dart';

/// docs/04_USE_CASES.md UC-01.
abstract class OnboardingRepository {
  /// Devuelve el perfil si ya existe un token guardado, o null si es la
  /// primera vez que se abre la app en este dispositivo.
  Future<UserProfile?> getExistingProfile();

  Future<UserProfile> registerDevice();

  Future<UserProfile> completeOnboarding({required String name});
}

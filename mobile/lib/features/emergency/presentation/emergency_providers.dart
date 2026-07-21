import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../../contacts/domain/contact.dart';
import '../data/emergency_repository_impl.dart';
import '../domain/emergency_repository.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

/// Se recarga (ref.invalidate) cada vez que se confirma un cambio, en vez
/// de mantener un StateNotifier - el contacto de emergencia cambia con
/// poca frecuencia y no necesita estado en memoria propio.
final emergencyContactProvider = FutureProvider.autoDispose<Contact?>((ref) {
  return ref.watch(emergencyRepositoryProvider).getEmergencyContact();
});

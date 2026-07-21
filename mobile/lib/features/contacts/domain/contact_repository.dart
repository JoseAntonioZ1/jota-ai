import 'contact.dart';

/// docs/09_API_DESIGN.md seccion 4.4.
abstract class ContactRepository {
  Future<List<Contact>> listContacts();

  Future<Contact> createContact({required String name, required String phoneNumber});

  Future<Contact> updateContact({required String id, String? name, String? phoneNumber});

  /// docs/09_API_DESIGN.md seccion 4.4: devuelve true si el contacto
  /// eliminado era el de emergencia vigente (la referencia ya se limpio
  /// en el backend; el llamador debe avisar y redirigir a UC-09).
  Future<bool> deleteContact(String id);

  /// UC-08: registra la llamada para el historial (Fase 7); el backend
  /// nunca inicia la llamada, solo la deja registrada.
  Future<void> logCall(String contactId, {String callType = 'frequent'});
}

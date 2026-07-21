import '../../contacts/domain/contact.dart';

/// docs/04_USE_CASES.md UC-09.
abstract class EmergencyRepository {
  Future<Contact?> getEmergencyContact();

  Future<Contact> setEmergencyContact(String contactId);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../data/contact_repository_impl.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final contactsControllerProvider =
    StateNotifierProvider<ContactsController, AsyncValue<List<Contact>>>((ref) {
      return ContactsController(ref.watch(contactRepositoryProvider));
    });

class ContactsController extends StateNotifier<AsyncValue<List<Contact>>> {
  ContactsController(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final ContactRepository _repository;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repository.listContacts();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() => _load();

  Future<void> create({required String name, required String phoneNumber}) async {
    await _repository.createContact(name: name, phoneNumber: phoneNumber);
    await _load();
  }

  Future<void> update({required String id, String? name, String? phoneNumber}) async {
    await _repository.updateContact(id: id, name: name, phoneNumber: phoneNumber);
    await _load();
  }

  Future<void> delete(String id) async {
    await _repository.deleteContact(id);
    await _load();
  }

  /// Lista actual sin recargar - usada por la conversacion (UC-08) para
  /// encontrar un contacto por nombre sin depender de un nuevo fetch.
  List<Contact> get currentContacts => state.asData?.value ?? const [];
}

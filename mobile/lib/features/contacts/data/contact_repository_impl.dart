import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<Contact>> listContacts() async {
    try {
      final response = await _apiClient.dio.get('/contacts');
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => Contact.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Contact> createContact({required String name, required String phoneNumber}) async {
    try {
      final response = await _apiClient.dio.post(
        '/contacts',
        data: {'name': name, 'phone_number': phoneNumber},
      );
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Contact> updateContact({required String id, String? name, String? phoneNumber}) async {
    try {
      final response = await _apiClient.dio.patch(
        '/contacts/$id',
        data: {
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      return Contact.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<bool> deleteContact(String id) async {
    try {
      final response = await _apiClient.dio.delete('/contacts/$id');
      final data = response.data as Map<String, dynamic>;
      return data['emergency_contact_cleared'] as bool? ?? false;
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<void> logCall(String contactId, {String callType = 'frequent'}) async {
    try {
      await _apiClient.dio.post(
        '/contacts/$contactId/call-log',
        data: {'call_type': callType},
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}

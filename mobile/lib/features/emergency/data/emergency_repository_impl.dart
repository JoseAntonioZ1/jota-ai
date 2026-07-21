import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../contacts/domain/contact.dart';
import '../domain/emergency_repository.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  EmergencyRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Contact?> getEmergencyContact() async {
    try {
      final response = await _apiClient.dio.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      final contactJson = data['emergency_contact'] as Map<String, dynamic>?;
      return contactJson == null ? null : Contact.fromJson(contactJson);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<Contact> setEmergencyContact(String contactId) async {
    try {
      final response = await _apiClient.dio.put(
        '/users/me/emergency-contact',
        data: {'contact_id': contactId},
      );
      final data = response.data as Map<String, dynamic>;
      return Contact.fromJson(data['emergency_contact'] as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}

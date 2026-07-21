import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/onboarding_repository.dart';
import '../domain/user_profile.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({required ApiClient apiClient, required TokenStorage tokenStorage})
    : _apiClient = apiClient,
      _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  @override
  Future<UserProfile?> getExistingProfile() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;

    try {
      final response = await _apiClient.dio.get('/users/me');
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<UserProfile> registerDevice() async {
    try {
      final response = await _apiClient.dio.post(
        '/devices',
        data: {'device_fingerprint': const Uuid().v4()},
      );
      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveToken(data['device_token'] as String);
      return UserProfile(
        userId: data['user_id'] as String,
        name: null,
        onboardingCompleted: data['onboarding_completed'] as bool,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  @override
  Future<UserProfile> completeOnboarding({required String name}) async {
    try {
      final response = await _apiClient.dio.patch(
        '/users/me',
        data: {'name': name, 'onboarding_completed': true},
      );
      return _fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  UserProfile _fromJson(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['user_id'] as String,
      name: map['name'] as String?,
      onboardingCompleted: map['onboarding_completed'] as bool,
    );
  }
}

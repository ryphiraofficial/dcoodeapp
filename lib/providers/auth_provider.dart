import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/services/secure_storage_service.dart';
import '../data/models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  User? _user;
  String? _role;
  bool _isLoading = false;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success']) {
        // The API returns { success: true, message: "...", data: { accessToken, ... } }
        // The LoginResponse.fromJson expects the full map
        final loginResponse = LoginResponse.fromJson(response.data);
        _user = loginResponse.user;
        _role = loginResponse.role;

        await _storage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          role: loginResponse.role,
          userId: loginResponse.user.id,
        );

        _isLoading = false;
        notifyListeners();
        debugPrint('Login successful: ${_user?.name} as $_role');
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Login Error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      debugPrint('Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _storage.clearAll();
      _user = null;
      _role = null;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      try {
        final response = await _apiClient.dio.get(ApiConstants.me);
        if (response.statusCode == 200 && response.data['success']) {
          final data = response.data['data'];
          // Handle both { data: { user: {...} } } and { data: {...} }
          if (data is Map && data.containsKey('user')) {
            _user = User.fromJson(data['user']);
          } else {
            _user = User.fromJson(data);
          }
          _role = await _storage.getRole();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Check Auth Error: $e');
        await logout();
      }
    }
  }
}

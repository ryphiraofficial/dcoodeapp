import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('[API REQUEST] ${options.method} ${options.uri}');
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        debugPrint('[API ERROR] ${e.response?.statusCode} ${e.requestOptions.uri}');
        debugPrint('[API ERROR DETAIL] ${e.message}');
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '${ApiConstants.baseUrl}${ApiConstants.refresh}',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
                final data = response.data['data'];
                if (data != null) {
                  final newAccessToken = data['accessToken'];
                  final newRefreshToken = data['refreshToken'];
                  final role = await _storage.getRole() ?? '';
                  final userId = await _storage.getUserId() ?? '';

                  await _storage.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                    role: role,
                    userId: userId,
                  );

                  // Retry original request
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await dio.fetch(e.requestOptions);
                  return handler.resolve(cloneReq);
                }
              }
            } catch (err) {
              // Refresh failed, logout
              await _storage.clearAll();
              // In a real app, you might want to use a global navigator key or a provider to redirect to login
            }
          }
        }
        return handler.next(e);
      },
    ));
  }
}

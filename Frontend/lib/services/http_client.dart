import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import '../utils/logger.dart';
import '../core/config/api_config.dart';

/// Custom HTTP client that handles token refresh on 401 responses
class ApiClient {
  static const String baseUrl = ApiConfig.baseUrl;
  static const int maxRetries = 3;

  /// Perform a GET request with automatic token refresh on 401
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      Logger.debug('🌐 [ApiClient] GET: $url');
      
      // Get the current valid token (with automatic refresh if needed)
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.get(url, headers: requestHeaders)
          .timeout(const Duration(seconds: 15));

      Logger.debug('📊 [ApiClient] GET response: ${response.statusCode}');

      // If token expired during request, refresh and retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        Logger.debug('🔄 [ApiClient] Got 401, attempting token refresh and retry...');
        
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return get(url, headers: headers, retryCount: retryCount + 1);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      Logger.error('❌ [ApiClient] GET error: $e');
      rethrow;
    }
  }

  /// Perform a POST request with automatic token refresh on 401
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    int retryCount = 0,
  }) async {
    try {
      Logger.debug('🌐 [ApiClient] POST: $url');
      
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body is String ? body : jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      Logger.debug('📊 [ApiClient] POST response: ${response.statusCode}');

      // If token expired during request, refresh and retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        Logger.debug('🔄 [ApiClient] Got 401, attempting token refresh and retry...');
        
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return post(url, headers: headers, body: body, retryCount: retryCount + 1);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      Logger.error('❌ [ApiClient] POST error: $e');
      rethrow;
    }
  }

  /// Perform a PUT request with automatic token refresh on 401
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    int retryCount = 0,
  }) async {
    try {
      Logger.debug('🌐 [ApiClient] PUT: $url');
      
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.put(
        url,
        headers: requestHeaders,
        body: body is String ? body : jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      Logger.debug('📊 [ApiClient] PUT response: ${response.statusCode}');

      // If token expired during request, refresh and retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        Logger.debug('🔄 [ApiClient] Got 401, attempting token refresh and retry...');
        
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return put(url, headers: headers, body: body, retryCount: retryCount + 1);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      Logger.error('❌ [ApiClient] PUT error: $e');
      rethrow;
    }
  }

  /// Perform a PATCH request with automatic token refresh on 401
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    int retryCount = 0,
  }) async {
    try {
      Logger.debug('🌐 [ApiClient] PATCH: $url');
      
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.patch(
        url,
        headers: requestHeaders,
        body: body is String ? body : jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      Logger.debug('📊 [ApiClient] PATCH response: ${response.statusCode}');

      // If token expired during request, refresh and retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        Logger.debug('🔄 [ApiClient] Got 401, attempting token refresh and retry...');
        
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return patch(url, headers: headers, body: body, retryCount: retryCount + 1);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      Logger.error('❌ [ApiClient] PATCH error: $e');
      rethrow;
    }
  }

  /// Perform a DELETE request with automatic token refresh on 401
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
    int retryCount = 0,
  }) async {
    try {
      Logger.debug('🌐 [ApiClient] DELETE: $url');
      
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?headers,
      };

      final response = await http.delete(
        url,
        headers: requestHeaders,
        body: body is String ? body : jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      Logger.debug('📊 [ApiClient] DELETE response: ${response.statusCode}');

      // If token expired during request, refresh and retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        Logger.debug('🔄 [ApiClient] Got 401, attempting token refresh and retry...');
        
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return delete(url, headers: headers, body: body, retryCount: retryCount + 1);
        } else {
          throw Exception('Session expired. Please log in again.');
        }
      }

      return response;
    } catch (e) {
      Logger.error('❌ [ApiClient] DELETE error: $e');
      rethrow;
    }
  }
}

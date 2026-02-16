import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/routing/app_router.dart';
import '../core/config/api_config.dart';
import '../core/utils/app_logger.dart';
import 'fcm_service.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';
  static const _tokenExpiryKey = 'token_expiry';

  // Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'] ?? data['access'];
        final refreshToken = data['refreshToken'] ?? data['refresh'];
        
        if (accessToken != null && refreshToken != null) {
          // Store tokens securely
          await _storage.write(key: _accessTokenKey, value: accessToken);
          await _storage.write(key: _refreshTokenKey, value: refreshToken);
          // Store user data
          await _storage.write(key: _userKey, value: jsonEncode(data['user']));
          // Store token expiry time (JWT tokens are valid for 24 hours by default)
          final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
          await _storage.write(key: _tokenExpiryKey, value: expiryTime);
          
          // Update router auth state
          AppRouter.updateAuthState(true);
          
          // Register device token with backend after successful login (fire and forget)
          try {
            await FCMService.registerDeviceToken();
          } catch (e) {
            // Log error but don't fail login - token might be registered later
            AppLogger.warning('⚠️ Failed to register device token during login: $e');
          }
          
          return {
            'success': true,
            'access': accessToken,
            'refresh': refreshToken,
            'user': data['user'],
            'email_verified': data['user']?['emailVerified'] ?? true,
          };
        } else {
          throw Exception('No tokens received from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Sign up with user details
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'fullName': username,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['accessToken'] ?? data['access'];
        final refreshToken = data['refreshToken'] ?? data['refresh'];
        
        if (accessToken != null && refreshToken != null) {
          // Store tokens securely
          await _storage.write(key: _accessTokenKey, value: accessToken);
          await _storage.write(key: _refreshTokenKey, value: refreshToken);
          // Store user data
          await _storage.write(key: _userKey, value: jsonEncode(data['user']));
          // Store token expiry time
          final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
          await _storage.write(key: _tokenExpiryKey, value: expiryTime);
          
          // Update router auth state
          AppRouter.updateAuthState(true);
          
          return {
            'success': true,
            'access': accessToken,
            'refresh': refreshToken,
            'user': data['user'],
          };
        } else {
          throw Exception('No tokens received from server');
        }
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['email']?[0] ?? 
                            errorData['password']?[0] ??
                            errorData['error'] ??
                            'Signup failed';
        throw Exception(errorMessage);
      } else {
        throw Exception('Signup failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Get stored access token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) {
        return null;
      }
      
      // Check if token is expired
      final isExpired = await _isTokenExpired();
      if (isExpired) {
        final refreshed = await refreshToken();
        if (!refreshed) {
          await logout();
          return null;
        }
        // Get new token after refresh
        return await _storage.read(key: _accessTokenKey);
      }
      
      return token;
    } catch (e) {
      return null;
    }
  }

  // Check if token is expired
  static Future<bool> _isTokenExpired() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) {
        return true;
      }
      
      final expiryTime = DateTime.parse(expiryStr);
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryTime);
      
      return isExpired;
    } catch (e) {
      return true; // Assume expired on error
    }
  }

  // Refresh the access token
  static Future<bool> refreshToken() async {
    try {
      final refreshTokenValue = await _storage.read(key: _refreshTokenKey);
      if (refreshTokenValue == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/token/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshTokenValue,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'] ?? data['access'];
        final newRefreshToken = data['refreshToken'] ?? data['refresh'];
        
        if (newAccessToken != null) {
          // Update access token
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
          
          // Update refresh token (token rotation - backend issues new refresh token)
          if (newRefreshToken != null) {
            await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
          }
          
          // Update expiry time (assuming 24 hours from now)
          final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
          await _storage.write(key: _tokenExpiryKey, value: expiryTime);
          
          return true;
        }
        return false;
      } else if (response.statusCode == 401) {
        await logout();
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      AppLogger.info('🔓 Starting logout process...');
      
      // Get refresh token before clearing
      final refreshTokenValue = await _storage.read(key: _refreshTokenKey);
      
      // Call backend logout to blacklist tokens
      if (refreshTokenValue != null) {
        try {
          final accessToken = await _storage.read(key: _accessTokenKey);
          AppLogger.info('📤 Calling backend logout endpoint...');
          await http.post(
            Uri.parse('$baseUrl/users/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'refreshToken': refreshTokenValue,
            }),
          ).timeout(const Duration(seconds: 5));
          AppLogger.info('✅ Backend logout successful');
          
        } catch (e) {
          AppLogger.warning('⚠️ Backend logout failed, continuing with local logout: $e');
          // Continue with local logout
        }
      }
      
      // Clear local tokens
      AppLogger.info('🗑️ Clearing local tokens...');
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _tokenExpiryKey);
      
      // Update router auth state
      AppRouter.updateAuthState(false);
      
      AppLogger.info('✅ Logout complete - all tokens cleared');
    } catch (e) {
      AppLogger.error('❌ Logout error', error: e);
      // Ignore logout errors
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

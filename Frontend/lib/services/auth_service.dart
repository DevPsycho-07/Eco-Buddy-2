import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';
import '../core/config/api_config.dart';

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
      Logger.debug('🔐 [Auth] Attempting login with email: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      Logger.debug('✅ [Auth] Login response status: ${response.statusCode}');
      Logger.debug('📋 [Auth] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ASP.NET backend uses 'accessToken' and 'refreshToken'
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
          
          Logger.debug('✅ [Auth] Login successful! Tokens stored.');
          return {
            'success': true,
            'access': accessToken,
            'refresh': refreshToken,
            'user': data['user'],
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
      Logger.error('❌ [Auth] Login error: $e');
      Logger.error('❌ [Auth] Stack trace: ${StackTrace.current}');
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
    String? fullName,
  }) async {
    try {
      Logger.debug('📝 [Auth] Attempting signup with email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/users/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          if (fullName != null) 'fullName': fullName,
        }),
      ).timeout(const Duration(seconds: 10));

      Logger.debug('✅ [Auth] Signup response status: ${response.statusCode}');
      Logger.debug('📋 [Auth] Response body: ${response.body}');

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
          
          Logger.debug('✅ [Auth] Signup successful! Tokens stored.');
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
      Logger.error('❌ [Auth] Signup error: $e');
      Logger.error('❌ [Auth] Stack trace: ${StackTrace.current}');
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
        Logger.debug('🔐 [Auth] No token found');
        return null;
      }
      
      // Check if token is expired
      final isExpired = await _isTokenExpired();
      if (isExpired) {
        Logger.debug('⏰ [Auth] Token expired, attempting refresh...');
        final refreshed = await refreshToken();
        if (!refreshed) {
          Logger.debug('❌ [Auth] Token refresh failed, logging out...');
          await logout();
          return null;
        }
        // Get new token after refresh
        return await _storage.read(key: _accessTokenKey);
      }
      
      Logger.debug('🔐 [Auth] Token retrieved (length: ${token.length})');
      return token;
    } catch (e) {
      Logger.error('❌ [Auth] Error retrieving token: $e');
      return null;
    }
  }

  // Check if token is expired
  static Future<bool> _isTokenExpired() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) {
        Logger.debug('⏰ [Auth] No expiry time found, assuming expired');
        return true;
      }
      
      final expiryTime = DateTime.parse(expiryStr);
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryTime);
      
      if (isExpired) {
        Logger.debug('⏰ [Auth] Token expired at $expiryTime (now: $now)');
      } else {
        final timeLeft = expiryTime.difference(now).inMinutes;
        Logger.debug('⏰ [Auth] Token valid for $timeLeft more minutes');
      }
      
      return isExpired;
    } catch (e) {
      Logger.error('❌ [Auth] Error checking token expiry: $e');
      return true; // Assume expired on error
    }
  }

  // Refresh the access token
  static Future<bool> refreshToken() async {
    try {
      Logger.debug('🔄 [Auth] Attempting token refresh...');
      
      final refreshTokenValue = await _storage.read(key: _refreshTokenKey);
      if (refreshTokenValue == null) {
        Logger.debug('❌ [Auth] No refresh token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshTokenValue,
        }),
      ).timeout(const Duration(seconds: 10));

      Logger.debug('✅ [Auth] Token refresh response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        
        if (newAccessToken != null) {
          // Update access token
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
          
          // Update expiry time (assuming 24 hours from now)
          final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
          await _storage.write(key: _tokenExpiryKey, value: expiryTime);
          
          Logger.debug('✅ [Auth] Token refreshed successfully!');
          return true;
        }
        return false;
      } else if (response.statusCode == 401) {
        Logger.debug('❌ [Auth] Refresh token expired, need to login again');
        await logout();
        return false;
      } else {
        Logger.debug('❌ [Auth] Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Logger.error('❌ [Auth] Error refreshing token: $e');
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
      Logger.error('❌ [Auth] Error reading user data: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Get refresh token before clearing
      final refreshTokenValue = await _storage.read(key: _refreshTokenKey);
      
      // Call backend logout to blacklist tokens
      if (refreshTokenValue != null) {
        try {
          final accessToken = await _storage.read(key: _accessTokenKey);
          final response = await http.post(
            Uri.parse('$baseUrl/users/logout/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'refresh': refreshTokenValue,
            }),
          ).timeout(const Duration(seconds: 5));
          
          Logger.debug('✅ [Auth] Backend logout response: ${response.statusCode}');
        } catch (e) {
          Logger.error('❌ [Auth] Backend logout error (continuing with local logout): $e');
        }
      }
      
      // Clear local tokens
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _tokenExpiryKey);
      Logger.debug('✅ [Auth] Logged out successfully');
    } catch (e) {
      Logger.error('❌ [Auth] Error logging out: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}

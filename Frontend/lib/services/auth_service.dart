import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  static final _plainDio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _plainDio.post(
        '$baseUrl/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      if (accessToken != null && refreshToken != null) {
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
        await _storage.write(key: _tokenExpiryKey, value: expiryTime);

        AppRouter.setAuthState(true);

        try {
          await FCMService.registerDeviceToken();
        } catch (e) {
          AppLogger.warning('⚠️ Failed to register device token during login: $e');
        }

        return {
          'success': true,
          'access': accessToken,
          'refresh': refreshToken,
          'user': data['user'],
          'email_verified': data['email_verified'] ?? false,
        };
      } else {
        throw Exception('No tokens received from server');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {'success': false, 'error': 'Exception: Invalid email or password'};
      }
      return {'success': false, 'error': 'Exception: Login failed. Status: ${e.response?.statusCode}'};
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
      final response = await _plainDio.post(
        '$baseUrl/users/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
        },
      );

      final data = response.data;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      if (accessToken != null && refreshToken != null) {
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
        await _storage.write(key: _tokenExpiryKey, value: expiryTime);

        AppRouter.setAuthState(true);

        return {
          'success': true,
          'access': accessToken,
          'refresh': refreshToken,
          'user': data['user'],
        };
      } else {
        throw Exception('No tokens received from server');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        final errorMessage = errorData?['email']?[0] ??
                            errorData?['password']?[0] ??
                            errorData?['error'] ??
                            'Signup failed';
        return {'success': false, 'error': 'Exception: $errorMessage'};
      }
      return {'success': false, 'error': 'Exception: Signup failed. Status: ${e.response?.statusCode}'};
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

      final response = await _plainDio.post(
        '$baseUrl/users/token/refresh',
        data: {'refresh': refreshTokenValue},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];

        if (newAccessToken != null) {
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
          final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
          await _storage.write(key: _tokenExpiryKey, value: expiryTime);
          return true;
        }
        return false;
      }
      return false;
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
          await Dio().post(
            '$baseUrl/users/logout',
            data: {'refresh': refreshTokenValue},
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );
          AppLogger.info('✅ Backend logout successful');
        } catch (e) {
          AppLogger.warning('⚠️ Backend logout failed, continuing with local logout: $e');
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

  // Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
      AppLogger.info('🔑 Google Sign-In: serverClientId = $clientId');

      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Required to get an ID token — must be the Web Client ID from Firebase
        serverClientId: clientId,
      );

      // Sign out first to force account picker
      AppLogger.info('🔄 Google Sign-In: signing out previous session...');
      await googleSignIn.signOut();

      AppLogger.info('👤 Google Sign-In: showing account picker...');
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.warning('⚠️ Google Sign-In: user cancelled');
        return {'success': false, 'error': 'Sign in cancelled'};
      }

      AppLogger.info('✅ Google Sign-In: got user → ${googleUser.email}');
      AppLogger.info('🔐 Google Sign-In: requesting authentication tokens...');

      final googleAuth = await googleUser.authentication;
      AppLogger.info('🪙 Google Sign-In: accessToken = ${googleAuth.accessToken != null ? "present" : "NULL"}');
      AppLogger.info('🪙 Google Sign-In: idToken    = ${googleAuth.idToken != null ? "present (${googleAuth.idToken!.substring(0, 20)}...)" : "NULL"}');

      final idTokenStr = googleAuth.idToken;
      if (idTokenStr == null) {
        AppLogger.error('❌ Google Sign-In: idToken is null — serverClientId may be wrong or missing');
        return {'success': false, 'error': 'Failed to get ID token from Google'};
      }

      AppLogger.info('📤 Google Sign-In: sending ID token to backend...');
      final response = await _plainDio.post(
        '$baseUrl/users/google',
        data: {'id_token': idTokenStr},
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );

      AppLogger.info('📥 Google Sign-In: backend response status = ${response.statusCode}');
      AppLogger.info('📥 Google Sign-In: backend response body = ${response.data}');

      final data = response.data;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      if (accessToken != null && refreshToken != null) {
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        final expiryTime = DateTime.now().add(const Duration(hours: 24)).toIso8601String();
        await _storage.write(key: _tokenExpiryKey, value: expiryTime);

        AppRouter.setAuthState(true);
        AppLogger.info('🎉 Google Sign-In: success! User = ${data['user']['email']}');

        try {
          await FCMService.registerDeviceToken();
        } catch (e) {
          AppLogger.warning('⚠️ Failed to register device token after Google sign-in: $e');
        }

        return {
          'success': true,
          'access': accessToken,
          'refresh': refreshToken,
          'user': data['user'],
          'email_verified': data['email_verified'] ?? true,
        };
      } else {
        throw Exception('No tokens received from server');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ Google Sign-In: DioException status=${e.response?.statusCode} body=${e.response?.data}');
      final body = e.response?.data;
      String? backendError;
      if (body is Map && body['error'] is String) {
        backendError = body['error'] as String;
      }
      final fallback = e.response?.statusCode == 401
          ? 'Could not verify your Google account. Please try again.'
          : 'Google sign-in failed. Please check your connection and try again.';
      return {'success': false, 'error': backendError ?? fallback};
    } catch (e) {
      AppLogger.error('❌ Google Sign-In: exception = $e');
      return {'success': false, 'error': 'Google sign-in failed. Please try again.'};
    }
  }
}

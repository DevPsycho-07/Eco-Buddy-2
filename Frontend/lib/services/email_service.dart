import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/utils/app_logger.dart';

class EmailService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Send password reset email
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await Dio().post(
        '$baseUrl/users/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent. Please check your inbox.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send password reset email',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        return {
          'success': false,
          'error': data?['error'] ?? 'Invalid email address',
        };
      }
      AppLogger.error('Error in forgotPassword: $e');
      return {
        'success': false,
        'error': e.message ?? 'Failed to send password reset email',
      };
    } catch (e) {
      AppLogger.error('Error in forgotPassword: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Reset password with token
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await Dio().post(
        '$baseUrl/users/reset-password',
        data: {
          'email': email,
          'token': token,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to reset password',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        return {
          'success': false,
          'error': data?['error'] ?? 'Invalid request',
        };
      }
      AppLogger.error('Error in resetPassword: $e');
      return {
        'success': false,
        'error': e.message ?? 'Failed to reset password',
      };
    } catch (e) {
      AppLogger.error('Error in resetPassword: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify email with token
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String token,
  }) async {
    try {
      final response = await Dio().post(
        '$baseUrl/users/verify-email',
        data: {
          'email': email,
          'token': token,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Verification link expired or invalid',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        return {
          'success': false,
          'error': data?['error'] ?? 'Invalid verification link',
        };
      }
      AppLogger.error('Error in verifyEmail: $e');
      return {
        'success': false,
        'error': e.message ?? 'Verification failed',
      };
    } catch (e) {
      AppLogger.error('Error in verifyEmail: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Resend verification email
  static Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      final response = await Dio().post(
        '$baseUrl/users/resend-verification-email',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification email sent. Please check your inbox.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to resend verification email',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        return {
          'success': false,
          'error': data?['error'] ?? 'Could not send verification email',
        };
      }
      AppLogger.error('Error in resendVerificationEmail: $e');
      return {
        'success': false,
        'error': e.message ?? 'Failed to resend verification email',
      };
    } catch (e) {
      AppLogger.error('Error in resendVerificationEmail: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

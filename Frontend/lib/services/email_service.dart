import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/api_config.dart';
import '../core/utils/app_logger.dart';

class EmailService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Send password reset email
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/forgot-password/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset email sent. Please check your inbox.',
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Invalid email address',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to send password reset email',
        };
      }
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
      final response = await http.post(
        Uri.parse('$baseUrl/users/reset-password/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successfully',
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Invalid request',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to reset password',
        };
      }
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
      final response = await http.post(
        Uri.parse('$baseUrl/users/verify-email/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully',
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Invalid verification link',
        };
      } else {
        return {
          'success': false,
          'error': 'Verification link expired or invalid',
        };
      }
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
      final response = await http.post(
        Uri.parse('$baseUrl/users/resend-verification-email/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Verification email sent. Please check your inbox.',
        };
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['error'] ?? 'Could not send verification email',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to resend verification email',
        };
      }
    } catch (e) {
      AppLogger.error('Error in resendVerificationEmail: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

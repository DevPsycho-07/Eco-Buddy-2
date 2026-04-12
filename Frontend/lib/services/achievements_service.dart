import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

/// Service for managing achievements, badges, and challenges
class AchievementsService {
  static final _dio = sl<DioClient>().dio;
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get overall achievements summary
  static Future<Map<String, dynamic>?> getSummary() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/summary');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// Get badges summary (earned vs available)
  static Future<Map<String, dynamic>?> getBadgesSummary() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/my-badges/summary');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        data['earned'] = (data['earned'] as List?)?.where((item) => item != null).toList() ?? [];
        data['not_earned'] = (data['not_earned'] as List?)?.where((item) => item != null).toList() ?? [];
      }
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Get all available badges
  static Future<List<dynamic>> getAllBadges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/badges');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  /// Get user's earned badges
  static Future<List<dynamic>> getEarnedBadges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/my-badges');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  /// Get active challenges
  static Future<List<dynamic>> getActiveChallenges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/challenges/active');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  /// Get user's active challenges
  static Future<List<dynamic>> getUserActiveChallenges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/my-challenges/active');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  /// Get user's completed challenges
  static Future<List<dynamic>> getUserCompletedChallenges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/my-challenges/completed');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  /// Join a challenge
  static Future<bool> joinChallenge(int challengeId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/achievements/my-challenges',
        data: {'challenge': challengeId},
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Get all user's challenges (active + completed)
  static Future<List<dynamic>> getAllUserChallenges() async {
    try {
      final response = await _dio.get('$baseUrl/achievements/my-challenges');
      final data = response.data;
      if (data is Map && data.containsKey('results')) {
        return data['results'] as List<dynamic>;
      } else if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

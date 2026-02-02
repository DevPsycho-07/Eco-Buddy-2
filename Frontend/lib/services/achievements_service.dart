import 'dart:convert';
import 'http_client.dart';
import '../utils/logger.dart';
import '../core/config/api_config.dart';

/// Service for managing achievements, badges, and challenges
class AchievementsService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get overall achievements summary
  static Future<Map<String, dynamic>?> getSummary() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/summary/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting summary: $e');
      return null;
    }
  }

  /// Get badges summary (earned vs available)
  static Future<Map<String, dynamic>?> getBadgesSummary() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/my-badges/summary/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure earned and not_earned are Lists
        if (data is Map) {
          data['earned'] = (data['earned'] as List?)?.where((item) => item != null).toList() ?? [];
          data['not_earned'] = (data['not_earned'] as List?)?.where((item) => item != null).toList() ?? [];
        }
        return data;
      }
      return null;
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting badges summary: $e');
      return null;
    }
  }

  /// Get all available badges
  static Future<List<dynamic>> getAllBadges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/badges/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting badges: $e');
      return [];
    }
  }

  /// Get user's earned badges
  static Future<List<dynamic>> getEarnedBadges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/my-badges/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting earned badges: $e');
      return [];
    }
  }

  /// Get active challenges
  static Future<List<dynamic>> getActiveChallenges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/challenges/active/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting active challenges: $e');
      return [];
    }
  }

  /// Get user's active challenges
  static Future<List<dynamic>> getUserActiveChallenges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/my-challenges/active/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting user challenges: $e');
      return [];
    }
  }

  /// Get user's completed challenges
  static Future<List<dynamic>> getUserCompletedChallenges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/my-challenges/completed/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting completed challenges: $e');
      return [];
    }
  }

  /// Join a challenge
  static Future<bool> joinChallenge(int challengeId) async {
    try {
      Logger.debug('📝 [Achievements] Joining challenge: $challengeId');

      final response = await ApiClient.post(
        Uri.parse('$baseUrl/achievements/my-challenges/'),
        body: jsonEncode({
          'challenge': challengeId,
        }),
      );

      Logger.debug('📊 [Achievements] Join response: ${response.statusCode}');
      return response.statusCode == 201;
    } catch (e) {
      Logger.error('❌ [Achievements] Error joining challenge: $e');
      return false;
    }
  }

  /// Get all user's challenges (active + completed)
  static Future<List<dynamic>> getAllUserChallenges() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/achievements/my-challenges/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle paginated response
        if (data is Map && data.containsKey('results')) {
          return data['results'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
        return [];
      }
      return [];
    } catch (e) {
      Logger.error('❌ [Achievements] Error getting all user challenges: $e');
      return [];
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../utils/logger.dart';
import 'http_client.dart';

/// Model for user profile/dashboard data
class UserDashboard {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String bio;
  final int ecoScore;
  final double totalCo2Saved;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int experiencePoints;

  UserDashboard({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.bio,
    required this.ecoScore,
    required this.totalCo2Saved,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.experiencePoints,
  });

  factory UserDashboard.fromJson(Map<String, dynamic> json) {
    return UserDashboard(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePicture: json['profile_picture'],
      bio: json['bio'] ?? '',
      ecoScore: json['eco_score'] ?? 0,
      totalCo2Saved: (json['total_co2_saved'] ?? 0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      level: json['level'] ?? 1,
      experiencePoints: json['experience_points'] ?? 0,
    );
  }

  String get displayName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return username;
  }
}

/// Model for daily score
class DailyScore {
  final String date;
  final int score;
  final double co2Emitted;
  final double co2Saved;
  final int steps;

  DailyScore({
    required this.date,
    required this.score,
    required this.co2Emitted,
    required this.co2Saved,
    required this.steps,
  });

  factory DailyScore.fromJson(Map<String, dynamic> json) {
    return DailyScore(
      date: json['date'] ?? '',
      score: json['score'] ?? 0,
      co2Emitted: (json['co2_emitted'] ?? 0).toDouble(),
      co2Saved: (json['co2_saved'] ?? 0).toDouble(),
      steps: json['steps'] ?? 0,
    );
  }
}

/// Model for user goal
class UserGoal {
  final int id;
  final String title;
  final String description;
  final double targetValue;
  final double currentValue;
  final String unit;
  final bool isCompleted;
  final String? deadline;
  final double progressPercentage;

  UserGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.isCompleted,
    this.deadline,
    required this.progressPercentage,
  });

  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetValue: (json['target_value'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      deadline: json['deadline'],
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
    );
  }
}

/// Model for challenge
class Challenge {
  final int id;
  final String title;
  final String description;
  final String challengeType;
  final double targetValue;
  final String targetUnit;
  final int pointsReward;
  final String startDate;
  final String endDate;
  final double? userProgress;
  final bool? isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeType,
    required this.targetValue,
    required this.targetUnit,
    required this.pointsReward,
    required this.startDate,
    required this.endDate,
    this.userProgress,
    this.isCompleted,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      challengeType: json['challenge_type'] ?? '',
      targetValue: (json['target_value'] ?? 0).toDouble(),
      targetUnit: json['target_unit'] ?? '',
      pointsReward: json['points_reward'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      userProgress: json['user_progress']?.toDouble(),
      isCompleted: json['is_completed'],
    );
  }
}

/// Service for dashboard-related API calls
class DashboardService {
  static const String _usersUrl = ApiConfig.usersUrl;
  static const String _achievementsUrl = ApiConfig.achievementsUrl;

  /// Get user profile/dashboard data
  static Future<UserDashboard> getUserProfile() async {
    final url = Uri.parse('$_usersUrl/profile/');

    Logger.debug('👤 [DashboardService] Fetching user profile');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.debug('✅ [DashboardService] Profile fetched');
        return UserDashboard.fromJson(data);
      } else if (response.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw DashboardException(
          'Failed to load profile. Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      Logger.error('❌ [DashboardService] Network error: $e');
      throw DashboardException(
        'Network error. Please check your internet connection and ensure the server is running.',
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      Logger.error('❌ [DashboardService] Error: $e');
      throw DashboardException('Failed to load profile: ${e.toString()}');
    }
  }

  /// Get user's daily scores
  static Future<List<DailyScore>> getDailyScores({int days = 7}) async {
    final url = Uri.parse('$_usersUrl/daily-scores/?days=$days');

    Logger.debug('📊 [DashboardService] Fetching daily scores');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((s) => DailyScore.fromJson(s)).toList();
      } else if (response.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw DashboardException(
          'Failed to load daily scores.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      Logger.error('❌ [DashboardService] Network error: $e');
      throw DashboardException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      Logger.error('❌ [DashboardService] Error: $e');
      throw DashboardException('Failed to load daily scores: ${e.toString()}');
    }
  }

  /// Get user's goals
  static Future<List<UserGoal>> getUserGoals() async {
    final url = Uri.parse('$_usersUrl/goals/');

    Logger.debug('🎯 [DashboardService] Fetching user goals');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((g) => UserGoal.fromJson(g)).toList();
      } else if (response.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw DashboardException(
          'Failed to load goals.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      Logger.error('❌ [DashboardService] Network error: $e');
      throw DashboardException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      Logger.error('❌ [DashboardService] Error: $e');
      throw DashboardException('Failed to load goals: ${e.toString()}');
    }
  }

  /// Get active challenges
  static Future<List<Challenge>> getActiveChallenges() async {
    final url = Uri.parse('$_achievementsUrl/challenges/active/');

    Logger.debug('🏆 [DashboardService] Fetching active challenges');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => Challenge.fromJson(c)).toList();
      } else if (response.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        // Return empty list if endpoint not available
        return [];
      }
    } catch (e) {
      Logger.error('❌ [DashboardService] Error fetching challenges: $e');
      return [];
    }
  }

  /// Get leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final url = Uri.parse('$_usersUrl/leaderboard/?limit=$limit');

    Logger.debug('🏅 [DashboardService] Fetching leaderboard');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        return [];
      }
    } catch (e) {
      Logger.error('❌ [DashboardService] Error: $e');
      return [];
    }
  }
}

/// Custom exception for dashboard errors
class DashboardException implements Exception {
  final String message;
  final int? statusCode;

  DashboardException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

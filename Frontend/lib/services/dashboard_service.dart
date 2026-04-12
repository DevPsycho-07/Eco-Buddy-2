import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

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
  static final _dio = sl<DioClient>().dio;
  static const String _usersUrl = ApiConfig.usersUrl;
  static const String _achievementsUrl = ApiConfig.achievementsUrl;

  /// Get user profile/dashboard data
  static Future<UserDashboard> getUserProfile() async {
    try {
      final response = await _dio.get('$_usersUrl/profile');

      return UserDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      }
      throw DashboardException(
        'Failed to load profile. ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Failed to load profile: ${e.toString()}');
    }
  }

  /// Get user's daily scores
  static Future<List<DailyScore>> getDailyScores({int days = 7}) async {
    try {
      final response = await _dio.get('$_usersUrl/daily-scores?days=$days');

      if (response.data == null) return [];
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((s) => DailyScore.fromJson(s)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      }
      throw DashboardException(
        'Failed to load daily scores. ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Failed to load daily scores: ${e.toString()}');
    }
  }

  /// Get user's goals
  static Future<List<UserGoal>> getUserGoals() async {
    try {
      final response = await _dio.get('$_usersUrl/goals');

      if (response.data == null) return [];
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((g) => UserGoal.fromJson(g)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw DashboardException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      }
      throw DashboardException(
        'Failed to load goals. ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is DashboardException) rethrow;
      throw DashboardException('Failed to load goals: ${e.toString()}');
    }
  }

  /// Get active challenges
  static Future<List<Challenge>> getActiveChallenges() async {
    try {
      final response = await _dio.get('$_achievementsUrl/challenges/active');

      final List<dynamic> data = response.data;
      return data.map((c) => Challenge.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _dio.get('$_usersUrl/leaderboard?limit=$limit');

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
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

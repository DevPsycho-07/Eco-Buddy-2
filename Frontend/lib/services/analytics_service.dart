import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../utils/logger.dart';
import 'http_client.dart';

/// Model for category breakdown data
class CategoryBreakdown {
  final String name;
  final int count;
  final double co2Impact;
  final double percentage;

  CategoryBreakdown({
    required this.name,
    required this.count,
    required this.co2Impact,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(String name, Map<String, dynamic> json) {
    return CategoryBreakdown(
      name: name,
      count: json['count'] ?? 0,
      co2Impact: (json['co2_impact'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

/// Model for daily trend data
class TrendData {
  final String date;
  final double co2Impact;
  final int activities;

  TrendData({
    required this.date,
    required this.co2Impact,
    required this.activities,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: json['date'] ?? '',
      co2Impact: (json['co2_impact'] ?? 0).toDouble(),
      activities: json['activities'] ?? 0,
    );
  }
}

/// Model for analytics stats response
class AnalyticsStats {
  final String period;
  final String startDate;
  final String endDate;
  final double totalCo2Emitted;
  final double totalCo2Saved;
  final double netImpact;
  final int totalActivities;
  final List<CategoryBreakdown> categories;
  final List<TrendData> trend;

  AnalyticsStats({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalCo2Emitted,
    required this.totalCo2Saved,
    required this.netImpact,
    required this.totalActivities,
    required this.categories,
    required this.trend,
  });

  factory AnalyticsStats.fromJson(Map<String, dynamic> json) {
    // Parse categories from by_category map
    final categoriesMap = json['by_category'] as Map<String, dynamic>? ?? {};
    final categories = categoriesMap.entries
        .map((e) => CategoryBreakdown.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList();

    // Parse trend data
    final trendList = json['trend'] as List<dynamic>? ?? [];
    final trend = trendList
        .map((e) => TrendData.fromJson(e as Map<String, dynamic>))
        .toList();

    return AnalyticsStats(
      period: json['period'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalCo2Emitted: (json['total_co2_emitted'] ?? 0).toDouble(),
      totalCo2Saved: (json['total_co2_saved'] ?? 0).toDouble(),
      netImpact: (json['net_impact'] ?? 0).toDouble(),
      totalActivities: json['total_activities'] ?? 0,
      categories: categories,
      trend: trend,
    );
  }
}

/// Model for comparison data
class ComparisonData {
  final double userEcoScore;
  final double userCo2Saved;
  final double avgEcoScore;
  final double avgCo2Saved;
  final double percentile;
  final double scoreDiff;
  final double co2Diff;

  ComparisonData({
    required this.userEcoScore,
    required this.userCo2Saved,
    required this.avgEcoScore,
    required this.avgCo2Saved,
    required this.percentile,
    required this.scoreDiff,
    required this.co2Diff,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final average = json['average'] as Map<String, dynamic>? ?? {};
    final comparison = json['comparison'] as Map<String, dynamic>? ?? {};

    return ComparisonData(
      userEcoScore: (user['eco_score'] ?? 0).toDouble(),
      userCo2Saved: (user['total_co2_saved'] ?? 0).toDouble(),
      avgEcoScore: (average['eco_score'] ?? 0).toDouble(),
      avgCo2Saved: (average['total_co2_saved'] ?? 0).toDouble(),
      percentile: (json['percentile'] ?? 0).toDouble(),
      scoreDiff: (comparison['score_diff'] ?? 0).toDouble(),
      co2Diff: (comparison['co2_diff'] ?? 0).toDouble(),
    );
  }
}

/// Service for handling analytics API calls
class AnalyticsService {
  static const String _baseUrl = ApiConfig.analyticsUrl;

  /// Get analytics stats for a specific period
  /// [period] can be 'day', 'week', 'month', or 'year'
  static Future<AnalyticsStats> getStats(String period) async {
    final url = Uri.parse('$_baseUrl/stats/?period=$period');
    
    Logger.debug('📊 [AnalyticsService] Fetching stats for period: $period');
    
    try {
      final response = await ApiClient.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Logger.debug('✅ [AnalyticsService] Stats fetched successfully');
        return AnalyticsStats.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AnalyticsException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 403) {
        throw AnalyticsException(
          'You do not have permission to view analytics.',
          statusCode: 403,
        );
      } else if (response.statusCode == 404) {
        throw AnalyticsException(
          'Analytics data not found. Please try again later.',
          statusCode: 404,
        );
      } else if (response.statusCode >= 500) {
        throw AnalyticsException(
          'Server error. The analytics service is temporarily unavailable.',
          statusCode: response.statusCode,
        );
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to load analytics data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        
        throw AnalyticsException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      Logger.error('❌ [AnalyticsService] Network error: $e');
      throw AnalyticsException(
        'Network error. Please check your internet connection and ensure the server is running.',
      );
    } on FormatException catch (e) {
      Logger.error('❌ [AnalyticsService] Invalid response format: $e');
      throw AnalyticsException(
        'Invalid response from server. Please try again later.',
      );
    } catch (e) {
      if (e is AnalyticsException) rethrow;
      Logger.error('❌ [AnalyticsService] Unexpected error: $e');
      throw AnalyticsException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Get comparison data (user vs average)
  static Future<ComparisonData> getComparison() async {
    final url = Uri.parse('$_baseUrl/comparison/');
    
    Logger.debug('📊 [AnalyticsService] Fetching comparison data');
    
    try {
      final response = await ApiClient.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Logger.debug('✅ [AnalyticsService] Comparison data fetched successfully');
        return ComparisonData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AnalyticsException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 403) {
        throw AnalyticsException(
          'You do not have permission to view comparison data.',
          statusCode: 403,
        );
      } else if (response.statusCode == 404) {
        throw AnalyticsException(
          'Comparison data not found. Please try again later.',
          statusCode: 404,
        );
      } else if (response.statusCode >= 500) {
        throw AnalyticsException(
          'Server error. The analytics service is temporarily unavailable.',
          statusCode: response.statusCode,
        );
      } else {
        // Try to parse error message from response
        String errorMessage = 'Failed to load comparison data.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {}
        
        throw AnalyticsException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      Logger.error('❌ [AnalyticsService] Network error: $e');
      throw AnalyticsException(
        'Network error. Please check your internet connection and ensure the server is running.',
      );
    } on FormatException catch (e) {
      Logger.error('❌ [AnalyticsService] Invalid response format: $e');
      throw AnalyticsException(
        'Invalid response from server. Please try again later.',
      );
    } catch (e) {
      if (e is AnalyticsException) rethrow;
      Logger.error('❌ [AnalyticsService] Unexpected error: $e');
      throw AnalyticsException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

/// Custom exception for analytics errors
class AnalyticsException implements Exception {
  final String message;
  final int? statusCode;

  AnalyticsException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

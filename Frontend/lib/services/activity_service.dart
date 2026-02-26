import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import 'http_client.dart';
import 'auth_service.dart';

/// Model for activity category
class ActivityCategory {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String description;
  final List<ActivityType> activityTypes;

  ActivityCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.activityTypes,
  });

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    final typesJson = json['activity_types'] as List<dynamic>? ?? [];
    return ActivityCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#4CAF50',
      description: json['description'] ?? '',
      activityTypes: typesJson.map((t) => ActivityType.fromJson(t)).toList(),
    );
  }
}

/// Model for activity type
class ActivityType {
  final int id;
  final String name;
  final String icon;
  final double co2Impact;
  final String impactUnit;
  final bool isEcoFriendly;
  final int points;
  final int? categoryId;
  final String? categoryName;

  ActivityType({
    required this.id,
    required this.name,
    required this.icon,
    required this.co2Impact,
    required this.impactUnit,
    required this.isEcoFriendly,
    required this.points,
    this.categoryId,
    this.categoryName,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) {
    return ActivityType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      co2Impact: (json['co2_impact'] ?? 0).toDouble(),
      impactUnit: json['impact_unit'] ?? 'per instance',
      isEcoFriendly: json['is_eco_friendly'] ?? false,
      points: json['points'] ?? 0,
      categoryId: json['category'],
      categoryName: json['category_name'],
    );
  }
}

/// Model for logged activity
class Activity {
  final int id;
  final int activityTypeId;
  final String activityTypeName;
  final String categoryName;
  final double quantity;
  final String unit;
  final String notes;
  final double co2Impact;
  final int pointsEarned;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String activityDate;
  final String? activityTime;
  final bool isAutoDetected;
  final String createdAt;

  Activity({
    required this.id,
    required this.activityTypeId,
    required this.activityTypeName,
    required this.categoryName,
    required this.quantity,
    required this.unit,
    required this.notes,
    required this.co2Impact,
    required this.pointsEarned,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.activityDate,
    this.activityTime,
    required this.isAutoDetected,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      activityTypeId: json['activity_type'] ?? 0,
      activityTypeName: json['activity_type_name'] ?? '',
      categoryName: json['category_name'] ?? '',
      quantity: (json['quantity'] ?? 1).toDouble(),
      unit: json['unit'] ?? '',
      notes: json['notes'] ?? '',
      co2Impact: (json['co2_impact'] ?? 0).toDouble(),
      pointsEarned: json['points_earned'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationName: json['location_name'],
      activityDate: json['activity_date'] ?? '',
      activityTime: json['activity_time'],
      isAutoDetected: json['is_auto_detected'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

/// Model for activity summary
class ActivitySummary {
  final String startDate;
  final String endDate;
  final int totalActivities;
  final int totalPoints;
  final double totalCo2Saved;
  final double totalCo2Emitted;
  final Map<String, dynamic> byCategory;

  ActivitySummary({
    required this.startDate,
    required this.endDate,
    required this.totalActivities,
    required this.totalPoints,
    required this.totalCo2Saved,
    required this.totalCo2Emitted,
    required this.byCategory,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalActivities: json['total_activities'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      totalCo2Saved: (json['total_co2_saved'] ?? 0).toDouble(),
      totalCo2Emitted: (json['total_co2_emitted'] ?? 0).toDouble(),
      byCategory: json['by_category'] ?? {},
    );
  }
}

/// Model for daily tip
class Tip {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String title;
  final String content;
  final String impactDescription;

  Tip({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.title,
    required this.content,
    required this.impactDescription,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] ?? 0,
      categoryId: json['category'],
      categoryName: json['category_name'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      impactDescription: json['impact_description'] ?? '',
    );
  }
}

/// Service for handling activity-related API calls
class ActivityService {
  static const String _baseUrl = ApiConfig.activitiesUrl;

  /// Get all activity categories with their types
  static Future<List<ActivityCategory>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories/');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Handle both paginated and non-paginated responses
        final List<dynamic> data = decoded is List ? decoded : (decoded['results'] ?? []);
        return data.map((c) => ActivityCategory.fromJson(c)).toList();
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw ActivityException(
          'Failed to load categories. Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection and ensure the server is running.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to load categories: ${e.toString()}');
    }
  }

  /// Get activity types, optionally filtered by category
  static Future<List<ActivityType>> getActivityTypes({int? categoryId}) async {
    var url = Uri.parse('$_baseUrl/types/');
    if (categoryId != null) {
      url = Uri.parse('$_baseUrl/types/?category=$categoryId');
    }

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Handle both paginated and non-paginated responses
        final List<dynamic> data = decoded is List ? decoded : (decoded['results'] ?? []);
        return data.map((t) => ActivityType.fromJson(t)).toList();
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw ActivityException(
          'Failed to load activity types. Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to load activity types: ${e.toString()}');
    }
  }

  /// Log a new activity
  static Future<Activity> logActivity({
    required int activityTypeId,
    required double quantity,
    String? unit,
    String? notes,
    double? latitude,
    double? longitude,
    String? locationName,
    required String activityDate,
    String? activityTime,
    bool isAutoDetected = false,
  }) async {
    final url = Uri.parse('$_baseUrl/log/');

    try {
      final body = {
        'activity_type': activityTypeId,
        'quantity': quantity,
        'activity_date': activityDate,
        'is_auto_detected': isAutoDetected,
      };

      if (unit != null && unit.isNotEmpty) body['unit'] = unit;
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (locationName != null && locationName.isNotEmpty) {
        body['location_name'] = locationName;
      }
      if (activityTime != null && activityTime.isNotEmpty) {
        body['activity_time'] = activityTime;
      }

      final response = await ApiClient.post(url, body: jsonEncode(body));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Activity.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        String message = 'Invalid activity data.';
        if (error is Map) {
          message = error.entries.map((e) => '${e.key}: ${e.value}').join(', ');
        }
        throw ActivityException(message, statusCode: 400);
      } else {
        throw ActivityException(
          'Failed to log activity. Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to log activity: ${e.toString()}');
    }
  }

  /// Get today's activities
  static Future<List<Activity>> getTodayActivities() async {
    final url = Uri.parse('$_baseUrl/log/today/');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((a) => Activity.fromJson(a)).toList();
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw ActivityException(
          'Failed to load today\'s activities.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to load activities: ${e.toString()}');
    }
  }

  /// Get activity summary for a date range
  static Future<ActivitySummary> getSummary({int days = 7}) async {
    final url = Uri.parse('$_baseUrl/log/summary/?days=$days');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ActivitySummary.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw ActivityException(
          'Failed to load activity summary.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to load summary: ${e.toString()}');
    }
  }

  /// Get activity history grouped by date
  static Future<Map<String, List<Activity>>> getHistory({int days = 30}) async {
    final url = Uri.parse('$_baseUrl/log/history/?days=$days');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final result = <String, List<Activity>>{};
        
        data.forEach((date, activities) {
          final list = activities as List<dynamic>;
          result[date] = list.map((a) => Activity.fromJson(a)).toList();
        });
        
        return result;
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        throw ActivityException(
          'Failed to load activity history.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to load history: ${e.toString()}');
    }
  }

  /// Get daily tip
  static Future<Tip?> getDailyTip() async {
    final url = Uri.parse('$_baseUrl/tips/daily/');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Tip.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Delete an activity
  static Future<void> deleteActivity(int activityId) async {
    final url = Uri.parse('$_baseUrl/log/$activityId/');

    try {
      final response = await ApiClient.delete(url);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw ActivityException(
          'Authentication failed. Please log in again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        throw ActivityException(
          'Activity not found.',
          statusCode: 404,
        );
      } else {
        throw ActivityException(
          'Failed to delete activity.',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ActivityException(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Failed to delete activity: ${e.toString()}');
    }
  }

  /// Search activities by query
  static Future<List<Map<String, dynamic>>> searchActivities(String query) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw ActivityException('Not authenticated');
      }

      final response = await ApiClient.get(
        Uri.parse('${ApiConfig.baseUrl}/activities/activities/?search=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw ActivityException(
          'Failed to search activities',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ActivityException) rethrow;
      throw ActivityException('Search failed: ${e.toString()}');
    }
  }
}

/// Custom exception for activity errors
class ActivityException implements Exception {
  final String message;
  final int? statusCode;

  ActivityException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

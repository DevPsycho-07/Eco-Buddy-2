import 'dart:convert';
import '../core/config/api_config.dart';
import 'http_client.dart';

/// Travel Service for managing trip-related API calls
class TravelService {
  static final String _baseUrl = '${ApiConfig.baseUrl}/travel';
  static final String _tripsUrl = '$_baseUrl/trips';

  /// Get today's trips
  static Future<List<Map<String, dynamic>>> getTodayTrips() async {
    final url = Uri.parse('$_tripsUrl/today/');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      } else {
        return [];
      }
    } catch (e) {
      throw TravelException('Failed to fetch today\'s trips: $e');
    }
  }

  /// Get trip statistics for the specified number of days
  static Future<Map<String, dynamic>> getTravelStats({int days = 7}) async {
    final url = Uri.parse('$_tripsUrl/stats/?days=$days');

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      } else {
        return {};
      }
    } catch (e) {
      throw TravelException('Failed to fetch travel stats: $e');
    }
  }

  /// Get all trips with optional filters
  static Future<List<Map<String, dynamic>>> getTrips({
    String? startDate,
    String? endDate,
    String? transportMode,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (transportMode != null) queryParams['mode'] = transportMode;

    final url = Uri.parse(_tripsUrl).replace(queryParameters: queryParams);

    try {
      final response = await ApiClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      } else {
        return [];
      }
    } catch (e) {
      throw TravelException('Failed to fetch trips: $e');
    }
  }

  /// Create a new trip
  static Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    final url = Uri.parse(_tripsUrl);

    try {
      final response = await ApiClient.post(
        url,
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      } else {
        throw TravelException('Failed to create trip');
      }
    } catch (e) {
      throw TravelException('Failed to create trip: $e');
    }
  }

  /// Update an existing trip
  static Future<Map<String, dynamic>> updateTrip(int tripId, Map<String, dynamic> tripData) async {
    final url = Uri.parse('$_tripsUrl/$tripId/');

    try {
      final response = await ApiClient.put(
        url,
        body: jsonEncode(tripData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      } else {
        throw TravelException('Failed to update trip');
      }
    } catch (e) {
      throw TravelException('Failed to update trip: $e');
    }
  }

  /// Delete a trip
  static Future<void> deleteTrip(int tripId) async {
    final url = Uri.parse('$_tripsUrl/$tripId/');

    try {
      final response = await ApiClient.delete(url);

      if (response.statusCode != 204) {
        throw TravelException('Failed to delete trip');
      }
    } catch (e) {
      throw TravelException('Failed to delete trip: $e');
    }
  }
}

/// Custom exception for travel service
class TravelException implements Exception {
  final String message;
  final int? statusCode;

  TravelException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

/// Travel Service for managing trip-related API calls
class TravelService {
  static final _dio = sl<DioClient>().dio;
  static final String _baseUrl = '${ApiConfig.baseUrl}/travel';
  static final String _tripsUrl = '$_baseUrl/trips';

  /// Get today's trips
  static Future<List<Map<String, dynamic>>> getTodayTrips() async {
    try {
      final response = await _dio.get('$_tripsUrl/today');

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to fetch today\'s trips: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
      throw TravelException('Failed to fetch today\'s trips: $e');
    }
  }

  /// Get trip statistics for the specified number of days
  static Future<Map<String, dynamic>> getTravelStats({int days = 7}) async {
    try {
      final response = await _dio.get('$_tripsUrl/stats?days=$days');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to fetch travel stats: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
      throw TravelException('Failed to fetch travel stats: $e');
    }
  }

  /// Get all trips with optional filters
  static Future<List<Map<String, dynamic>>> getTrips({
    String? startDate,
    String? endDate,
    String? transportMode,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (transportMode != null) queryParams['mode'] = transportMode;

      final response = await _dio.get(
        _tripsUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to fetch trips: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
      throw TravelException('Failed to fetch trips: $e');
    }
  }

  /// Create a new trip
  static Future<Map<String, dynamic>> createTrip(Map<String, dynamic> tripData) async {
    try {
      final response = await _dio.post(_tripsUrl, data: tripData);

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw TravelException('Failed to create trip');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to create trip: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
      throw TravelException('Failed to create trip: $e');
    }
  }

  /// Update an existing trip
  static Future<Map<String, dynamic>> updateTrip(int tripId, Map<String, dynamic> tripData) async {
    try {
      final response = await _dio.put('$_tripsUrl/$tripId', data: tripData);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to update trip: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
      throw TravelException('Failed to update trip: $e');
    }
  }

  /// Delete a trip
  static Future<void> deleteTrip(int tripId) async {
    try {
      final response = await _dio.delete('$_tripsUrl/$tripId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw TravelException('Failed to delete trip');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw TravelException('Authentication failed. Please log in again.', statusCode: 401);
      }
      throw TravelException('Failed to delete trip: ${e.message}');
    } catch (e) {
      if (e is TravelException) rethrow;
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

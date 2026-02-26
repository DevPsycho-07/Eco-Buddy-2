/// Secure profile picture service
/// Handles encrypted profile pictures through authenticated API
library;

import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';
import '../core/utils/app_logger.dart';

/// Cache entry for profile pictures
class _ImageCacheEntry {
  final Uint8List bytes;
  final DateTime cachedAt;

  _ImageCacheEntry(this.bytes, this.cachedAt);

  bool get isValid {
    final age = DateTime.now().difference(cachedAt);
    return age.inMinutes < 30; // Cache for 30 minutes
  }
}

/// Service for managing encrypted profile pictures
class SecureProfilePictureService {
  static final _dio = sl<DioClient>().dio;
  static const String baseUrl = ApiConfig.baseUrl;
  
  /// In-memory cache for profile picture bytes (key: userId or "self" for current user)
  static final Map<String, _ImageCacheEntry> _imageCache = {};

  /// Upload encrypted profile picture
  /// 
  /// The image is encrypted on the server side for privacy
  /// 
  /// Example:
  /// ```dart
  /// await SecureProfilePictureService.uploadProfilePicture(imageFile);
  /// ```
  static Future<String?> uploadProfilePicture(String filePath) async {
    try {
      AppLogger.info('Uploading profile picture: $filePath');

      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          filePath,
          filename: 'profile.jpg',
        ),
      });

      final response = await _dio.post(
        '$baseUrl/users/profile-picture/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Clear cache after upload
        clearCache(cacheKey: 'self');
        AppLogger.info('Profile picture uploaded successfully');
        return response.data['profile_picture_url'] as String?;
      }

      AppLogger.warning('Failed to upload profile picture: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Dio error uploading profile picture',
        error: e,
        stackTrace: e.stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error uploading profile picture',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get decrypted profile picture
  /// 
  /// The server decrypts the image before sending
  /// Only accessible by the authenticated user
  /// 
  /// Example:
  /// ```dart
  /// final imageBytes = await SecureProfilePictureService.getProfilePicture();
  /// ```
  static Future<Uint8List?> getProfilePicture({int? userId}) async {
    try {
      final cacheKey = userId?.toString() ?? 'self';
      
      // Check widget-level cache first
      final cached = _imageCache[cacheKey];
      if (cached != null && cached.isValid) {
        AppLogger.info('Using cached profile picture for user: $cacheKey');
        return cached.bytes;
      }
      
      final url = userId != null
          ? '$baseUrl/users/profile-picture/$userId/'
          : '$baseUrl/users/profile-picture/';

      AppLogger.info('Fetching profile picture from: $url');

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as Uint8List;
        
        // Store in widget-level cache
        _imageCache[cacheKey] = _ImageCacheEntry(bytes, DateTime.now());
        
        AppLogger.info('Profile picture fetched successfully');
        return bytes;
      }

      AppLogger.warning('Failed to fetch profile picture: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('No profile picture found');
        return null;
      }
      AppLogger.error(
        'Dio error fetching profile picture',
        error: e,
        stackTrace: e.stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error fetching profile picture',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Delete profile picture
  /// 
  /// Removes the encrypted profile picture from server
  /// 
  /// Example:
  /// ```dart
  /// await SecureProfilePictureService.deleteProfilePicture();
  /// ```
  static Future<bool> deleteProfilePicture() async {
    try {
      AppLogger.info('Deleting profile picture');

      final response = await _dio.delete(
        '$baseUrl/users/profile-picture/',
      );

      if (response.statusCode == 200) {
        // Clear cache after deletion
        _imageCache.remove('self');
        AppLogger.info('Profile picture deleted successfully');
        return true;
      }

      AppLogger.warning('Failed to delete profile picture: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      AppLogger.error(
        'Dio error deleting profile picture',
        error: e,
        stackTrace: e.stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error deleting profile picture',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
  
  /// Clear cached profile pictures
  /// Useful when user updates their profile picture
  static void clearCache({String? cacheKey}) {
    if (cacheKey != null) {
      _imageCache.remove(cacheKey);
      AppLogger.info('Cleared cache for: $cacheKey');
    } else {
      _imageCache.clear();
      AppLogger.info('Cleared all profile picture cache');
    }
  }

  /// Get profile picture URL for a user
  /// 
  /// Returns the API endpoint URL (not direct file access)
  /// 
  /// Example:
  /// ```dart
  /// final url = SecureProfilePictureService.getProfilePictureUrl(userId);
  /// ```
  static String getProfilePictureUrl(int userId) {
    return '$baseUrl/users/profile-picture/$userId/';
  }
}

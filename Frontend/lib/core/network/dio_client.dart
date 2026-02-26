// ignore_for_file: dangling_library_doc_comments

/// Dio HTTP Client with automatic retry, caching, and token management
/// 
/// Features:
/// - Automatic token refresh on 401 errors
/// - Request/response caching
/// - Connectivity checking
/// - Request/response logging
/// - Error handling
library;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/api_config.dart';
import '../utils/app_logger.dart';
import 'cache_manager.dart';
import 'connectivity_service.dart';

/// Custom Dio client with advanced features
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage storage;
  final ConnectivityService connectivityService;
  final CacheManager cacheManager;

  DioClient({
    required this.storage,
    required this.connectivityService,
    required this.cacheManager,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Add pretty logger for debugging
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Handle outgoing requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check connectivity
    final hasConnection = await connectivityService.hasConnection;
    if (!hasConnection) {
      // Try to get cached response
      final cachedResponse = await cacheManager.get(options.uri.toString());
      if (cachedResponse != null) {
        AppLogger.info('Using cached response (offline mode)');
        return handler.resolve(
          Response(
            requestOptions: options,
            data: cachedResponse,
            statusCode: 200,
            headers: Headers.fromMap({'X-Cache': ['HIT']}),
          ),
        );
      }

      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
    }

    // Add authorization token
    final token = await storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    AppLogger.apiRequest(options.method, options.uri.toString());
    handler.next(options);
  }

  /// Handle incoming responses
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    AppLogger.apiResponse(
      response.statusCode ?? 0,
      response.requestOptions.uri.toString(),
    );

    // Cache successful GET requests
    if (response.requestOptions.method == 'GET' && 
        response.statusCode == 200 &&
        response.data != null) {
      await cacheManager.set(
        response.requestOptions.uri.toString(),
        response.data,
        duration: const Duration(minutes: 5),
      );
    }

    handler.next(response);
  }

  /// Handle errors
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.error(
      'API Error: ${error.message}',
      error: error,
      stackTrace: error.stackTrace,
    );

    // Handle 401 - Token expired
    if (error.response?.statusCode == 401) {
      try {
        // Try to refresh token
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request
          final options = error.requestOptions;
          final token = await storage.read(key: 'access_token');
          options.headers['Authorization'] = 'Bearer $token';

          try {
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            // If retry fails, pass the error
            return handler.next(error);
          }
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', error: e);
      }
    }

    // Try to use cached response on error
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      final cachedResponse = await cacheManager.get(
        error.requestOptions.uri.toString(),
      );
      if (cachedResponse != null) {
        AppLogger.info('Using cached response due to network error');
        return handler.resolve(
          Response(
            requestOptions: error.requestOptions,
            data: cachedResponse,
            statusCode: 200,
            headers: Headers.fromMap({'X-Cache': ['HIT-ERROR']}),
          ),
        );
      }
    }

    handler.next(error);
  }

  /// Refresh authentication token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConfig.baseUrl}/api/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await storage.write(key: 'access_token', value: newAccessToken);
        AppLogger.info('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to refresh token', error: e);
      return false;
    }
  }

  /// Clear all cached responses
  Future<void> clearCache() async {
    await cacheManager.clear();
    AppLogger.info('Cache cleared');
  }
}

/// Firebase Cloud Messaging Service
/// Handles push notifications for the app
library;

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../core/utils/app_logger.dart';
import 'auth_service.dart';
import '../core/config/api_config.dart';
import '../core/network/dio_client.dart';
import '../core/di/service_locator.dart';

/// Handle background messages (app terminated)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Handling background message: ${message.messageId}');
  // Handle background notification
  if (message.notification != null) {
    AppLogger.info('Background notification: ${message.notification!.title}');
  }
}

/// Firebase Cloud Messaging Service
class FCMService {
  // Use getter to lazily access Firebase after initialization
  static FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  static final _dio = sl<DioClient>().dio;
  static const String baseUrl = ApiConfig.baseUrl;

  /// Initialize Firebase and FCM
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      AppLogger.info('Firebase initialized');
      
      // Request notification permissions
      await _requestPermissions();
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Setup foreground notification handling
      _setupForegroundHandler();
      
      // Setup notification tapping
      _setupNotificationTapHandler();
      
      AppLogger.info('FCM initialization complete');
    } catch (e) {
      AppLogger.error('Firebase initialization failed', error: e);
      rethrow; // Rethrow so main.dart can catch it
    }
  }

  /// Request notification permissions (iOS 13+)
  static Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('Notification permissions granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('Notification permissions provisional');
      } else {
        AppLogger.warning('Notification permissions denied');
      }
    } catch (e) {
      AppLogger.error('Failed to request notification permissions', error: e);
    }
  }

  /// Get device FCM token and register with backend
  static Future<void> registerDeviceToken() async {
    try {
      AppLogger.info('📱 Starting device token registration...');
      
      // Small delay to ensure Firebase is initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      
      if (token == null) {
        AppLogger.warning('⚠️ Failed to get FCM token');
        return;
      }

      AppLogger.info('🔑 FCM Token obtained: ${token.substring(0, 30)}...');

      // Register token with backend
      await _registerTokenWithBackend(token);

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        AppLogger.info('🔄 FCM Token refreshed: ${newToken.substring(0, 30)}...');
        _registerTokenWithBackend(newToken);
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to register device token', 
        error: e, 
        stackTrace: stackTrace,
      );
      rethrow; // Re-throw so caller can handle
    }
  }

  /// Register device token with backend
  static Future<void> _registerTokenWithBackend(String token) async {
    try {
      final authToken = await AuthService.getToken();
      if (authToken == null) {
        AppLogger.warning('❌ No auth token available for device registration');
        return;
      }

      AppLogger.info('📤 Registering device token with backend...');
      AppLogger.info('Auth token available: ${authToken.substring(0, 20)}...');

      final response = await _dio.post(
        '$baseUrl/users/register-device-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'deviceToken': token,
          'deviceType': 'mobile',
        },
      );

      AppLogger.info('📡 Backend response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('✅ Device token registered successfully');
        AppLogger.info('Response: ${response.data}');
      } else {
        AppLogger.warning('⚠️ Failed to register device token: ${response.statusCode}');
        AppLogger.warning('Response: ${response.data}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to register device token with backend', 
        error: e, 
        stackTrace: stackTrace,
      );
    }
  }

  /// Setup foreground notification handler
  static void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground message received: ${message.messageId}');
      
      // Check for refresh_notifications action in data
      final action = message.data['action'];
      if (action == 'refresh_notifications') {
        AppLogger.info('📬 Notification refresh requested by backend');
        // Trigger notification refresh callback if set
        _onNotificationReceived?.call();
      }
      
      if (message.notification != null) {
        AppLogger.info('Title: ${message.notification!.title}');
        AppLogger.info('Body: ${message.notification!.body}');
        
        // Show in-app notification
        _showInAppNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
          data: message.data,
        );
      }
    });
  }

  /// Callback for when notification is received (for app_shell to refresh count)
  static VoidCallback? _onNotificationReceived;
  
  /// Set callback for when notification is received
  static void setNotificationCallback(VoidCallback callback) {
    _onNotificationReceived = callback;
  }

  /// Setup notification tap handler
  static void _setupNotificationTapHandler() {
    // When app is in background/terminated and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification tapped: ${message.messageId}');
      
      // Trigger notification refresh when user opens app from notification
      _onNotificationReceived?.call();
      
      _handleNotificationTap(message.data);
    });

    // Check if app was opened from terminated state
    _checkInitialMessage();
  }

  /// Check initial message when app is launched from notification
  static Future<void> _checkInitialMessage() async {
    try {
      final RemoteMessage? initialMessage = 
          await FirebaseMessaging.instance.getInitialMessage();
      
      if (initialMessage != null) {
        AppLogger.info('App launched from notification: ${initialMessage.messageId}');
        _handleNotificationTap(initialMessage.data);
      }
    } catch (e) {
      AppLogger.error('Failed to check initial message', error: e);
    }
  }

  /// Show in-app notification (implement based on your notification center UI)
  static void _showInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    AppLogger.info('Showing in-app notification: $title - $body');
    
    // In-app notifications are handled through the notification center
    // which fetches notifications from the backend API
    // This method can be used for immediate UI feedback (e.g., toast/snackbar)
    // For now, notifications are stored on the backend and displayed through
    // the NotificationsPage when user opens the notification center
    
    // Future enhancement: Could add a floating toast notification here
    // using packages like 'toastification' or custom SnackBar implementation
  }

  /// Handle notification tap navigation
  static void _handleNotificationTap(Map<String, dynamic> data) {
    AppLogger.info('Handling notification tap with data: $data');
    
    // Extract notification type and navigate accordingly
    final notificationType = data['type'] ?? 'general';
    final targetId = data['target_id'];

    switch (notificationType) {
      case 'achievement':
        // Navigate to achievements page
        // navigatorKey.currentState?.pushNamed('/achievements');
        AppLogger.info('Navigating to achievement: $targetId');
        break;
      case 'badge':
        // Navigate to achievements page
        AppLogger.info('Navigating to badge: $targetId');
        break;
      case 'challenge':
        // Navigate to challenges
        AppLogger.info('Navigating to challenge: $targetId');
        break;
      default:
        AppLogger.info('Unknown notification type: $notificationType');
    }
  }

  /// Test method to send local test notification (for development)
  static Future<void> sendTestNotification() async {
    try {
      // This would normally come from FCM
      // For testing, we show a local notification
      AppLogger.info('Test notification triggered');
    } catch (e) {
      AppLogger.error('Failed to send test notification', error: e);
    }
  }
}

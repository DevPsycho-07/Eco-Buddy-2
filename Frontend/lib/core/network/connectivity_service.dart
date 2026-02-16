// ignore_for_file: dangling_library_doc_comments

/// Connectivity service to monitor network status
/// 
/// Provides real-time network connectivity monitoring and status checks.
/// 
/// Example:
/// ```dart
/// final connectivityService = sl<ConnectivityService>();
/// 
/// // Check current status
/// if (await connectivityService.hasConnection) {
///   // Make network request
/// }
/// 
/// // Listen to changes
/// connectivityService.connectivityStream.listen((hasConnection) {
///   if (!hasConnection) {
///     showOfflineMessage();
///   }
/// });
/// ```
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

/// Service to manage and monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();

  ConnectivityService(this._connectivity) {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Stream of connectivity status changes
  /// Emits true when connected, false when disconnected
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Check if device has internet connection
  Future<bool> get hasConnection async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (e) {
      AppLogger.error('Error checking connectivity', error: e);
      return false;
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      AppLogger.error('Error initializing connectivity', error: e);
      _connectivityController.add(false);
    }
  }

  /// Update connection status when connectivity changes
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final hasConnection = _isConnected(result);
    _connectivityController.add(hasConnection);
    
    if (hasConnection) {
      AppLogger.info('Network connected: ${result.join(", ")}');
    } else {
      AppLogger.warning('Network disconnected');
    }
  }

  /// Check if connectivity result indicates connection
  bool _isConnected(List<ConnectivityResult> result) {
    return result.any((r) => 
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.ethernet
    );
  }

  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}

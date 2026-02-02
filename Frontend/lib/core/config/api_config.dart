import 'dart:io';

/// Centralized API configuration for ASP.NET Core Backend
/// Change the base URL here to update it across the entire app
class ApiConfig {
  // ASP.NET Core backend URL using dev tunnel for remote access
  static const String _dotnetTunnelUrl = 'https://hc09rz96-5000.inc1.devtunnels.ms';
  
  // Fallback local IP (for physical devices on same network)
  static const String _fallbackIp = '192.168.1.10';
  static const String _port = '5000';
  
  // Auto-detect local IP address
  static Future<String> _getLocalIp() async {
    try {
      // Get all network interfaces
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      // Find the first non-loopback IPv4 address
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          // Skip loopback addresses (127.x.x.x)
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      // If detection fails, use fallback
      return _fallbackIp;
    }
    return _fallbackIp;
  }
  
  // Get base URL with auto-detected or fallback IP
  static Future<String> getBaseUrl() async {
    final ip = await _getLocalIp();
    return 'http://$ip:$_port/api';
  }
  
  // Static base URL for synchronous access (uses dev tunnel for .NET backend)
  // Use getBaseUrl() for auto-detection
  static const String baseUrl = '$_dotnetTunnelUrl/api';
  
  // Individual endpoint bases (if needed)
  static const String usersUrl = '$baseUrl/users';
  static const String predictionsUrl = '$baseUrl/predictions';
  static const String activitiesUrl = '$baseUrl/activities';
  static const String achievementsUrl = '$baseUrl/achievements';
  static const String analyticsUrl = '$baseUrl/analytics';
  static const String travelUrl = '$baseUrl/travel';
}


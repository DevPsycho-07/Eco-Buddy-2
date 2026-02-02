/// Simple logging utility for debugging
/// Messages are always printed to console for visibility during development
class Logger {
  static void debug(String message) {
    // ignore: avoid_print
    print('[DEBUG] $message');
  }

  static void error(String message) {
    // ignore: avoid_print
    print('[ERROR] $message');
  }

  static void info(String message) {
    // ignore: avoid_print
    print('[INFO] $message');
  }
}

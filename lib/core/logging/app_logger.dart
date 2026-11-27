// Cross-platform console logger ensuring visibility in Chrome DevTools Console.
// Uses print() so logs appear in debug, profile, and release web builds.

abstract final class AppLogger {
  static void log(String message) {
    // ignore: avoid_print
    print(message);
  }
}

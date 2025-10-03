// Fallback implementation for Mobile platforms
// This provides the same API as package:web/web.dart but with stub implementations

/// Fake Document class that mimics web document behavior
class Document {
  /// Always returns false on mobile platforms since there's no browser fullscreen
  bool get fullscreen => false;

  /// Stub method for fullscreen requests (does nothing on mobile)
  void exitFullscreen() {
    // No-op for mobile platforms
  }

  /// Stub method for fullscreen requests (does nothing on mobile)
  void requestFullscreen() {
    // No-op for mobile platforms
  }
}

/// Global document instance that matches the web library pattern
final Document document = Document();

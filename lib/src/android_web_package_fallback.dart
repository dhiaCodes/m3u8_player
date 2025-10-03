/// Fallback implementation for mobile platforms.
///
/// This file provides stub implementations of web APIs that are not available
/// on mobile platforms. It ensures that code can compile and run on mobile
/// without throwing runtime errors when web-specific APIs are called.
library;

/// Stub implementation of the web Document class for mobile platforms.
///
/// This class provides the same API surface as the web document object
/// but with no-op implementations since fullscreen operations are handled
/// differently on mobile platforms.
class Document {
  /// Always returns false on mobile platforms since there's no browser fullscreen concept.
  ///
  /// Mobile fullscreen is handled through the Flutter framework and
  /// system UI controls rather than browser APIs.
  bool get fullscreen => false;

  /// Stub method for exiting fullscreen (no-op on mobile platforms).
  ///
  /// On mobile, fullscreen operations are handled by the Flutter
  /// framework and native platform controls.
  void exitFullscreen() {
    // No-op for mobile platforms - fullscreen is handled by Flutter
  }

  /// Stub method for requesting fullscreen (no-op on mobile platforms).
  ///
  /// On mobile, fullscreen operations are handled by the Flutter
  /// framework and native platform controls.
  void requestFullscreen() {
    // No-op for mobile platforms - fullscreen is handled by Flutter
  }
}

/// Global document instance that matches the web library API pattern.
///
/// This provides a consistent API surface across web and mobile platforms,
/// allowing the same code to compile and run on both platforms.
final Document document = Document();

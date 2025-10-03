# Changelog

## [v1.0.0] - 2025-01-03

### 🚀 Major Release - Enhanced Fork
This is a fork of the original m3u8_player with significant improvements and enhancements.

### ✨ Added
- **Full Mobile Platform Support**: Complete implementation for Android and iOS platforms
- **Modern Web APIs**: Migrated from deprecated `dart:html` and `dart:js_util` to modern APIs:
  - `dart:js_interop`
  - `dart:js_interop_unsafe` 
  - `package:web`
- Enhanced mobile video player experience with native controls
- Improved error handling and stability across platforms

### 🐛 Fixed
- Multiple web-related bugs that affected video playback
- Compatibility issues with latest Flutter and Dart versions
- Mobile platform rendering and control issues

### 📝 Attribution
This package is based on the original work by [Helio Mendes](https://github.com/MendesCorporation/m3u8_player). We thank the original author for their contribution to the Flutter community.

---

## Previous Versions (from original package)

## [v0.0.7] 

- Add auto fullscreen on orientation mobile

## [v0.0.6] 

- Fixed some bugs

## [v0.0.5] 

- Removed bitrate shows from web player

## [v0.0.4] 

- Fixed web player.

## [v0.0.3] 

### Git Changelog
- Implemented core functionalities for m3u8 player.
- Refactored player control components.
- Improved quality selection services.
- Minor bug fixes and performance improvements.

### pub.dev Changelog
- v0.0.3 Release:
    - Implemented core functionalities for m3u8 player.
    - Refactored player control components.
    - Improved quality selection services.
    - Minor bug fixes and performance improvements.

# M3U8 Player Plus

An enhanced Flutter package that provides a customizable M3U8 player for both mobile and web platforms with improved mobile support and modern web APIs.

## 🚀 What's New in Plus Version

This package is a fork of the original [m3u8_player](https://github.com/MendesCorporation/m3u8_player) with significant improvements:

### ✨ Key Improvements
- **Full Mobile Platform Support**: Added complete support for Android and iOS platforms
- **Modern Web APIs**: Replaced deprecated `dart:html` and `dart:js_util` with modern `dart:js_interop`, `dart:js_interop_unsafe`, and `package:web`
- **Bug Fixes**: Fixed multiple web-related issues for better stability and performance
- **Enhanced Compatibility**: Improved compatibility with latest Flutter and Dart versions

### 🙏 Attribution

This package is a fork of the original [m3u8_player](https://github.com/MendesCorporation/m3u8_player) created by [Helio Mendes](https://github.com/MendesCorporation). We extend our sincere gratitude to the original author for creating the foundation that made this enhanced version possible.

## 📱 Features

A Flutter package that provides a customizable M3U8 player for both mobile and web platforms.

![image](https://github.com/user-attachments/assets/c1151144-3daf-4107-9401-b13fd11ddf25)
![WhatsApp Image 2025-03-15 at 20 02 48](https://github.com/user-attachments/assets/a6155764-a998-4105-9806-3d3ce79007eb)
![WhatsApp Image 2025-03-15 at 20 02 49](https://github.com/user-attachments/assets/1fd392bc-fd76-47f5-8303-9a6c7b4dc43e)



[![Support Me on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/heliomendes)


## Features

- **Cross-platform Support**: Compatible with Android, iOS, and Web.
- **Customizable UI**: Easily customize the player's appearance to match your application's theme.
- **Playback Controls**: Play, pause, seek, adjust volume, playback speed, and quality of the stream.
- **Fullscreen Mode**: Toggle fullscreen mode seamlessly.
- **Progress Callbacks**: Receive progress updates at specified intervals.
- **Completion Callback and Threshold**: The player triggers an onCompleted callback when the playback reaches the specified completedPercentage (a value between 0 and 1; e.g., 1.0 indicates full completion).

## Getting Started

### Installation

Add `m3u8_player` to your project's `pubspec.yaml`:

```yaml
dependencies:
  m3u8_player_plus: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Usage

#### Import the Package

```dart
import 'package:m3u8_player_plus/m3u8_player_plus.dart';
```

#### Initialize PlayerConfig

Create a `PlayerConfig` to configure the player:

```dart
PlayerConfig config = PlayerConfig(
  url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
  autoPlay: true,
  loop: false,
  startPosition: 0,
  enableProgressCallback: true,
  progressCallbackInterval: 1,
  onProgressUpdate: (position) {
    // Handle progress update
    print('Current position: ${position.inSeconds} seconds');
  },
  onFullscreenChanged: (isFullscreen) {
    // Handle fullscreen change
    print('Fullscreen mode: $isFullscreen');
  },
  completedPercentage: 0.95,
  onCompleted:(){
  print('Video completo');
  },
  theme: PlayerTheme(
    primaryColor: Colors.blue,
    backgroundColor: Colors.black,
    bufferColor: Colors.grey,
    progressColor: Colors.red,
    iconSize: 24.0,
  ),
);
```

#### Embed M3u8PlayerWidget in Your Widget Tree

```dart
import 'package:flutter/material.dart';
import 'package:m3u8_player_plus/m3u8_player_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerConfig config = PlayerConfig(
      url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
      autoPlay: true,
      theme: PlayerTheme(
        primaryColor: Colors.blue,
      ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('M3U8 Player Example')),
        body: Center(
          child: M3u8PlayerWidget(config: config),
        ),
      ),
    );
  }
}
```

### Example

The `example` folder contains a complete example of how to use the `m3u8_player` package. To run the example:

1. Navigate to the `example` directory:

   ```bash
   cd example
   ```

2. Run the example app:

   ```bash
   flutter run
   ```

## API Documentation

### PlayerConfig

Configuration options for initializing the player.

- **url**: `String` - The HLS stream URL.
- **autoPlay**: `bool` - Enables or disables automatic playback on initialization. Default is `false`.
- **loop**: `bool` - Enables or disables looping of the stream. Default is `false`.
- **startPosition**: `int` - Specifies the initial playback position in seconds. Default is `0`.
- **enableProgressCallback**: `bool` - Enables progress updates with a specified interval. Default is `false`.
- **progressCallbackInterval**: `int` - Interval in seconds for the progress callback. Default is `1`.
- **onProgressUpdate**: `void Function(Duration)` - Callback for progress updates.
- **onFullscreenChanged**: `Function(bool)?` - Callback for fullscreen state changes.
- **onCompleted**: `Function(bool)?` - Callback for completed watch video.
- **completedPercentage**: `double` - value 0 to 1 for considering completed video.
- **theme**: `PlayerTheme` - Defines theming options for the player.

### PlayerTheme

Defines theming options for the player.

- **primaryColor**: `Color` - Primary color for icons and text.
- **backgroundColor**: `Color` - Background color of the player.
- **bufferColor**: `Color` - Color of the buffer progress.
- **progressColor**: `Color` - Color of the playback progress.
- **iconSize**: `double` - Size of the player icons.

### M3u8PlayerWidget

A widget that embeds the M3U8 Player into your Flutter application.

#### Constructor

```dart
M3u8PlayerWidget({
  Key? key,
  required PlayerConfig config,
})
```

- **config**: `PlayerConfig` - Configuration for initializing the player.

## Donate

If you liked this project, consider supporting it with a donation!

[![Support Me on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/heliomendes)


## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For support or inquiries, please contact [contato@apptrix.app](contato@apptrix.app).

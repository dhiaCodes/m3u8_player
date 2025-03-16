import 'package:flutter/material.dart';
import 'package:m3u8_player/m3u8_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M3U8 Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPlayerFullScreen = false;

  void _onFullScreenChanged(bool isFullscreen) {
    setState(() {
      _isPlayerFullScreen = isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isPlayerFullScreen ? null : AppBar(title: const Text('M3U8 Player Demo')),
      backgroundColor: const Color.fromARGB(221, 255, 255, 255),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: M3u8PlayerWidget(
            config: PlayerConfig(
              url: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
              autoPlay: true,
              startPosition: 15,
              enableProgressCallback: true,
              progressCallbackInterval: 15,
              onProgressUpdate: (position) {
                print('Posição atual: ${position.inSeconds} segundos');
              },
              completedPercentage: 0.95,
              onCompleted:(){
                print('Video completo');
              },
              onFullscreenChanged: _onFullScreenChanged,
              theme: const PlayerTheme(
                primaryColor: Colors.white,
                progressColor: Colors.red,
                backgroundColor: Colors.black54,
                bufferColor: Colors.white24,
                iconSize: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

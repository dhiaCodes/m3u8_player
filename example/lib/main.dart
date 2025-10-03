import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:m3u8_player_plus/m3u8_player_plus.dart';

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
  String url = ''; // add the video URL here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M3U8 Player Demo')),
      backgroundColor: const Color.fromARGB(221, 255, 255, 255),
      body: Center(
        child: url.isEmpty
            ? const Text('Please provide a valid M3U8 URL.')
            : Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: M3u8PlayerWidget(
                  config: PlayerConfig(
                    url: url,
                    autoPlay: true,
                    enableProgressCallback: true,
                    progressCallbackInterval: 15,
                    onProgressUpdate: (position) {
                      log('Posição atual: ${position.inSeconds} segundos');
                    },
                    completedPercentage: 0.95,
                    onCompleted: () {
                      log('Video Done');
                    },
                    onFullscreenChanged: (isFullscreen) {
                      log("Fullscreen changed: $isFullscreen");
                    },
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

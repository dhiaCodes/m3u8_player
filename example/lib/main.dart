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
  String url =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8'; // add the video URL here

  void _showVideoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            constraints: const BoxConstraints(
              maxWidth: 800,
              maxHeight: 600,
            ),
            child: Column(
              children: [
                // Dialog header with close button
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'M3U8 Video Player',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Video player
                Expanded(
                  child: M3u8PlayerWidget(
                    config: PlayerConfig(
                      url: url,
                      autoPlay: true,
                      enableProgressCallback: true,
                      progressCallbackInterval: 15,
                      onProgressUpdate: (position) {
                        log('Current position: $position seconds');
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M3U8 Player Demo')),
      backgroundColor: const Color.fromARGB(221, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'M3U8 Player Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: url.isEmpty ? null : _showVideoDialog,
              icon: const Icon(Icons.play_circle_filled),
              label: const Text('Open Video Player'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              url.isEmpty ? 'No video URL provided' : 'Ready to play video',
              style: TextStyle(
                color: url.isEmpty ? Colors.red : Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

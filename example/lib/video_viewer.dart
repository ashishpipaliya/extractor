
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoViewer extends StatefulWidget {
  final String url;
  const VideoViewer({Key? key,required this.url}) : super(key: key);

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
    const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Normal player page"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: _betterPlayerController.getAspectRatio()!,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ScreenPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLiveStream;

  const ScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.isLiveStream,
  });

  @override
  ScreenPlayerState createState() => ScreenPlayerState();
}
class ScreenPlayerState extends State<ScreenPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.videoUrl, widget.isLiveStream);
  }

  @override
  void didUpdateWidget(covariant ScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializePlayer(widget.videoUrl, widget.isLiveStream);
    }
  }

  Future<void> _initializePlayer(String videoUrl, bool isLiveStream) async {
    _disposeControllers();

    try {
      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController!.initialize();

      if (!_isDisposed) {
        setState(() {
          _setupChewieController(videoUrl, isLiveStream);
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
      print("Error initializing video: $e");
    }
  }

  void _setupChewieController(String videoUrl, bool isLiveStream) {
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      aspectRatio: _videoController!.value.aspectRatio,
      autoPlay: true,
      looping: false,
      showControls: true,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      additionalOptions: (context) {
        if (isLiveStream) {
          return <OptionItem>[
            OptionItem(
              iconData: Icons.video_settings,
              title: 'Quality',
              onTap: (context) => _showQualityOptions(context),
            ),
          ];
        }
        return [];
      },
    );
  }

  void _showQualityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.sd, color: Colors.white),
              title: const Text('360p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context, 'https://ott.mercytv.tv/hls_output/360p.m3u8', true),
            ),
            ListTile(
              leading: const Icon(Icons.hd, color: Colors.white),
              title: const Text('720p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context, 'https://ott.mercytv.tv/hls_output/720p.m3u8', true),
            ),
            ListTile(
              leading: const Icon(Icons.hd, color: Colors.white),
              title: const Text('1080p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(context,
                  'https://5dd3981940faa.streamlock.net:443/mercytv/mercytv/playlist.m3u8', true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeVideoQuality(
      BuildContext context, String videoUrl, bool isLiveStream) async {
    Navigator.pop(context);
    _initializePlayer(videoUrl, isLiveStream);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isVideoInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    return _isVideoInitialized && _chewieController != null
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator());
  }
}

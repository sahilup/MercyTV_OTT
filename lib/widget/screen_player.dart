import 'dart:async';
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

class ScreenPlayerState extends State<ScreenPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;
  bool _isLiveStream = false;
  bool _showButton = false;
  Timer? _hideButtonTimer;
  int _playerInitToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    final int currentToken = ++_playerInitToken;

    try {
      _videoController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: isLiveStream
            ? VideoPlayerOptions(
                mixWithOthers: true, allowBackgroundPlayback: true)
            : null,
      );

      await _videoController!.initialize();

      if (mounted && !_isDisposed && currentToken == _playerInitToken) {
        _isLiveStream = isLiveStream;
        _isVideoInitialized = true;
        _setupChewieController();
        if (isLiveStream) {
          _videoController!.play();
        }
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted && currentToken == _playerInitToken) {
        _isVideoInitialized = false;
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      }
      print("Error initializing video: $e");
    }
  }

  void _setupChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      aspectRatio: _videoController!.value.aspectRatio,
      autoPlay: true,
      looping: false,
      showControls: true,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: !_isLiveStream,
      isLive: false,
      fullScreenByDefault: false,
      additionalOptions: (context) {
        if (_isLiveStream) {
          return <OptionItem>[
            OptionItem(
              iconData: Icons.video_settings,
              title: 'Quality',
              onTap: (context) => _showQualityOptions(context),
            )
          ];
        }
        return [];
      },
    );
  }

  void _showQualityOptions(BuildContext context) {
    if (_isDisposed) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            _qualityOption(
                context, 'Auto', 'https://mercyott.com/hls_output/master.m3u8'),
            _qualityOption(
                context, '360p', 'https://mercyott.com/hls_output/360p.m3u8'),
            _qualityOption(
                context, '720p', 'https://mercyott.com/hls_output/720p.m3u8'),
            _qualityOption(
                context, '1080p', 'https://mercyott.com/hls_output/1080p.m3u8'),
          ],
        );
      },
    );
  }

  Widget _qualityOption(BuildContext context, String quality, String url) {
    return ListTile(
      leading: const Icon(Icons.hd, color: Colors.white),
      title: Text(quality, style: const TextStyle(color: Colors.white)),
      onTap: () => _changeVideoQuality(context, url),
    );
  }

  Future<void> _changeVideoQuality(
      BuildContext context, String videoUrl) async {
    // Close quality bottom sheet if open
    Navigator.pop(context);
    debugPrint('Changing quality to: $videoUrl');

    // Safely handle transition when changing quality
    if (_chewieController != null && _chewieController!.isFullScreen) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _initializePlayer(videoUrl, true);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _initializePlayer(videoUrl, true);
      }
    }
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _onScreenTapped() {
    setState(() {
      _showButton = true;
    });
    _hideButtonTimer?.cancel();
    _hideButtonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isDisposed) {
        setState(() => _showButton = false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _disposeControllers();
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isVideoInitialized && _chewieController != null
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator()),
          Listener(
            onPointerDown: (_) => _onScreenTapped(),
            behavior: HitTestBehavior.translucent,
          ),
          if (_showButton)
            Positioned(
              top: 22,
              left: 16,
              child: _liveButton(
                _isLiveStream ? 'Live' : 'Go Live',
                _isLiveStream ? Colors.red : const Color(0xFF8DBDCC),
                () => _initializePlayer(
                    'https://mercyott.com/hls_output/720p.m3u8', true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _liveButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      height: 20,
      width: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 11)),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';

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
  bool _isLiveStream = true;
  bool _showButton = true;
  Timer? _hideButtonTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer(widget.videoUrl, widget.isLiveStream);
    _listenToOrientationChanges();
    _startHideButtonTimer();
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
      _videoController = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: isLiveStream
            ? VideoPlayerOptions(
                mixWithOthers: true, allowBackgroundPlayback: true)
            : null,
      );
      await _videoController!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _setupChewieController(videoUrl, isLiveStream);
          _isVideoInitialized = true;
          _isLiveStream = isLiveStream;
        });

        if (isLiveStream) {
          _videoController!.play();
        }
      }
    } catch (e) {
      if (mounted) {
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
      showOptions: true,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: !isLiveStream,
      isLive: false,
      fullScreenByDefault: false,
      autoInitialize: true, // Use custom controls
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

  void _playLiveStream() {
    _initializePlayer('https://mercyott.com/hls_output/720p.m3u8', true);
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
              title: const Text('Auto', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context, 'https://mercyott.com/hls_output/master.m3u8', true),
            ),
            ListTile(
              leading: const Icon(Icons.sd, color: Colors.white),
              title: const Text('360p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context, 'https://mercyott.com/hls_output/360p.m3u8', true),
            ),
            ListTile(
              leading: const Icon(Icons.hd, color: Colors.white),
              title: const Text('720p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context, 'https://mercyott.com/hls_output/720p.m3u8', true),
            ),
            ListTile(
              leading: const Icon(Icons.hd, color: Colors.white),
              title: const Text('1080p', style: TextStyle(color: Colors.white)),
              onTap: () => _changeVideoQuality(
                  context,
                  'https://mercyott.com/hls_output/1080p.m3u8',
                  true),
            ),
          ],
        );
      },
    );
  } // Use custom controls

  Future<void> _changeVideoQuality(
      BuildContext context, String videoUrl, bool isLiveStream) async {
    if (mounted) {
      Navigator.pop(context);
    }
    _initializePlayer(videoUrl, isLiveStream);
  }

  void _listenToOrientationChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final mediaQuery = MediaQuery.of(context);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orientation = mediaQuery.orientation;
      if (_chewieController != null) {
        if (orientation == Orientation.landscape &&
            !_chewieController!.isFullScreen) {
          _chewieController!.enterFullScreen();
        } else if (orientation == Orientation.portrait &&
            _chewieController!.isFullScreen) {
          _chewieController!.exitFullScreen();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.initState();
    _isDisposed = true;
    _disposeControllers();
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _startHideButtonTimer() {
    _hideButtonTimer?.cancel();
    _hideButtonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showButton = false;
        });
      }
    });
  }

  void _onScreenTapped() {
    log("presses",name: "live");
    setState(() {
      _showButton = true;
    });
    _startHideButtonTimer();
  }

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque, // Important! Captures taps anywhere.
    onTap: _onScreenTapped,
    child: Stack(
      children: [
        _isVideoInitialized && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Center(child: CircularProgressIndicator()),
        if (_showButton)
          Positioned(
            top: 20,
            left: 16,
            child: _liveButton(
              _isLiveStream ? 'Live' : 'Go Live',
              _isLiveStream ? Colors.red : const Color(0xFF8DBDCC),
              _playLiveStream,
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
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state) onChange;

  LifecycleEventHandler({required this.onChange});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }
}

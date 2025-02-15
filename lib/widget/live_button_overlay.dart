import 'dart:async';
import 'package:flutter/material.dart';

class LiveButtonOverlay extends StatefulWidget {
  const LiveButtonOverlay({super.key});

  @override
  State<LiveButtonOverlay> createState() => _LiveButtonOverlayState();
}

class _LiveButtonOverlayState extends State<LiveButtonOverlay> {
  bool _showButton = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel(); // Cancel any existing timer
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showButton = false;
      });
    });
  }

  void _handleTap() {
    setState(() {
      _showButton = true;
    });
    _startHideTimer(); // Restart the hide timer
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Ensures the tap is detected anywhere on the screen
        onTap: _handleTap,
        child: Stack(
          children: [
            // Your background or video player widget here
            Container(color: Colors.black), // Placeholder background

            // Conditionally show the "Live" button
            if (_showButton)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.red,
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

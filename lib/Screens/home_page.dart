import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mercy_tv_app/Colors/custom_color.dart';
import 'package:mercy_tv_app/widget/button_section.dart';
import 'package:mercy_tv_app/widget/screen_player.dart';
import 'package:mercy_tv_app/API/dataModel.dart';
import 'package:mercy_tv_app/widget/sugested_video_list.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFavorite = false;
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _currentVideoUrl = 'https://ott.mercytv.tv/hls_output/master.m3u8';
  bool _isLiveStream = true;
  String _selectedProgramTitle = 'Mercy TV Live';
  String _selectedProgramDate = '';
  String _selectedProgramTime = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://mercytv.tv/support-ott/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _playVideo(ProgramDetails programDetails) {
    setState(() {
      _currentVideoUrl = programDetails.videoUrl;
      _isLiveStream = false;
      _selectedProgramTitle = programDetails.title;

      // Date Formatting
      if (programDetails.date != null && programDetails.date!.isNotEmpty) {
        try {
          DateTime parsedDate =
              DateFormat('yyyy-MM-dd').parse(programDetails.date!);
          _selectedProgramDate = DateFormat('EEE dd MMM').format(parsedDate);
        } catch (e) {
          _selectedProgramDate = programDetails.date!;
        }
      } else {
        _selectedProgramDate = '';
      }

      // Time Formatting
      if (programDetails.time != null && programDetails.time!.isNotEmpty) {
        try {
          DateTime parsedTime =
              DateFormat('HH:mm:ss').parse(programDetails.time!);
          _selectedProgramTime = DateFormat('hh:mm a').format(parsedTime);
        } catch (e) {
          _selectedProgramTime = programDetails.time!;
        }
      } else {
        _selectedProgramTime = '';
      }
    });
  }

  void _playLiveStream() {
    setState(() {
      _currentVideoUrl = 'https://ott.mercytv.tv/hls_output/master.m3u8';
      _isLiveStream = true;
      _selectedProgramTitle = 'Mercy TV Live';
      _selectedProgramDate = '';
      _selectedProgramTime = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _selectedProgramDate.isNotEmpty
        ? _selectedProgramDate
        : DateFormat('EEE dd MMM').format(_currentDateTime);
    String formattedTime = _selectedProgramTime.isNotEmpty
        ? _selectedProgramTime
        : DateFormat('hh:mm a').format(_currentDateTime);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color.fromARGB(255, 0, 90, 87),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.9],
          ),
        ),
        child: Column(
          children: [
            // Video Player at the Top
            SizedBox(
              height: 250,
              child: ScreenPlayer(
                videoUrl: _currentVideoUrl,
                isLiveStream: _isLiveStream,
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.7, // Limit title to 70% of width
                            child: GestureDetector(
                              onTap: _playLiveStream, // Switch back to Live
                              child: Text(
                                _selectedProgramTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Prevent overflow, add "..."
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!_isLiveStream)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(360),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 3),
                              child: IconButton(
                                onPressed: _playLiveStream,
                                icon: const Icon(
                                  Icons.live_tv,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          const Text("|",
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ButtonSection(),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _launchURL,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow
                                    .withOpacity(0.6), // Yellow shadow
                                spreadRadius: 0.1,
                                blurRadius: 10,
                                offset: const Offset(
                                    0, 1), // Shadow only at the bottom
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sponsor Us',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      const Text(
                        'Past Programs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                          width: 138,
                          height: 2,
                          color: CustomColors.buttonColor),
                      SuggestedVideoCard(
                        onVideoTap: _playVideo,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

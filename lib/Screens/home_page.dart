import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mercy_tv_app/Colors/custom_color.dart';
import 'package:mercy_tv_app/Screens/profile_page.dart';
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
    final Uri url = Uri.parse('https://mercytv.tv/support/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _playVideo(ProgramDetails programDetails) {
    setState(() {
      _currentVideoUrl = programDetails.videoUrl;
      _isLiveStream = false;
      _selectedProgramTitle = programDetails.title;
      _selectedProgramDate = programDetails.date ?? '';
      _selectedProgramTime = programDetails.time ?? '';
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
      appBar: AppBar(
        title: const Text('Mercy TV'),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Mercy TV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
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
                          GestureDetector(
                            onTap: _playLiveStream, // Switch back to Live
                            child: Text(
                              _selectedProgramTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Conditionally display the "Live" button
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
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 36,
                              width: 36,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Mercy TV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _launchURL,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Donate',
                                    style: TextStyle(
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isFavorite = !isFavorite;
                                      });
                                    },
                                    child: Icon(
                                      isFavorite
                                          ? Icons.volunteer_activism
                                          : Icons.volunteer_activism_outlined,
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const ButtonSection(),
                      const Divider(color: Colors.grey, thickness: 1),
                      const Text(
                        'Past Programs',
                        style: TextStyle(
                          color: CustomColors.buttonColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(width: 138, height: 2, color: Colors.red),
                      const SizedBox(height: 10),
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

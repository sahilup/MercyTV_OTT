import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mercy_tv_app/Colors/custom_color.dart';
import 'package:mercy_tv_app/controllers/home_controller.dart';
import 'package:mercy_tv_app/controllers/rotation_helper.dart';
import 'package:mercy_tv_app/widget/Live_View_widget.dart';
import 'package:mercy_tv_app/widget/button_section.dart';
import 'package:mercy_tv_app/widget/new_screen_player.dart';
import 'package:mercy_tv_app/API/dataModel.dart';
import 'package:mercy_tv_app/widget/sugested_video_list.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFavorite = false;
  Timer? _timer;
  DateTime _currentDateTime = DateTime.now();
  // ignore: unused_field
  String _currentVideoUrl = 'https://mercyott.com/hls_output/master.m3u8';
  bool _isLiveStream = true;
  String _selectedProgramTitle = 'Mercy TV Live';
  String _selectedProgramDate = '';
  String _selectedProgramTime = '';
  StreamSubscription? _orientationSubscription;
  Stream<bool>? rotationStream;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WakelockPlus.enable();
    _startOrientationListener();
    rotationStream = RotationHelper.autoRotateStream;
    // accelerometerEventStream().listen((AccelerometerEvent event) {
    //   log("Test Accelerometer: x=${event.x}, y=${event.y}, z=${event.z}");
    // });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orientationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://mercytv.tv/support-ott/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _playVideo(ProgramDetails programDetails) {
    if (!mounted) return;
    setState(() {
      _currentVideoUrl = programDetails.videoUrl;
      _isLiveStream = false;
      _selectedProgramTitle = programDetails.title;
      final HomeController homeController = Get.put(HomeController());
      homeController.initializePlayer(programDetails.videoUrl, false);

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

  Stream<Orientation?> detectOrientation() async* {
    await for (bool autoRotateOn in RotationHelper.autoRotateStream) {
      log("Auto-rotate stream emitted: $autoRotateOn");
      if (!autoRotateOn) {
        log("Auto-rotate is OFF, ignoring orientation changes.");
        yield null;
        continue; // Skip detecting orientation changes
      }

      await for (AccelerometerEvent event in accelerometerEventStream()) {
        log("Accelerometer Event: x=${event.x}, y=${event.y}, z=${event.z}");
        double x = event.x; // Horizontal tilt
        double y = event.y; // Vertical tilt
        double z = event.z; // Flat detection

        // Ignore changes if the device is lying flat
        if (z.abs() > 8) {
          log("Device is flat, ignoring orientation change.");
          yield null;
          continue;
        }

        if (y.abs() > x.abs()) {
          yield Orientation.portrait;
        } else {
          yield Orientation.landscape;
        }
      }
    }
  }

  void _startOrientationListener() async {
    final HomeController homeController = Get.put(HomeController());
    log("inside orientation listener");

    _orientationSubscription = detectOrientation().listen((orientation) {
      log("Orientation detected: $orientation");

      if (orientation != null &&
          homeController.currentOrientation.value != orientation) {
        homeController.currentOrientation.value = orientation;

        if (orientation == Orientation.landscape) {
          log("Switching to Landscape mode");
          Future.delayed(const Duration(milliseconds: 100), () {
            homeController.chewieController?.enterFullScreen();
          });
        } else {
          log("Switching to Portrait mode");
          Future.delayed(const Duration(milliseconds: 100), () {
            homeController.chewieController?.exitFullScreen();
          });
        }
      }
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
            SizedBox(
              height: 250,
              child: NewScreenPlayer(),
            ),
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
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: GestureDetector(
                              child: Text(
                                _selectedProgramTitle,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Mulish-Bold'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          if (_isLiveStream)
                            const Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: LiveViewWidget(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Mulish-Medium'),
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
                      const ButtonSection(),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _launchURL,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Center(
                            child: Text(
                              'Sponsor us',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Mulish-Medium'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Past Programs',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Mulish-Medium'),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 138,
                        height: 2,
                        color: CustomColors.buttonColor,
                      ),
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

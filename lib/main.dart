import 'package:flutter/material.dart';
import 'package:mercy_tv_app/Screens/Splash_screen.dart';
import 'package:mercy_tv_app/widget/orientaton_listner.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home:  OrientationListenerWidget(onOrientationChange: (Orientation ) { print("orientation chnage"); },
      child: SplashScreen()),
    );
  }
}


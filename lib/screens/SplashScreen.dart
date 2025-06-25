import 'package:HostelMate/screens/SelectRole.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    wrapper();
  }
  void wrapper ()
  async {
    await Future.delayed(const Duration(seconds: 3));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelectRolePage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // white background
      body: Center(
        child: Image.asset(
          'assets/images/hostelmate.png',
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          fit: BoxFit.contain, // keep original aspect ratio, no cut-off
        ),
      ),
    );
  }
}

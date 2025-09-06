import 'package:HostelMate/screens/SelectRole.dart';
import 'package:HostelMate/admin/AdminLogin.dart';
import 'package:HostelMate/hostelite/HSignIn.dart';
import 'package:HostelMate/admin/ADashboard.dart';
import 'package:HostelMate/hostelite/HDashboard.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
  void wrapper () async {
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is the first time opening the app
    final isFirstTime = prefs.getBool('is_first_time') ?? true;
    
    if (isFirstTime) {
      // First time - show SelectRole page
      await prefs.setBool('is_first_time', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelectRolePage()),
      );
    } else {
      // Check if user has "Remember Me" enabled
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe) {
        // Check if user is admin or regular user
        final isAdmin = prefs.getBool('is_admin') ?? false;
        final hasHosteliteId = prefs.getString('hostelite_id') != null;
        
        if (isAdmin) {
          // Navigate to admin dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ADashboard()),
          );
        } else if (hasHosteliteId) {
          // Navigate to hostelite dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HDashboard()),
          );
        } else {
          // No valid session - show SelectRole page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SelectRolePage()),
          );
        }
      } else {
        // Remember Me not checked - show SelectRole page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SelectRolePage()),
        );
      }
    }
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

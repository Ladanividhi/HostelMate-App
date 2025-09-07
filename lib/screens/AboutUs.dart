import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primary_color,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "About Us",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.home_work_rounded, color: primary_color, size: 80),
              SizedBox(height: 20),
              Text(
                "HostelMate",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primary_color,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "A smart and simple hostel management solution built to ease administrative operations and enhance hostelite experience.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 30),

              // Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        "In Coordination",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Vidhi Ladani\nHarmi Kotak",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          color: Colors.black87,
                        ),
                      ),
                      Divider(height: 30, thickness: 0.8),
                      Text(
                        "Contact Us",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "hostelmate.app@gmail.com",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Version info footer
              Text(
                "App Version 1.0.0",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

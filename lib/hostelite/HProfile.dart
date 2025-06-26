import 'package:HostelMate/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class HProfilePage extends StatefulWidget {
  @override
  State<HProfilePage> createState() => _HProfilePageState();
}

class _HProfilePageState extends State<HProfilePage> {
  Map<String, String> userProfile = {
    "name": "Vidhi Ladani",
    "hostelId": "H001",
    "room": "302",
    "bed": "B",
    "college": "Dharmsinh Desai University",
    "course": "Computer Engineering",
    "email": "vidhi@gmail.com",
    "phone": "9999988888",
    "address": "Rajkot",
    "fatherName": "Avanish Ladani",
    "motherName": "Reshma Ladani",
    "fatherContact": "9999911111",
    "motherContact": "9999922222",
    "guardianEmail": "avanish@gmail.com",
  };

  void onMenuSelected(String value) {
    if (value == 'edit') {
      // navigate to Edit Profile page or show dialog
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Edit Profile clicked")));
    } else if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primary_color,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "My Profile",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              color: Colors.white, // popup background color
              elevation: 8, // shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: primary_color),
                      SizedBox(width: 10),
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20, color: primary_color),
                      SizedBox(width: 10),
                      Text(
                        "Settings",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primary_color.withOpacity(0.2),
                child: Text(
                  userProfile["name"]![0],
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    color: primary_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                userProfile["name"]!,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primary_color,
                ),
              ),
            ),
            SizedBox(height: 28),

            // Profile details
            ...userProfile.entries.map((entry) => profileRow(entry.key, entry.value)),

          ],
        ),
      ),
    );
  }

  Widget profileRow(String title, String value) {
    // Make title readable
    String formattedTitle = title
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .replaceAll('Id', 'ID')
        .replaceFirst(title[0], title[0].toUpperCase());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: bg_color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          title: Text(
            formattedTitle,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

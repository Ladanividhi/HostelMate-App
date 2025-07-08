import 'package:HostelMate/admin/AFaqs.dart';
import 'package:HostelMate/hostelite/HFaqs.dart';
import 'package:HostelMate/screens/AboutUs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            "Settings",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            settingTile(
              icon: Icons.phone_in_talk_outlined,
              label: "Contact Information",
              onTap: () {
                // Navigate or show info dialog
              },
            ),
            settingTile(
              icon: Icons.article_outlined,
              label: "Terms & Conditions",
              onTap: () {},
            ),
            settingTile(
              icon: Icons.help_outline,
              label: "Help",
              onTap: () {},
            ),
            settingTile(
              icon: Icons.question_answer_outlined,
              label: "FAQs",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AFaqsPage()),
                );
              },
            ),
            settingTile(
              icon: Icons.info_outline,
              label: "About Us",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
            ),
            settingTile(
              icon: Icons.logout,
              label: "Log Out",
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              onTap: () {
                // Add logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = primary_color,
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: bg_color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
          onTap: onTap,
        ),
      ),
    );
  }
}

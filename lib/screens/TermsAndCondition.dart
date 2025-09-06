import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/Constants.dart';
import 'package:flutter/services.dart';

class TermsAndConditionPage extends StatefulWidget {
  @override
  State<TermsAndConditionPage> createState() => _TermsAndConditionPageState();
}

class _TermsAndConditionPageState extends State<TermsAndConditionPage> {
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
            "Terms & Conditions",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                color: Colors.grey[200],
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description,
                        size: 48,
                        color: primary_color,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "HostelMate Terms & Conditions",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Terms Content
              _buildSection(
                "1. Acceptance of Terms",
                "By using the HostelMate application, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.",
                Icons.check_circle,
              ),
              
              _buildSection(
                "2. User Responsibilities",
                "• Provide accurate and complete information during registration\n• Maintain the confidentiality of your account credentials\n• Use the application in compliance with hostel rules and regulations\n• Report any security breaches or suspicious activities immediately\n• Respect other users' privacy and maintain appropriate conduct",
                Icons.person,
              ),
              
              _buildSection(
                "3. Prohibited Activities",
                "• Sharing false or misleading information\n• Attempting to gain unauthorized access to the system\n• Using the application for illegal or unauthorized purposes\n• Harassing, threatening, or abusing other users\n• Violating any applicable laws or regulations",
                Icons.block,
              ),
              
              _buildSection(
                "4. Privacy and Data Protection",
                "We are committed to protecting your privacy and personal information. Your data will be used only for the purposes stated in our Privacy Policy and will not be shared with third parties without your consent, except as required by law.",
                Icons.privacy_tip,
              ),
              
              _buildSection(
                "5. Service Availability",
                "We strive to maintain continuous service availability but cannot guarantee uninterrupted access. The application may be temporarily unavailable due to maintenance, updates, or technical issues.",
                Icons.settings,
              ),
              
              _buildSection(
                "5. Intellectual Property",
                "All content, features, and functionality of the HostelMate application are owned by the hostel management and are protected by copyright, trademark, and other intellectual property laws.",
                Icons.copyright,
              ),
              
              _buildSection(
                "7. Limitation of Liability",
                "The hostel management shall not be liable for any indirect, incidental, special, or consequential damages arising from the use of this application, including but not limited to loss of data or business interruption.",
                Icons.warning,
              ),
              
              _buildSection(
                "8. Modifications",
                "We reserve the right to modify these Terms and Conditions at any time. Users will be notified of significant changes, and continued use of the application constitutes acceptance of the modified terms.",
                Icons.edit,
              ),

              
              SizedBox(height: 20),
              
              // Agreement Card
              Card(
                color: Colors.green[50],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "By using HostelMate, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      color: bg_color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: primary_color,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

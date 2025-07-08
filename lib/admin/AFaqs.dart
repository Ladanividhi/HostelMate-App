import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class AFaqsPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How can I approve a gatepass request?",
      "answer": "Go to the 'Gatepass Requests' page, switch to the 'Pending' tab, and click the 'Approve' button for the request."
    },
    {
      "question": "Can I view vacant rooms and beds?",
      "answer": "Yes, the 'Vacancy' page shows all available room and bed numbers in the hostel."
    },
    {
      "question": "Where can I track complaints from hostelites?",
      "answer": "Navigate to the 'Complaints' page to view all complaints. Mark them as 'Action Taken' after resolving."
    },
    {
      "question": "How do I manage hostelite profiles?",
      "answer": "Go to the 'Hostelites' section to view, search, and manage hostelite details."
    },
    {
      "question": "How do I mark a complaint as resolved?",
      "answer": "Click on the 'Action Taken' button in the complaint card, enter the action details, and save."
    },
    {
      "question": "Can I scan a hostelite's QR code?",
      "answer": "Yes, use the 'QR Scanner' page from the admin dashboard to scan and retrieve hostelite data."
    },
    {
      "question": "How can I log out from the admin panel?",
      "answer": "Use the 'Log Out' option in the Settings menu available on your admin dashboard."
    },
    {
      "question": "Is there a way to filter gatepasses by status?",
      "answer": "Yes, you can toggle between 'Pending' and 'Approved' using radio buttons at the top of the Gatepass Requests page."
    },
    {
      "question": "How do I update an admin's own profile?",
      "answer": "Go to your profile section, click on the menu, and select 'Edit Profile' to update details."
    },
    {
      "question": "Where can I view help or support info?",
      "answer": "The 'About Us' and 'FAQs' pages in the admin dashboard provide essential app and support information."
    },
  ];

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
            "FAQs",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Card(
                color: bg_color,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      faq["question"]!,
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: primary_color,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          faq["answer"]!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

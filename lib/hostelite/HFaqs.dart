import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class HFaqsPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I apply for a gatepass?",
      "answer": "Go to the Gatepass section in your dashboard, fill in the details, and click on 'Generate Gatepass'."
    },
    {
      "question": "Can I edit my profile information?",
      "answer": "Yes, click on the three-dot menu in the Profile section and select 'Edit Profile' to update your details."
    },
    {
      "question": "What happens if my parent doesn't approve my gatepass?",
      "answer": "Your request will remain pending until your parent approves it via the system link."
    },
    {
      "question": "How to check my room allotment?",
      "answer": "You can view your room number in the Hostelites section or in your profile page."
    },
    {
      "question": "Where can I raise a complaint?",
      "answer": "Go to the Complaints section, fill in the complaint form, and submit it. The admin will review it shortly."
    },
    {
      "question": "Can I change my room?",
      "answer": "Room changes are subject to availability and admin approval. Contact the hostel warden for further process."
    },
    {
      "question": "How do I log out of the app?",
      "answer": "Go to Settings from the menu and tap on 'Log Out' option at the bottom."
    },
    {
      "question": "How can I check vacant rooms?",
      "answer": "The 'Vacancy' page in the admin section lists all available rooms and bed numbers."
    },
    {
      "question": "What if I forget my login credentials?",
      "answer": "Use the 'Forgot Password' option on the login page to reset your credentials via registered email."
    },
    {
      "question": "How do I contact support?",
      "answer": "You can reach out to us at hostelmate.app@gmail.com for any app-related queries or technical support."
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

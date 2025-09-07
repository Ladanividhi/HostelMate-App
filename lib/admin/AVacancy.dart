import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class AVacancyPage extends StatefulWidget {
  @override
  State<AVacancyPage> createState() => _AVacancyPageState();
}

class _AVacancyPageState extends State<AVacancyPage> {
  // Mock vacancy data
  final List<Map<String, String>> vacancies = [
    {"room": "101", "bed": "A"},
    {"room": "101", "bed": "B"},
    {"room": "205", "bed": "C"},
    {"room": "305", "bed": "A"},
    {"room": "408", "bed": "D"},
    {"room": "510", "bed": "B"},
    {"room": "603", "bed": "C"},
    {"room": "701", "bed": "A"},
  ];

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
            "Vacancy List",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: vacancies.length,
                itemBuilder: (context, index) {
                  final vacancy = vacancies[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      color: bg_color,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          "Room No: ${vacancy["room"]}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primary_color,
                          ),
                        ),
                        subtitle: Text(
                          "Bed No: ${vacancy["bed"]}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        leading: Icon(
                          Icons.hotel,
                          color: primary_color,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class HHostelitePage extends StatefulWidget {
  @override
  State<HHostelitePage> createState() => _HHostelitePageState();
}

class _HHostelitePageState extends State<HHostelitePage> {
  List<Map<String, String>> hostelites = [
    {"name": "Vidhi Ladani", "room": "302"},
    {"name": "Riya Shah", "room": "101"},
    {"name": "Mihir Joshi", "room": "205"},
    {"name": "Sneha Patel", "room": "303"},
    {"name": "Ankit Mehta", "room": "102"},
    {"name": "Dhruv Shah", "room": "305"},
    {"name": "Nidhi Sharma", "room": "104"},
    {"name": "Yashraj Chauhan", "room": "308"},
    {"name": "Tanvi Desai", "room": "210"},
    {"name": "Aarav Soni", "room": "106"},
  ];

  List<Map<String, String>> filteredHostelites = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredHostelites = hostelites;
  }

  void searchHostelite(String query) {
    final results = hostelites.where((h) {
      final name = h["name"]!.toLowerCase();
      final room = h["room"]!;
      final input = query.toLowerCase();

      return name.contains(input) || room.contains(input);
    }).toList();

    setState(() {
      filteredHostelites = results;
    });
  }

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
            "Hostelites",
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
            SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: searchHostelite,
                decoration: InputDecoration(
                  hintText: "Search by name or room number",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),

            SizedBox(height: 16),

            // Hostelites List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredHostelites.length,
                itemBuilder: (context, index) {
                  final h = filteredHostelites[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      color: bg_color,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h["name"]!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary_color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Room No: ${h["room"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
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

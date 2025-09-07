import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HHostelitePage extends StatefulWidget {
  @override
  State<HHostelitePage> createState() => _HHostelitePageState();
}

class _HHostelitePageState extends State<HHostelitePage> {
  List<Map<String, String>> hostelites = [];
  List<Map<String, String>> filteredHostelites = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHostelites();
    debugPrintRooms();
  }

  Future<void> fetchHostelites() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      final List<Map<String, String>> loadedHostelites = snapshot.docs
          .map((doc) {
        final data = doc.data();

        // Extract fields
        final email = (data["Email"] ?? "").toString().trim();
        final name = (data["Name"] ?? "Unknown").toString();
        final room = (data["RoomNumber"] ?? "N/A").toString();

        return {
          "email": email,
          "name": name,
          "room": room,
        };
      })
      // Filter out users whose email == "a"
          .where((hostelite) => hostelite["email"]?.toLowerCase() != "a")
          .toList();

      setState(() {
        hostelites = loadedHostelites;
        filteredHostelites = loadedHostelites;
      });
    } catch (e) {
      print("Error fetching hostelites: $e");
    }
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
  Future<void> debugPrintRooms() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .get();

      if (snapshot.docs.isEmpty) {
        print("No rooms found.");
        return;
      }

      // Print header
      print("Room ID\t\tStatus\t\tOther Fields");
      print("=====================================");

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final roomId = doc.id;
        final status = data["status"] ?? "N/A";

        // Print row (add other fields as needed)
        print("$roomId\t\t$status\t\t$data");
      }
    } catch (e) {
      print("Error fetching rooms: $e");
    }
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AVacancyPage extends StatefulWidget {
  @override
  State<AVacancyPage> createState() => _AVacancyPageState();
}

class _AVacancyPageState extends State<AVacancyPage> {
  String searchQuery = "";
  String filterAC = "All"; // All, AC, Non-AC

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
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Vacancy List",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        body: Column(
          children: [
            // ✅ SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value.trim());
                },
                decoration: InputDecoration(
                  hintText: "Search Room or Bed Number...",
                  prefixIcon: Icon(Icons.search, color: primary_color),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),

            // ✅ FILTER CHIP ROW
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                children: [
                  filterChip("All"),
                  SizedBox(width: 10),
                  filterChip("AC"),
                  SizedBox(width: 10),
                  filterChip("Non-AC"),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Rooms")
                    .where("Status", isEqualTo: false) // only vacant
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No vacant rooms available",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }

                  // ✅ Convert docs into list
                  List rooms = snapshot.data!.docs.map((doc) {
                    return doc.data() as Map<String, dynamic>;
                  }).toList();

                  // ✅ Apply filter AC/Non-AC
                  if (filterAC == "AC") {
                    rooms = rooms.where((r) => r["AC"] == true).toList();
                  } else if (filterAC == "Non-AC") {
                    rooms = rooms.where((r) => r["AC"] == false).toList();
                  }

                  // ✅ Apply search filter
                  if (searchQuery.isNotEmpty) {
                    rooms = rooms.where((room) {
                      final roomNo = room["RoomNumber"].toString();
                      final bedNo = room["BedNumber"].toString();
                      return roomNo.contains(searchQuery) ||
                          bedNo.contains(searchQuery);
                    }).toList();
                  }

                  // ✅ Sort ascending by RoomNumber
                  rooms.sort((a, b) =>
                      a["RoomNumber"].toString().compareTo(b["RoomNumber"].toString()));

                  if (rooms.isEmpty) {
                    return Center(
                      child: Text(
                        "No rooms match your filters",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];

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
                            leading: Icon(
                              Icons.hotel,
                              color: primary_color,
                              size: 30,
                            ),
                            title: Text(
                              "Room No: ${room["RoomNumber"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary_color,
                              ),
                            ),
                            subtitle: Text(
                              "Bed No: ${room["BedNumber"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: room["AC"] == true
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                room["AC"] == true ? "AC" : "Non-AC",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: room["AC"] == true
                                      ? Colors.blue[900]
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ✅ Filter Chip builder
  Widget filterChip(String label) {
    final bool selected = filterAC == label;

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
      selected: selected,
      selectedColor: primary_color,
      onSelected: (_) {
        setState(() => filterAC = label);
      },
      backgroundColor: Colors.grey[300],
      labelPadding: EdgeInsets.symmetric(horizontal: 14),
    );
  }
}
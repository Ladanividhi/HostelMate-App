import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class ARequestsPage extends StatefulWidget {
  @override
  _ARequestsPageState createState() => _ARequestsPageState();
}

class _ARequestsPageState extends State<ARequestsPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> requests = [
    {
      "message": "Need extra pillow",
      "name": "Vidhi Ladani",
      "room": "302",
      "date": "24-06-2025",
      "status": "Pending",
    },
    {
      "message": "Fan not working",
      "name": "Isha Patel",
      "room": "301",
      "date": "23-06-2025",
      "status": "Completed",
    },
    {
      "message": "Request for room cleaning",
      "name": "Krish Mehta",
      "room": "305",
      "date": "24-06-2025",
      "status": "Pending",
    },
    {
      "message": "Electric socket broken",
      "name": "Saanvi Joshi",
      "room": "310",
      "date": "22-06-2025",
      "status": "Completed",
    },
    // Add more static request records here
  ];

  List<Map<String, String>> filteredRequests = [];

  @override
  void initState() {
    super.initState();
    filteredRequests = requests;
  }

  void searchRequest(String query) {
    final result = requests.where((r) {
      final message = r["message"]!.toLowerCase();
      final name = r["name"]!.toLowerCase();
      final room = r["room"]!;
      final input = query.toLowerCase();

      return message.contains(input) ||
          name.contains(input) ||
          room.contains(input);
    }).toList();

    setState(() {
      filteredRequests = result;
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
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: primary_color,
            elevation: 0,
            title: Text(
              "Requests",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: searchController,
                    onChanged: searchRequest,
                    decoration: InputDecoration(
                      hintText: "Search by message, name or room no.",
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 18),

                // List of requests
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final r = filteredRequests[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          color: bg_color,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                r["message"]!,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primary_color,
                                ),
                              ),
                              subtitle: Text(
                                "From: ${r["name"]} | Room: ${r["room"]}",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              children: [
                                detailRow("Request Message", r["message"]!),
                                detailRow("Name", r["name"]!),
                                detailRow("Room", r["room"]!),
                                detailRow("Date", r["date"]!),
                                detailRow("Status", r["status"]!),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

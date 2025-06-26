import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class AComplaintsPage extends StatefulWidget {
  @override
  State<AComplaintsPage> createState() => _AComplaintsPageState();
}

class _AComplaintsPageState extends State<AComplaintsPage> {
  String selectedStatus = "Pending";

  List<Map<String, dynamic>> complaints = [
    {
      "name": "Vidhi Ladani",
      "hostelId": "H001",
      "room": "302",
      "date": "2025-06-24",
      "message": "Water leakage in bathroom.",
      "status": "Pending",
      "remarks": ""
    },
    {
      "name": "Riya Shah",
      "hostelId": "H002",
      "room": "101",
      "date": "2025-06-23",
      "message": "Fan not working.",
      "status": "Action Taken",
      "remarks": "Fan replaced by maintenance staff."
    },
    // Add more dummy complaints if needed
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
            "Complaints",
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

            // Radio buttons for status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: "Pending",
                  groupValue: selectedStatus,
                  activeColor: primary_color,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                Text("Pending", style: GoogleFonts.poppins(fontSize: 14)),

                SizedBox(width: 20),
                Radio<String>(
                  value: "Action Taken",
                  groupValue: selectedStatus,
                  activeColor: primary_color,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
                Text("Action Taken", style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),

            SizedBox(height: 10),

            // List of complaints
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final c = complaints[index];
                  if (c["status"] != selectedStatus) return SizedBox();

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
                              c["name"],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary_color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Hostel ID: ${c["hostelId"]} | Room: ${c["room"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            detailRow("Date", c["date"]),
                            detailRow("Complaint", c["message"]),
                            detailRow("Status", c["status"]),
                            if (c["status"] == "Action Taken")
                              detailRow("Remarks", c["remarks"]),

                            // Action Taken button if Pending
                            if (c["status"] == "Pending") ...[
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  showActionDialog(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary_color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Mark as Action Taken",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white),
                                ),
                              )
                            ]
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

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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

  void showActionDialog(int index) {
    final TextEditingController remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bg_color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Enter Action Taken",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: primary_color,
          ),
        ),
        content: TextField(
          controller: remarksController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Describe the action taken",
            hintStyle: GoogleFonts.poppins(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey.shade800),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                complaints[index]["status"] = "Action Taken";
                complaints[index]["remarks"] = remarksController.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Save",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

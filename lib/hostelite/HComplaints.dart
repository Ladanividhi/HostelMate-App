import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class HComplaintPage extends StatefulWidget {
  @override
  State<HComplaintPage> createState() => _HComplaintPageState();
}

class _HComplaintPageState extends State<HComplaintPage> {
  final TextEditingController complaintController = TextEditingController();

  List<Map<String, dynamic>> previousComplaints = [
    {
      "date": "2025-06-23",
      "message": "Water leakage in room.",
      "status": "Pending"
    },
    {
      "date": "2025-06-18",
      "message": "Light not working in bathroom.",
      "status": "Action Taken"
    },
  ];

  void submitComplaint() {
    if (complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a complaint message")),
      );
      return;
    }

    setState(() {
      previousComplaints.insert(0, {
        "date": DateTime.now().toString().substring(0, 10),
        "message": complaintController.text,
        "status": "Pending"
      });
      complaintController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Complaint Submitted")),
    );
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
            "My Complaints",
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
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Text(
                    "New Complaint",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  SizedBox(height: 14),

                  TextField(
                    controller: complaintController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Type your complaint here",
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),

                  SizedBox(height: 26),

                  Text(
                    "Previous Complaints",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  SizedBox(height: 12),

                  ...previousComplaints.map((c) => Padding(
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
                            detailRow("Date", c["date"]),
                            detailRow("Complaint", c["message"]),
                            detailRow("Status", c["status"]),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // Sticky Submit Button
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Submit Complaint",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
              style:
              GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

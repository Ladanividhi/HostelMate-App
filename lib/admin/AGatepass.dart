import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class AGatepassPage extends StatefulWidget {
  @override
  State<AGatepassPage> createState() => _AGatepassPageState();
}

class _AGatepassPageState extends State<AGatepassPage> {
  String selectedStatus = "Pending";

  List<Map<String, dynamic>> gatepasses = [
    {
      "name": "Vidhi Ladani",
      "hostelId": "H001",
      "room": "302",
      "dateApplied": "2025-06-25",
      "dateOfGoing": "2025-06-26",
      "dateOfReturn": "2025-06-28",
      "reason": "Family Function",
      "parentApproval": "Approved",
      "status": "Pending"
    },
    {
      "name": "Riya Shah",
      "hostelId": "H002",
      "room": "101",
      "dateApplied": "2025-06-22",
      "dateOfGoing": "2025-06-23",
      "dateOfReturn": "2025-06-24",
      "reason": "Medical Checkup",
      "parentApproval": "Pending",
      "status": "Approved"
    },
    // Add more mock data if needed
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
            "Gatepass Requests",
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

            //Radio Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,   // 👈 center them
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
                    value: "Approved",
                    groupValue: selectedStatus,
                    activeColor: primary_color,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  Text("Approved", style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),


            SizedBox(height: 10),

            // Gatepass List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: gatepasses.length,
                itemBuilder: (context, index) {
                  final gp = gatepasses[index];

                  if (gp["status"] != selectedStatus) return SizedBox();

                  final days = DateTime.parse(gp["dateOfReturn"])
                      .difference(DateTime.parse(gp["dateOfGoing"]))
                      .inDays;

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
                              gp["name"],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary_color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Hostel ID: ${gp["hostelId"]} | Room: ${gp["room"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            detailRow("Date Applied", gp["dateApplied"]),
                            detailRow("Going Date", gp["dateOfGoing"]),
                            detailRow("Return Date", gp["dateOfReturn"]),
                            detailRow("Reason", gp["reason"]),
                            detailRow("Days",
                                "${days == 0 ? 1 : days} day${days > 1 ? 's' : ''}"),
                            detailRow("Parent Approval", gp["parentApproval"]),

                            // Approve Button for Pending
                            if (selectedStatus == "Pending") ...[
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    gp["status"] = "Approved";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary_color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Approve",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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

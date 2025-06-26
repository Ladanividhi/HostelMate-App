import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';

class HRequestPage extends StatefulWidget {
  @override
  State<HRequestPage> createState() => _HRequestPageState();
}

class _HRequestPageState extends State<HRequestPage> {
  final TextEditingController requestController = TextEditingController();

  List<Map<String, dynamic>> previousRequests = [
    {
      "date": "2025-06-24",
      "message": "Request for fan repair.",
      "status": "Pending"
    },
    {
      "date": "2025-06-20",
      "message": "Need extra blanket.",
      "status": "Completed"
    },
  ];

  void submitRequest() {
    if (requestController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a request message")),
      );
      return;
    }

    setState(() {
      previousRequests.insert(0, {
        "date": DateTime.now().toString().substring(0, 10),
        "message": requestController.text,
        "status": "Pending"
      });
      requestController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request Submitted")),
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
            "My Requests",
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
                    "New Request",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  SizedBox(height: 14),

                  TextField(
                    controller: requestController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Type your request here",
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
                    "Previous Requests",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  SizedBox(height: 12),

                  ...previousRequests.map((req) => Padding(
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
                            detailRow("Date", req["date"]),
                            detailRow("Request", req["message"]),
                            detailRow("Status", req["status"]),
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
                  onPressed: submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Submit Request",
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

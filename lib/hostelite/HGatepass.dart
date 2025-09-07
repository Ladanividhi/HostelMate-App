import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HGatepassPage extends StatefulWidget {
  const HGatepassPage({Key? key}) : super(key: key);

  @override
  State<HGatepassPage> createState() => _HGatepassPageState();
}

class _HGatepassPageState extends State<HGatepassPage> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? dateOfGoing;
  DateTime? dateOfReturn;

  String? hosteliteId; // fetched from SharedPreferences

  List<Map<String, dynamic>> previousGatepasses = [];

  @override
  void initState() {
    super.initState();
    _loadHosteliteId();
  }

  Future<void> _loadHosteliteId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hosteliteId = prefs.getString("hostelite_id"); // 🔑 saved at login
    });
  }

  void pickDate(BuildContext context, bool isGoing) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary_color,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isGoing) {
          dateOfGoing = pickedDate;
        } else {
          dateOfReturn = pickedDate;
        }
      });
    }
  }

  void generateGatepass() async {
    if (dateOfGoing == null || dateOfReturn == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details!")),
      );
      return;
    }

    if (hosteliteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Hostelite ID not found!")),
      );
      return;
    }

    try {
      // Create a new document in Gatepass collection
      DocumentReference gatepassRef =
      FirebaseFirestore.instance.collection("Gatepass").doc();

      await gatepassRef.set({
        "gatepassId": gatepassRef.id, // unique id
        "hosteliteId": hosteliteId, // taken from SharedPreferences
        "goingDate": dateOfGoing,
        "returnDate": dateOfReturn,
        "reason": reasonController.text.trim(),
        "generatedTime": DateTime.now(),
        "parentApproval": "Pending",
        "adminApproval": "Pending",
      });

      // Update UI
      setState(() {
        previousGatepasses.insert(0, {
          "gatepassId": gatepassRef.id,
          "dateApplied": DateTime.now().toString().substring(0, 10),
          "dateOfGoing": dateOfGoing.toString().substring(0, 10),
          "dateOfReturn": dateOfReturn.toString().substring(0, 10),
          "reason": reasonController.text,
          "status": "Pending",
          "parentApproval": "Pending"
        });
        reasonController.clear();
        dateOfGoing = null;
        dateOfReturn = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gatepass Generated & Sent for Approval!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
            "My Gatepasses",
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
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    "Request New Gatepass",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Pickers & Reason Field
                  buildDateField("Date of Going", dateOfGoing, true),
                  const SizedBox(height: 12),
                  buildDateField("Date of Return", dateOfReturn, false),
                  const SizedBox(height: 12),

                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Reason",
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    "Previous Gatepasses",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...previousGatepasses.map((gp) => Padding(
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
                            detailRow("Date Applied", gp["dateApplied"]),
                            detailRow("Going Date", gp["dateOfGoing"]),
                            detailRow("Return Date", gp["dateOfReturn"]),
                            detailRow("Reason", gp["reason"]),
                            detailRow("Parent Approval",
                                gp["parentApproval"]),
                            detailRow("Status", gp["status"]),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            // Sticky Button
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generateGatepass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Generate Gatepass",
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

  Widget buildDateField(String title, DateTime? date, bool isGoing) {
    return GestureDetector(
      onTap: () => pickDate(context, isGoing),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: primary_color),
            const SizedBox(width: 12),
            Text(
              date != null ? date.toString().substring(0, 10) : title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: date != null ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String? value) {
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
              value ?? '',
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

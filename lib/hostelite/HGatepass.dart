import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HGatepassPage extends StatefulWidget {
  const HGatepassPage({Key? key}) : super(key: key);

  @override
  State<HGatepassPage> createState() => _HGatepassPageState();
}

class _HGatepassPageState extends State<HGatepassPage> {
  final TextEditingController reasonController = TextEditingController();
  DateTime? dateOfGoing;
  DateTime? dateOfReturn;

  String? hosteliteId;
  List<Map<String, dynamic>> previousGatepasses = [];

  // ✅ Values read from environment:
  late final String emailSender = dotenv.env["SMTP_EMAIL"] ?? "";
  late final String emailPassword = dotenv.env["SMTP_PASSWORD"] ?? "";
  final String approvalServerBaseUrl =
      'https://hostelmate-backend-1.onrender.com';

  @override
  void initState() {
    super.initState();
    _loadHosteliteId();
  }

  Future<void> _loadHosteliteId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hosteliteId = prefs.getString("hostelite_id");
    });
  }

  /// ------------------------------------------------------------
  /// ✅ Date Picker
  /// ------------------------------------------------------------
  void pickDate(BuildContext context, bool isGoing) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primary_color),
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

  /// ------------------------------------------------------------
  /// ✅ Main Gatepass Generator
  /// ------------------------------------------------------------
  void generateGatepass() async {
    if (dateOfGoing == null ||
        dateOfReturn == null ||
        reasonController.text.isEmpty) {
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
      /// ✅ Fetch guardian email using hosteliteId field
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hosteliteId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guardian email not found!")),
        );
        return;
      }

      final userDoc = querySnapshot.docs.first.data();
      final guardianEmail = userDoc['GuardianEmail'];

      if (guardianEmail == null || guardianEmail.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guardian email missing.")),
        );
        return;
      }

      /// ✅ Create Firestore Gatepass record
      final gatepassRef =
      FirebaseFirestore.instance.collection("Gatepass").doc();

      await gatepassRef.set({
        "gatepassId": gatepassRef.id,
        "hosteliteId": hosteliteId,
        "goingDate": dateOfGoing,
        "returnDate": dateOfReturn,
        "reason": reasonController.text.trim(),
        "generatedTime": DateTime.now(),
        "parentApproval": "Pending",
        "adminApproval": "Pending",
      });

      /// ------------------------------------------------------------
      /// ✅ Send Email to Guardian
      /// ------------------------------------------------------------
      final smtpServer = gmail(emailSender, emailPassword);

      final message = Message()
        ..from = Address(emailSender, "HostelMate System")
        ..recipients.add(guardianEmail)
        ..subject = "Gatepass Request for Approval"
        ..html = '''
    <p>Dear Guardian,</p>
    <p>A new gatepass request has been generated:</p>
    <p>
      <b>Reason:</b> ${reasonController.text}<br>
      <b>Date of Going:</b> ${dateOfGoing.toString().substring(0, 10)}<br>
      <b>Date of Return:</b> ${dateOfReturn.toString().substring(0, 10)}
    </p>
    <p>Please approve or reject:</p>
    <p>
      <a href="$approvalServerBaseUrl/approve?gatepassId=${gatepassRef.id}"
         style="padding:10px 20px;background:#4CAF50;color:white;
                text-decoration:none;border-radius:8px;">Approve</a>
      &nbsp;
      <a href="$approvalServerBaseUrl/decline?gatepassId=${gatepassRef.id}"
         style="padding:10px 20px;background:#F44336;color:white;
                text-decoration:none;border-radius:8px;">Decline</a>
    </p>
    <p>Thank you,<br>HostelMate</p>
    ''';

      try {
        await send(message, smtpServer);
      } catch (e) {
        print("❌ Email send error: $e");
      }

      /// ✅ Update UI
      setState(() {
        previousGatepasses.insert(0, {
          "gatepassId": gatepassRef.id,
          "dateApplied": DateTime.now().toString().substring(0, 10),
          "dateOfGoing": dateOfGoing.toString().substring(0, 10),
          "dateOfReturn": dateOfReturn.toString().substring(0, 10),
          "reason": reasonController.text,
          "status": "Pending",
          "parentApproval": "Pending",
        });

        reasonController.clear();
        dateOfGoing = null;
        dateOfReturn = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gatepass Generated & Email Sent!")),
      );
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// ------------------------------------------------------------
  /// ✅ UI Widgets
  /// ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ).copyWith(statusBarColor: primary_color),
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
                        color: primary_color),
                  ),
                  const SizedBox(height: 16),
                  buildDateField("Date of Going", dateOfGoing, true),
                  const SizedBox(height: 12),
                  buildDateField("Date of Return", dateOfReturn, false),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Reason",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                  ...previousGatepasses.map((gp) => gatepassTile(gp)),
                ],
              ),
            ),
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: generateGatepass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_color,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// ------------------------------------------------------------
  /// ✅ Individual Widgets
  /// ------------------------------------------------------------
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

  Widget gatepassTile(Map<String, dynamic> gp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 3,
        color: bg_color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailRow("Date Applied", gp["dateApplied"]),
              detailRow("Going Date", gp["dateOfGoing"]),
              detailRow("Return Date", gp["dateOfReturn"]),
              detailRow("Reason", gp["reason"]),
              detailRow("Parent Approval", gp["parentApproval"]),
              detailRow("Status", gp["status"]),
            ],
          ),
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
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style:
              GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
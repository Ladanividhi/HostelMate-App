// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:HostelMate/utils/Constants.dart';
// import 'package:flutter/services.dart';
//
// class AGatepassPage extends StatefulWidget {
//   @override
//   State<AGatepassPage> createState() => _AGatepassPageState();
// }
//
// class _AGatepassPageState extends State<AGatepassPage> {
//   String selectedStatus = "Pending";
//
//   List<Map<String, dynamic>> gatepasses = [
//     {
//       "name": "Vidhi Ladani",
//       "hostelId": "H001",
//       "room": "302",
//       "dateApplied": "2025-06-25",
//       "dateOfGoing": "2025-06-26",
//       "dateOfReturn": "2025-06-28",
//       "reason": "Family Function",
//       "parentApproval": "Approved",
//       "status": "Pending"
//     },
//     {
//       "name": "Riya Shah",
//       "hostelId": "H002",
//       "room": "101",
//       "dateApplied": "2025-06-22",
//       "dateOfGoing": "2025-06-23",
//       "dateOfReturn": "2025-06-24",
//       "reason": "Medical Checkup",
//       "parentApproval": "Pending",
//       "status": "Approved"
//     },
//     // Add more mock data if needed
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: primary_color,
//         statusBarIconBrightness: Brightness.light,
//       ),
//       child: Scaffold(
//         backgroundColor: Color(0xFFF5F5F5),
//         appBar: AppBar(
//           backgroundColor: primary_color,
//           elevation: 0,
//           title: Text(
//             "Gatepass Requests",
//             style: GoogleFonts.poppins(
//               fontSize: 22,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//           iconTheme: const IconThemeData(color: Colors.white),
//         ),
//         body: Column(
//           children: [
//             SizedBox(height: 16),
//
//             //Radio Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,   // 👈 center them
//                 children: [
//                   Radio<String>(
//                     value: "Pending",
//                     groupValue: selectedStatus,
//                     activeColor: primary_color,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedStatus = value!;
//                       });
//                     },
//                   ),
//                   Text("Pending", style: GoogleFonts.poppins(fontSize: 14)),
//
//                   SizedBox(width: 20),
//                   Radio<String>(
//                     value: "Approved",
//                     groupValue: selectedStatus,
//                     activeColor: primary_color,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedStatus = value!;
//                       });
//                     },
//                   ),
//                   Text("Approved", style: GoogleFonts.poppins(fontSize: 14)),
//                 ],
//               ),
//             ),
//
//
//             SizedBox(height: 10),
//
//             // Gatepass List
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 itemCount: gatepasses.length,
//                 itemBuilder: (context, index) {
//                   final gp = gatepasses[index];
//
//                   if (gp["status"] != selectedStatus) return SizedBox();
//
//                   final days = DateTime.parse(gp["dateOfReturn"])
//                       .difference(DateTime.parse(gp["dateOfGoing"]))
//                       .inDays;
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Card(
//                       color: bg_color,
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               gp["name"],
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: primary_color,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               "Hostel ID: ${gp["hostelId"]} | Room: ${gp["room"]}",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13.5,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             detailRow("Date Applied", gp["dateApplied"]),
//                             detailRow("Going Date", gp["dateOfGoing"]),
//                             detailRow("Return Date", gp["dateOfReturn"]),
//                             detailRow("Reason", gp["reason"]),
//                             detailRow("Days",
//                                 "${days == 0 ? 1 : days} day${days > 1 ? 's' : ''}"),
//                             detailRow("Parent Approval", gp["parentApproval"]),
//
//                             // Approve Button for Pending
//                             if (selectedStatus == "Pending") ...[
//                               SizedBox(height: 8),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     gp["status"] = "Approved";
//                                   });
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: primary_color,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   "Approve",
//                                   style: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ]
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget detailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Text(
//             "$title: ",
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600,
//               fontSize: 13.5,
//               color: Colors.black87,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style:
//               GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class AGatepassPage extends StatefulWidget {
  @override
  State<AGatepassPage> createState() => _AGatepassPageState();
}

class _AGatepassPageState extends State<AGatepassPage> {
  String selectedStatus = "Pending";

  // 📧 Gmail config
  final String emailSender = "yourgmail@gmail.com"; // your Gmail
  final String emailAppPassword =
      "xxxxxxxxxxxxxxxx"; // 16-digit app password from Google

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
            "Gatepass Requests",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 🔘 Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: "Pending",
                      groupValue: selectedStatus,
                      activeColor: primary_color,
                      onChanged: (value) => setState(() => selectedStatus = value!),
                    ),
                    Text("Pending", style: GoogleFonts.poppins(fontSize: 14)),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: "Approved",
                      groupValue: selectedStatus,
                      activeColor: primary_color,
                      onChanged: (value) => setState(() => selectedStatus = value!),
                    ),
                    Text("Approved", style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 Live Firestore Stream
              StreamBuilder<QuerySnapshot>(
                stream: selectedStatus == "Pending"
                    ? FirebaseFirestore.instance
                    .collection("Gatepass")
                    .where("adminApproval", isEqualTo: "Pending")
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection("Gatepass")
                    .where("adminApproval", isEqualTo: "Approved")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Text(
                        "No $selectedStatus requests",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  }

                  final gatepasses = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true, // ✅ So it fits inside SingleChildScrollView
                    physics:
                    const NeverScrollableScrollPhysics(), // ✅ Disable internal scrolling
                    itemCount: gatepasses.length,
                    itemBuilder: (context, index) {
                      final gp = gatepasses[index].data() as Map<String, dynamic>;
                      final docId = gatepasses[index].id;

                      final goingDate = (gp["goingDate"] as Timestamp).toDate();
                      final returnDate = (gp["returnDate"] as Timestamp).toDate();
                      final days = returnDate.difference(goingDate).inDays;

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
                                  "Hostelite ID: ${gp["hosteliteId"]}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primary_color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                detailRow(
                                  "Date Applied",
                                  (gp["generatedTime"] as Timestamp)
                                      .toDate()
                                      .toString()
                                      .substring(0, 10),
                                ),
                                detailRow("Going Date",
                                    goingDate.toString().substring(0, 10)),
                                detailRow("Return Date",
                                    returnDate.toString().substring(0, 10)),
                                detailRow("Reason", gp["reason"]),
                                detailRow(
                                    "Parent Approval", gp["parentApproval"]),
                                detailRow(
                                  "Days",
                                  "${days == 0 ? 1 : days} day${days > 1 ? 's' : ''}",
                                ),

                                // ✅ Show Approve button only for Pending tab
                                if (selectedStatus == "Pending") ...[
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: gp["parentApproval"] == "Approved"
                                        ? () async {
                                      await FirebaseFirestore.instance
                                          .collection("Gatepass")
                                          .doc(docId)
                                          .update({
                                        "adminApproval": "Approved"
                                      });

                                      setState(() {}); // Refresh UI instantly

                                      if (gp["parentEmail"] != null) {
                                        _sendApprovalEmail(
                                          parentEmail: gp["parentEmail"],
                                          reason: gp["reason"],
                                          going: goingDate,
                                          returning: returnDate,
                                        );
                                      }

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Gatepass Approved & Email Sent ✅"),
                                        ),
                                      );
                                    }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      gp["parentApproval"] == "Approved"
                                          ? primary_color
                                          : Colors.grey.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      gp["parentApproval"] == "Approved"
                                          ? "Approve"
                                          : "Waiting for Parent Approval",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
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
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendApprovalEmail({
    required String parentEmail,
    required String reason,
    required DateTime going,
    required DateTime returning,
  }) async {
    final smtpServer = gmail(emailSender, emailAppPassword);

    final message = Message()
      ..from = Address(emailSender, "Hostel Admin")
      ..recipients.add(parentEmail)
      ..subject = "Gatepass Approved ✅"
      ..text = """
Hello,

Your ward's gatepass has been approved.

Reason: $reason
Going Date: ${going.toString().substring(0, 10)}
Return Date: ${returning.toString().substring(0, 10)}

Regards,
Hostel Administration
""";

    try {
      await send(message, smtpServer);
      print("Approval email sent to $parentEmail");
    } catch (e) {
      print("Email error: $e");
    }
  }
}
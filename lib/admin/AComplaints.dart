import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AComplaintsPage extends StatefulWidget {
  @override
  State<AComplaintsPage> createState() => _AComplaintsPageState();
}

class _AComplaintsPageState extends State<AComplaintsPage> {
  String selectedStatus = "Pending";
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Fetch all complaints from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('Complaints')
          .get();

      // Get user details for each complaint
      List<Map<String, dynamic>> complaintsWithUserData = [];
      
      for (var doc in snapshot.docs) {
        final complaintData = doc.data();
        final hostelId = complaintData['HostelId'];
        
        // Fetch user details from Users collection
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('HostelId', isEqualTo: hostelId)
            .limit(1)
            .get();
        
        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          
          complaintsWithUserData.add({
            "id": doc.id,
            "name": userData['Name'] ?? 'Unknown',
            "hostelId": hostelId,
            "room": userData['RoomNumber']?.toString() ?? 'N/A',
            "date": _formatDate(complaintData['Date']),
            "message": complaintData['Description'] ?? '',
            "status": complaintData['Status'] == true ? "Action Taken" : "Pending",
            "remarks": complaintData['ActionMsg'] ?? '',
            "actionDate": _formatDate(complaintData['ActionDate']),
            "isResolved": complaintData['Status'] == true,
            "timestamp": complaintData['Date'],
          });
        }
      }

      // Sort by timestamp in descending order (newest first)
      complaintsWithUserData.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        return bTime.compareTo(aTime);
      });

      setState(() {
        complaints = complaintsWithUserData;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching complaints: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Unknown";
    if (date is Timestamp) {
      return date.toDate().toString().substring(0, 10);
    }
    return date.toString().substring(0, 10);
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
            "Complaints",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                await _fetchComplaints();
              },
            ),
          ],
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
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: complaints.where((c) => c["status"] == selectedStatus).length,
                      itemBuilder: (context, index) {
                        final filteredComplaints = complaints.where((c) => c["status"] == selectedStatus).toList();
                        final c = filteredComplaints[index];

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
                            if (c["status"] == "Action Taken") ...[
                              detailRow("Remarks", c["remarks"]),
                              if (c["actionDate"] != null && c["actionDate"] != "Unknown")
                                detailRow("Action Date", c["actionDate"]),
                            ],

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
    final filteredComplaints = complaints.where((c) => c["status"] == selectedStatus).toList();
    final complaint = filteredComplaints[index];
    
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
            onPressed: () async {
              await _markAsActionTaken(complaint["id"], remarksController.text);
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

  Future<void> _markAsActionTaken(String complaintId, String actionMessage) async {
    try {
      // Update the complaint in Firestore
      await FirebaseFirestore.instance
          .collection('Complaints')
          .doc(complaintId)
          .update({
        'Status': true,
        'ActionMsg': actionMessage,
        'ActionDate': Timestamp.now(),
      });

      // Refresh the complaints list
      await _fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Action marked successfully")),
      );
    } catch (e) {
      print("❌ Error marking action taken: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark action. Please try again.")),
      );
    }
  }
}

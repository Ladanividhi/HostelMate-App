import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HComplaintPage extends StatefulWidget {
  @override
  State<HComplaintPage> createState() => _HComplaintPageState();
}

class _HComplaintPageState extends State<HComplaintPage> {
  final TextEditingController complaintController = TextEditingController();
  List<Map<String, dynamic>> previousComplaints = [];
  String? hostelId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    complaintController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getHostelId();
    await _fetchComplaints();
  }

  Future<void> _getHostelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      hostelId = prefs.getString('hostelite_id');
      print("🔍 Retrieved Hostel ID: $hostelId");
    } catch (e) {
      print("❌ Error getting hostel ID: $e");
    }
  }

  Future<void> _fetchComplaints() async {
    if (hostelId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Complaints')
          .where('HostelId', isEqualTo: hostelId)
          .get();

      setState(() {
        // Convert documents to list and sort by date (newest first)
        final complaintsList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "date": _formatDate(data['Date']),
            "message": data['Description'] ?? '',
            "status": data['Status'] == true ? "Action Taken" : "Pending",
            "actionMsg": data['ActionMsg'] ?? '',
            "actionDate": _formatDate(data['ActionDate']),
            "isResolved": data['Status'] == true,
            "timestamp": data['Date'], // Keep original timestamp for sorting
          };
        }).toList();

        // Sort by timestamp in descending order (newest first)
        complaintsList.sort((a, b) {
          final aTime = a['timestamp'] as Timestamp?;
          final bTime = b['timestamp'] as Timestamp?;
          
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          return bTime.compareTo(aTime);
        });

        // Remove timestamp from final data
        previousComplaints = complaintsList.map((complaint) {
          final Map<String, dynamic> cleanComplaint = Map.from(complaint);
          cleanComplaint.remove('timestamp');
          return cleanComplaint;
        }).toList();
        
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

  Future<void> submitComplaint() async {
    if (complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a complaint message")),
      );
      return;
    }

    if (hostelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hostel ID not found. Please sign in again.")),
      );
      return;
    }

    try {
      // Add complaint to Firestore
      await FirebaseFirestore.instance.collection('Complaints').add({
        'HostelId': hostelId,
        'Description': complaintController.text,
        'Date': Timestamp.now(),
        'ActionDate': null,
        'ActionMsg': null,
        'Status': false,
      });

      // Clear the text field
      complaintController.clear();

      // Refresh the complaints list
      await _fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint Submitted Successfully")),
      );
    } catch (e) {
      print("❌ Error submitting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit complaint. Please try again.")),
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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await _fetchComplaints();
              },
            ),
          ],
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

                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                        ),
                      ),
                    )
                  else if (previousComplaints.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No complaints found",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
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
                              _buildStatusRow(c),
                              if (c["status"] == "Action Taken" && c["actionMsg"] != null && c["actionMsg"].isNotEmpty)
                                detailRow("Action Message", c["actionMsg"]),
                              if (c["status"] == "Action Taken" && c["actionDate"] != null && c["actionDate"].isNotEmpty)
                                detailRow("Action Date", c["actionDate"]),
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

  Widget _buildStatusRow(Map<String, dynamic> complaint) {
    final isResolved = complaint["isResolved"] == true;
    final statusText = complaint["status"];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "Status: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isResolved ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isResolved ? Colors.green[300]! : Colors.red[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isResolved ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
          ),
        ],
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

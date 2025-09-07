import 'package:HostelMate/admin/APayment.dart';
import 'package:HostelMate/hostelite/HComplaints.dart';
import 'package:HostelMate/hostelite/HGatepass.dart';
import 'package:HostelMate/hostelite/HHostelites.dart';
import 'package:HostelMate/hostelite/HPayment.dart';
import 'package:HostelMate/hostelite/HProfile.dart';
import 'package:HostelMate/hostelite/HScanner.dart';
import 'package:HostelMate/hostelite/Messages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:HostelMate/hostelite/HFeedback.dart';


class HDashboard extends StatefulWidget {
  @override
  _HDashboardState createState() => _HDashboardState();
}

class _HDashboardState extends State<HDashboard> {
  String? hosteliteName;
  String? hosteliteId;
  String? roomNumber;
  String? bedNumber;
  bool isLoading = true;

  final List<Map<String, dynamic>> dashboardItems = [
    {"icon": Icons.people_alt_outlined, "label": "Hostelites"},
    {"icon": Icons.report_problem_outlined, "label": "Draft Complaint"},
    {"icon": Icons.message_outlined, "label": "Group chat"},
    {"icon": Icons.woman, "label": "View Vacancies"},
    {"icon": Icons.currency_rupee, "label": "Payment Status"},
    {"icon": Icons.vpn_key_outlined, "label": "Generate Gatepass"},
    {"icon": Icons.qr_code_scanner, "label": "Scanner"},
    {"icon": Icons.feedback_outlined, "label": "Feedback"},
    {"icon": Icons.account_circle, "label": "My Profile"},
  ];

  @override
  void initState() {
    super.initState();
    _loadHosteliteData();
  }

  Future<void> _loadHosteliteData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        hosteliteName = prefs.getString('hostelite_name') ?? 'Guest';
        hosteliteId = prefs.getString('hostelite_id') ?? 'N/A';
        roomNumber = prefs.getString('hostelite_room') ?? 'N/A';
        bedNumber = prefs.getString('hostelite_bed') ?? 'N/A';
        isLoading = false;
      });
      
      print("✅ Hostelite data loaded from shared preferences:");
      print("   - Name: $hosteliteName");
      print("   - Hostel ID: $hosteliteId");
      print("   - Room: $roomNumber");
      print("   - Bed: $bedNumber");
    } catch (e) {
      print("❌ Error loading hostelite data: $e");
      setState(() {
        hosteliteName = 'Guest';
        hosteliteId = 'N/A';
        roomNumber = 'N/A';
        bedNumber = 'N/A';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = dashboardItems;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primary_color,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  color: primary_color,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left part: Welcome + Name + Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to HostelMate",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          hosteliteName ?? 'Guest',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Hostel ID: $hosteliteId | Room: $roomNumber | Bed: $bedNumber",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              SizedBox(height: 26),
              // Dashboard grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                    children: List.generate(filteredItems.length, (index) {
                      return dashboardCard(
                        icon: filteredItems[index]['icon'],
                        label: filteredItems[index]['label'],
                        onTap: () {
                          print("${filteredItems[index]['label']} tapped");
                          if(filteredItems[index]['label'] == 'Hostelites')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HHostelitePage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Generate Gatepass')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HGatepassPage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Group chat')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MessagesPage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Payment Status')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HPaymentPage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Draft Complaint')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HComplaintPage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Scanner')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HScannerPage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'My Profile')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HProfilePage()),
                            );
                          }
                          else if(filteredItems[index]['label'] == 'Feedback')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HFeedbackPage()),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary_color,
              size: 35,
            ),
            SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:HostelMate/admin/AAddHostelite.dart';
import 'package:HostelMate/admin/AComplaints.dart';
import 'package:HostelMate/admin/AGatepass.dart';
import 'package:HostelMate/admin/AHostelites.dart';
import 'package:HostelMate/admin/AScanner.dart';
import 'package:HostelMate/admin/AVacancy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/rendering.dart';

class ADashboard extends StatefulWidget {
  @override
  State<ADashboard> createState() => _ADashboardState();
}

class _ADashboardState extends State<ADashboard> {
  final List<Map<String, dynamic>> dashboardItems = [
    {"icon": Icons.people_alt_outlined, "label": "Hostelites"},
    {"icon": Icons.report_problem_outlined, "label": "Complaints"},
    {"icon": Icons.message_outlined, "label": "Group chat"},
    {"icon": Icons.woman, "label": "Vacancy"},
    {"icon": Icons.currency_rupee, "label": "Payment"},
    {"icon": Icons.vpn_key_outlined, "label": "Gatepass"},
    {"icon": Icons.qr_code_scanner, "label": "Scanner"},
    {"icon": Icons.feedback_outlined, "label": "Feedback"},
    {"icon": Icons.add_circle_outlined, "label": "Add Hostelite"},
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
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: primary_color,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Text(
                  "Welcome to HostelMate",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Flexible Grid section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.7,  // Adjust this ratio to perfectly fit height
                    children: List.generate(dashboardItems.length, (index) {
                      return dashboardCard(
                        icon: dashboardItems[index]['icon'],
                        label: dashboardItems[index]['label'],
                        onTap: () {
                          print("${dashboardItems[index]['label']} tapped");
                          if(dashboardItems[index]['label'] == 'Hostelites')
                            {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AHostelitePage()),
                              );
                            }
                          else if(dashboardItems[index]['label'] == 'Scanner')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AScannerPage()),
                            );
                          }
                          else if(dashboardItems[index]['label'] == 'Gatepass')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AGatepassPage()),
                            );
                          }
                          else if(dashboardItems[index]['label'] == 'Complaints')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AComplaintsPage()),
                            );
                          }
                          else if(dashboardItems[index]['label'] == 'Vacancy')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AVacancyPage()),
                            );
                          }
                          else if(dashboardItems[index]['label'] == 'Add Hostelite')
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddHostelitePage()),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ),
              ),
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
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
                fontSize: 12,
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

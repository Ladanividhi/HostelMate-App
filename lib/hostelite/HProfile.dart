import 'package:HostelMate/hostelite/HEditProfile.dart';
import 'package:HostelMate/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HProfilePage extends StatefulWidget {
  @override
  State<HProfilePage> createState() => _HProfilePageState();
}

class _HProfilePageState extends State<HProfilePage> {
  Map<String, String> userProfile = {};
  String? currentHostelId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getHostelId();
    await _fetchUserProfile();
  }

  Future<void> _getHostelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hostelId = prefs.getString('hostelite_id');
      if (hostelId != null) {
        setState(() {
          currentHostelId = hostelId;
        });
      }
    } catch (e) {
      print("❌ Error getting hostel ID: $e");
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (currentHostelId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch user data from Users table
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('HostelId', isEqualTo: currentHostelId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        
        setState(() {
          userProfile = {
            "name": userData['Name'] ?? 'N/A',
            "hostelId": userData['HostelId'] ?? 'N/A',
            "room": userData['RoomNumber']?.toString() ?? 'N/A',
            "bed": userData['BedNumber'] ?? 'N/A',
            "college": userData['College'] ?? 'N/A',
            "course": userData['Course'] ?? 'N/A',
            "email": userData['Email'] ?? 'N/A',
            "phone": userData['Phone'] ?? 'N/A',
            "address": userData['Address'] ?? 'N/A',
            "fatherName": userData['FatherName'] ?? 'N/A',
            "motherName": userData['MotherName'] ?? 'N/A',
            "fatherContact": userData['FatherContact'] ?? 'N/A',
            "motherContact": userData['MotherContact'] ?? 'N/A',
            "guardianEmail": userData['GuardianEmail'] ?? 'N/A',
            "joiningDate": _formatDate(userData['JoiningDate']),
          };
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching user profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
      }
      return "N/A";
    } catch (e) {
      return "N/A";
    }
  }

  void onMenuSelected(String value) {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HEditProfilePage()),
      ).then((value) {
        // This runs when HEditProfilePage is popped
        _initializeData(); // call your function to reload data
        setState(() {});    // rebuilds the page
      });

    } else if (value == 'settings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
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
            "My Profile",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              color: Colors.white, // popup background color
              elevation: 8, // shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: primary_color),
                      SizedBox(width: 10),
                      Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20, color: primary_color),
                      SizedBox(width: 10),
                      Text(
                        "Settings",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                ),
              )
            : userProfile.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Profile not found",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Unable to load your profile data",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: primary_color.withOpacity(0.2),
                          child: Text(
                            userProfile["name"]?.isNotEmpty == true 
                                ? userProfile["name"]![0].toUpperCase()
                                : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              color: primary_color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      Center(
                        child: Text(
                          userProfile["name"] ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: primary_color,
                          ),
                        ),
                      ),
                      SizedBox(height: 28),

                      // Profile details
                      ...userProfile.entries.map((entry) => profileRow(entry.key, entry.value)),

                    ],
                  ),
      ),
    );
  }

  Widget profileRow(String title, String value) {
    // Make title readable
    String formattedTitle = title
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .replaceAll('Id', 'ID')
        .replaceFirst(title[0], title[0].toUpperCase());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: bg_color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          title: Text(
            formattedTitle,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/Constants.dart';
import 'package:flutter/services.dart';

class HEditProfilePage extends StatefulWidget {
  @override
  State<HEditProfilePage> createState() => _HEditProfilePageState();
}

class _HEditProfilePageState extends State<HEditProfilePage> {
  Map<String, String> userProfile = {};
  String? currentHostelId;
  bool isLoading = true;
  bool isUpdating = false;

  // Controllers for editable fields
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherContactController = TextEditingController();
  final TextEditingController _motherContactController = TextEditingController();
  final TextEditingController _guardianEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _collegeController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _fatherContactController.dispose();
    _motherContactController.dispose();
    _guardianEmailController.dispose();
    super.dispose();
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

        // Populate controllers with current values
        _populateControllers();
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

  void _populateControllers() {
    _collegeController.text = userProfile['college'] ?? '';
    _courseController.text = userProfile['course'] ?? '';
    _emailController.text = userProfile['email'] ?? '';
    _phoneController.text = userProfile['phone'] ?? '';
    _addressController.text = userProfile['address'] ?? '';
    _fatherNameController.text = userProfile['fatherName'] ?? '';
    _motherNameController.text = userProfile['motherName'] ?? '';
    _fatherContactController.text = userProfile['fatherContact'] ?? '';
    _motherContactController.text = userProfile['motherContact'] ?? '';
    _guardianEmailController.text = userProfile['guardianEmail'] ?? '';
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

  Future<void> _updateProfile() async {
    try {
      setState(() {
        isUpdating = true;
      });

      if (currentHostelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User ID not found")),
        );
        return;
      }

      // Find the user document
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('HostelId', isEqualTo: currentHostelId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final docId = userSnapshot.docs.first.id;
        
        // Update the document
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(docId)
            .update({
          'College': _collegeController.text.trim(),
          'Course': _courseController.text.trim(),
          'Email': _emailController.text.trim(),
          'Phone': _phoneController.text.trim(),
          'Address': _addressController.text.trim(),
          'FatherName': _fatherNameController.text.trim(),
          'MotherName': _motherNameController.text.trim(),
          'FatherContact': _fatherContactController.text.trim(),
          'MotherContact': _motherContactController.text.trim(),
          'GuardianEmail': _guardianEmailController.text.trim(),
        });

        // Update local profile
        setState(() {
          userProfile['college'] = _collegeController.text.trim();
          userProfile['course'] = _courseController.text.trim();
          userProfile['email'] = _emailController.text.trim();
          userProfile['phone'] = _phoneController.text.trim();
          userProfile['address'] = _addressController.text.trim();
          userProfile['fatherName'] = _fatherNameController.text.trim();
          userProfile['motherName'] = _motherNameController.text.trim();
          userProfile['fatherContact'] = _fatherContactController.text.trim();
          userProfile['motherContact'] = _motherContactController.text.trim();
          userProfile['guardianEmail'] = _guardianEmailController.text.trim();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile updated successfully!"),
          ),
        );

        } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User not found")),
        );
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile. Please try again.")),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
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
            "Edit Profile",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : _updateProfile,
              child: isUpdating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Save",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Header
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
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Hostel ID: ${userProfile['hostelId']} | Room: ${userProfile['room']} | Bed: ${userProfile['bed']}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 28),

                        // Editable Fields
                        _buildEditableField("College", _collegeController, Icons.school),
                        _buildEditableField("Course", _courseController, Icons.book),
                        _buildEditableField("Email", _emailController, Icons.email),
                        _buildEditableField("Phone", _phoneController, Icons.phone),
                        _buildEditableField("Address", _addressController, Icons.location_on),
                        _buildEditableField("Father Name", _fatherNameController, Icons.person),
                        _buildEditableField("Mother Name", _motherNameController, Icons.person),
                        _buildEditableField("Father Contact", _fatherContactController, Icons.phone),
                        _buildEditableField("Mother Contact", _motherContactController, Icons.phone),
                        _buildEditableField("Guardian Email", _guardianEmailController, Icons.email),

                        SizedBox(height: 20),

                        // Read-only Fields
                        _buildReadOnlyField("Joining Date", userProfile['joiningDate'] ?? 'N/A', Icons.calendar_today),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: bg_color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: primary_color,
                  ),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller,
                enabled: !isUpdating,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Enter $title",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primary_color),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                inputFormatters: title.toLowerCase().contains('phone') || title.toLowerCase().contains('contact')
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                keyboardType: title.toLowerCase().contains('email')
                    ? TextInputType.emailAddress
                    : title.toLowerCase().contains('phone') || title.toLowerCase().contains('contact')
                        ? TextInputType.phone
                        : TextInputType.text,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: Colors.grey[100],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          subtitle: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

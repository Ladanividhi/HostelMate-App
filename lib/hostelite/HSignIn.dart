import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/hostelite/HDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HSignInPage extends StatefulWidget {
  @override
  State<HSignInPage> createState() => _HSignInPageState();
}

class _HSignInPageState extends State<HSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final hostelIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool rememberMe = false;

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
    ));
  }

  void signInUser() async {
    if (!_formKey.currentState!.validate()) return;

    final hostelId = hostelIdController.text.trim();
    final password = passwordController.text.trim();

    try {
      await FirebaseFirestore.instance.collection("Users").limit(1).get();

      // Try as string first
      var userQuery = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hostelId)
          .get();

      // If no results, try as number
      if (userQuery.docs.isEmpty && int.tryParse(hostelId) != null) {
        userQuery = await FirebaseFirestore.instance
            .collection("Users")
            .where("HostelId", isEqualTo: int.parse(hostelId))
            .get();
      }
      
      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();

        // Check if password matches
        if (userData['Password'] == password) {
          // Store hostelite ID in shared preferences
          await _storeHosteliteData(hostelId, userData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HDashboard()),
                (Route<dynamic> route) => false, // This removes all previous routes
          );

        } else {
          showSnack("Invalid Hostel ID or Password.");
        }
      } else {
        showSnack("Invalid Hostel ID or Password.");
      }
    } catch (e) {
      showSnack("Something went wrong. Please try again.");
    }
  }

  Future<void> _storeHosteliteData(String hostelId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear admin flag and store hostelite ID and other useful data
      await prefs.setBool('is_admin', false);
      await prefs.setString('hostelite_id', hostelId);
      await prefs.setString('hostelite_room', userData['RoomNumber']?.toString() ?? '');
      await prefs.setString('hostelite_bed', userData['BedNumber']?.toString() ?? '');
      await prefs.setString('hostelite_scanner_img', userData['ScannerImg']?.toString() ?? '');
      await prefs.setString('hostelite_name', userData['Name']?.toString() ?? '');
      await prefs.setBool('remember_me', rememberMe); // Save remember me preference
      
      print("✅ Hostelite data stored in shared preferences:");
      print("   - Hostel ID: $hostelId");
      print("   - Room: ${userData['RoomNumber']}");
      print("   - Bed: ${userData['BedNumber']}");
      print("   - Scanner Image: ${userData['ScannerImg']}");
    } catch (e) {
      print("❌ Error storing hostelite data: $e");
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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  "Hostelite Login",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Login with your Hostel ID and password",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 32),

                // Card container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Hostel ID Field
                        TextFormField(
                          controller: hostelIdController,
                          decoration: InputDecoration(
                            labelText: "Hostel ID",
                            labelStyle: GoogleFonts.poppins(fontSize: 14),
                            filled: true,
                            fillColor: Color(0xFFF9F9F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your Hostel ID";
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(),
                        ),
                        SizedBox(height: 18),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: GoogleFonts.poppins(fontSize: 14),
                            filled: true,
                            fillColor: Color(0xFFF9F9F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(),
                        ),
                        SizedBox(height: 20),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                              activeColor: primary_color,
                            ),
                            Text(
                              "Remember Me",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: signInUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary_color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HSignInPage extends StatefulWidget {
  @override
  State<HSignInPage> createState() => _HSignInPageState();
}

class _HSignInPageState extends State<HSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final hostelIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
      backgroundColor: primary_color,
    ));
  }

  void signInUser() async {
    if (!_formKey.currentState!.validate()) return;

    final hostelId = hostelIdController.text.trim();
    final password = passwordController.text.trim();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hostelId)
          .where("Password", isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HSignInPage()),
        );
      } else {
        showSnack("Invalid Hostel ID or Password.");
      }
    } catch (e) {
      print("Login error: $e");
      showSnack("Something went wrong. Please try again.");
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
                  "Hostelite Sign In",
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
                        SizedBox(height: 28),

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

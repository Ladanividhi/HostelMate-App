import 'package:HostelMate/hostelite/HSignIn.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/hostelite/HSignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/Constants.dart';

class HosteliteIdCheckPage extends StatefulWidget {
  @override
  State<HosteliteIdCheckPage> createState() => _HosteliteIdCheckPageState();
}

class _HosteliteIdCheckPageState extends State<HosteliteIdCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final hostelIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final secretcodeController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  void checkHostelIdAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final hostelId = hostelIdController.text.trim();
      final password = passwordController.text.trim();
      final secretcodeinput = secretcodeController.text.trim();
      print("🔍 Entered Hostel ID: $hostelId");
      print("🔐 Entered Password: $password");

      if (hostelId.isEmpty) {
        showSnack("Please enter Hostel ID.");
        print("❌ Hostel ID is empty.");
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hostelId)
          .get();

      print("📦 Documents found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final email = data["Email"]?.toString() ?? "";
        final dbHostelId = data["HostelId"]?.toString() ?? "";
        final secretcode = data["SecretCode"]?.toString() ?? "";

        print("✅ Found record -> HostelId: $dbHostelId, SecretCode: $secretcode, Email: $email");

        if (secretcode != secretcodeinput) {
          showSnack("Invalid secret code.");
          return;
        }

        final docId = querySnapshot.docs.first.id;
        if (email == "a") {
          print("➡️ Proceeding to HSignUpPage...");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HSignUpPage(
                hostelId: hostelId,
                password: password,
                docId: docId,
              ),
            ),
          );
        } else {
          print("⚠️ Email is not 'a', user already registered.");
          showSnack("User already exists, kindly sign in.");
        }
      } else {
        print("❌ No matching Hostel ID found in Firestore.");
        showSnack("Invalid Hostel ID.");
      }
    } catch (e) {
      print("❗ Error while fetching HostelId: $e");
      showSnack("Something went wrong. Please try again.");
    }
  }


  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
    ));
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
                  "Enter your hostel ID and set your password to proceed.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),

                // Card like form container
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
                        buildTextField(
                          label: "Hostel ID",
                          controller: hostelIdController,
                          validatorMsg: "Please enter Hostel ID",
                        ),
                        SizedBox(height: 18),
                        buildTextField(
                          label: "Secret Code",
                          controller: secretcodeController,
                          validatorMsg: "Please enter the secret code",
                        ),
                        SizedBox(height: 18),
                        buildPasswordField(
                          label: "Create Password",
                          controller: passwordController,
                          visible: _passwordVisible,
                          onToggle: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          validatorMsg: "Please create a password",
                        ),
                        SizedBox(height: 18),
                        buildPasswordField(
                          label: "Confirm Password",
                          controller: confirmPasswordController,
                          visible: _confirmPasswordVisible,
                          onToggle: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                          validatorMsg: "Please confirm your password",
                          confirmCheck: true,
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: checkHostelIdAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary_color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              "Proceed",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // 👉 Login redirect text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already registered? ",
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HSignInPage()),
                                );
                              },
                              child: Text(
                                "Login here",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: primary_color,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String validatorMsg,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        filled: true,
        fillColor: Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        return null;
      },
      style: GoogleFonts.poppins(),
    );
  }

  Widget buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
    required String validatorMsg,
    bool confirmCheck = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        filled: true,
        fillColor: Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade700,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg;
        }
        if (confirmCheck && value != passwordController.text) {
          return "Passwords do not match";
        }
        if (!confirmCheck && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
      style: GoogleFonts.poppins(),
    );
  }
}

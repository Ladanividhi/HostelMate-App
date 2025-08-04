import 'package:HostelMate/admin/ADashboard.dart';
import 'package:HostelMate/hostelite/HDashboard.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController secretKeyController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Admin Login",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: primary_color,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Welcome back, Admin!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Username Field
                  textLabel("Username"),
                  SizedBox(height: 8),
                  textInputField(usernameController, "Enter username", false),

                  SizedBox(height: 20),

                  // Password Field
                  textLabel("Password"),
                  SizedBox(height: 8),
                  passwordInputField(),

                  SizedBox(height: 20),

                  // Secret Key Field
                  textLabel("Secret Code"),
                  SizedBox(height: 8),
                  textInputField(secretKeyController, "Enter secret code", true),

                  SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handleLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_color,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Debug Button (remove this in production)

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim(); // ❌ No hashing here
    final password = passwordController.text.trim();
    final secretKey = secretKeyController.text.trim();

    if (username.isEmpty || password.isEmpty || secretKey.isEmpty) {
      showError("Please fill in all fields.");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔐 Only hash password and secret key
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final hashedSecret = sha256.convert(utf8.encode(secretKey)).toString();

      // 🔎 Look for admin document by raw (plain text) username
      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('Username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        showError("Username not found.");
        return;
      }

      final adminData = snapshot.docs.first.data();

      // ✅ Ensure necessary fields exist
      if (!adminData.containsKey('Password') || !adminData.containsKey('Security')) {
        showError("Account data is incomplete. Please contact support.");
        return;
      }

      final storedPassword = adminData['Password'];
      final storedSecret = adminData['Security'];

      // 🔁 Compare hashed credentials
      if (password != storedPassword) {
        showError("Incorrect password.");
        return;
      }

      if (secretKey != storedSecret) {
        showError("Incorrect secret code.");
        return;
      }

      // 🎉 SUCCESS
      showSuccess("Welcome Admin!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ADashboard()),
      );

    } catch (e) {
      print("Login error: $e");
      showError("Login failed. Please check your connection.");
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> _debugCredentials() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final secretKey = secretKeyController.text.trim();

    print('\n🔍 DEBUG: Testing current credentials');
    print('Username: "$username"');
    print('Password: "$password"');
    print('Secret Key: "$secretKey"');

    if (username.isEmpty || password.isEmpty || secretKey.isEmpty) {
      print('❌ One or more fields are empty');
      return;
    }

    try {
      // Hash the credentials
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final hashedSecret = sha256.convert(utf8.encode(secretKey)).toString();

      print('\n📝 Generated hashes:');
      print('Password hash: $hashedPassword');
      print('Secret hash: $hashedSecret');

      // Query Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      print('\n📊 Firebase query result:');
      print('Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('❌ No admin found with username: "$username"');
        return;
      }

      final adminData = snapshot.docs.first.data();
      print('Document ID: ${snapshot.docs.first.id}');
      print('All fields: ${adminData.keys}');

      if (!adminData.containsKey('password')) {
        print('❌ No password field found');
        return;
      }

      if (!adminData.containsKey('security')) {
        print('❌ No security field found');
        return;
      }

      final storedPassword = adminData['password'];
      final storedSecret = adminData['security'];

      print('\n💾 Stored values in Firebase:');
      print('Stored password: $storedPassword');
      print('Stored secret: $storedSecret');

      print('\n🔍 Detailed comparison:');
      print('Password lengths - Input: ${hashedPassword.length}, Stored: ${storedPassword.length}');
      print('Secret lengths - Input: ${hashedSecret.length}, Stored: ${storedSecret.length}');
      print('Password match: ${hashedPassword == storedPassword ? '✅ YES' : '❌ NO'}');
      print('Secret match: ${hashedSecret == storedSecret ? '✅ YES' : '❌ NO'}');

      if (hashedPassword != storedPassword) {
        print('\n🔍 Password mismatch details:');
        print('First 10 chars of input hash: ${hashedPassword.substring(0, 10)}...');
        print('First 10 chars of stored hash: ${storedPassword.substring(0, 10)}...');
      }

      if (hashedSecret != storedSecret) {
        print('\n🔍 Secret mismatch details:');
        print('First 10 chars of input hash: ${hashedSecret.substring(0, 10)}...');
        print('First 10 chars of stored hash: ${storedSecret.substring(0, 10)}...');
      }

      if (hashedPassword == storedPassword && hashedSecret == storedSecret) {
        print('\n🎉 AUTHENTICATION WOULD SUCCEED!');
        showSuccess("Debug: Credentials are correct!");
      } else {
        print('\n❌ AUTHENTICATION WOULD FAIL!');
        showError("Debug: Credentials are incorrect!");
      }

    } catch (e) {
      print('❌ Error during debug: $e');
      showError("Debug error: $e");
    }
  }

  // Label Widget
  Widget textLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primary_color,
        ),
      ),
    );
  }

  // Generic Text Input Field
  Widget textInputField(
      TextEditingController controller,
      String hint,
      bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
    );
  }

  // Password Field with Eye Icon
  Widget passwordInputField() {
    return TextField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        hintText: "Enter password",
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade700,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:HostelMate/admin/AdminLogin.dart';
import 'package:HostelMate/hostelite/HSignUp.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectRolePage extends StatefulWidget {
  @override
  _SelectRolePageState createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  String selectedRole = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      await FirebaseFirestore.instance.collection('Users').add({
        'Name': "Harmi",
        'Email': "harmikotak@gmail.com",
      });
      print("User added successfully!");
    } catch (e) {
      print("Error adding user: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Text(
                "Choose Your Role",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: primary_color,
                ),
              ),
              SizedBox(height: 20),
              roleCard("assets/images/admin.png", "Admin"),
              SizedBox(height: 40),
              roleCard("assets/images/hostelite.png", "Hostelite"),

              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRole.isEmpty
                      ? null
                      : () {
                    if (selectedRole == "Admin") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminLoginPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HSignUpPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole.isEmpty ? Colors.grey : primary_color,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget roleCard(String imagePath, String roleName) {
    bool isSelected = selectedRole == roleName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleName;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 70),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary_color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 70,
              height: 70,
            ),
            SizedBox(height: 16),
            Text(
              roleName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: primary_color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:HostelMate/hostelite/HDashboard.dart';

class HSignUpPage extends StatefulWidget {
  final String hostelId;
  final String password;
  HSignUpPage({required this.hostelId, required this.password});

  @override
  _HSignUpPageState createState() => _HSignUpPageState();
}

class _HSignUpPageState extends State<HSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController fatherContactController = TextEditingController();
  final TextEditingController motherContactController = TextEditingController();
  final TextEditingController guardianEmailController = TextEditingController();

  String roomNumber = "";
  String bedNumber = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHosteliteDetails();
  }

  void fetchHosteliteDetails() async {
    final doc = await FirebaseFirestore.instance.collection("Users").doc(widget.hostelId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        roomNumber = data["RoomNumber"] ?? "";
        bedNumber = data["BedNumber"] ?? "";
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid Hostel ID"))
      );
      Navigator.pop(context);
    }
  }

  void saveProfile() async {
    if (nameController.text.isEmpty ||
        collegeController.text.isEmpty ||
        courseController.text.isEmpty ||
        numberController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill required fields correctly")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("Users").doc(widget.hostelId).update({
      "Name": nameController.text,
      "College": collegeController.text,
      "Course": courseController.text,
      "Phone": numberController.text,
      "Email": emailController.text,
      "Address": addressController.text,
      "FatherName": fatherNameController.text,
      "MotherName": motherNameController.text,
      "FatherContact": fatherContactController.text,
      "MotherContact": motherContactController.text,
      "GuardianEmail": guardianEmailController.text,
      "Password": widget.password
    });

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HDashboard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primary_color))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("Complete Profile", style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.w700, color: primary_color)),
                ),
                SizedBox(height: 30),

                sectionTitle("Hostel Details"),
                detailField("Hostel ID", widget.hostelId),
                detailField("Room Number", roomNumber),
                detailField("Bed Number", bedNumber),

                SizedBox(height: 20),
                sectionTitle("Personal Details"),
                textInput("Full Name", nameController),
                textInput("College", collegeController),
                textInput("Course", courseController),
                textInput("Phone Number", numberController, maxLength: 10, isNumber: true),
                textInput("Email Address", emailController),
                textInput("Address", addressController),

                SizedBox(height: 20),
                sectionTitle("Guardian Information"),
                textInput("Father's Name", fatherNameController),
                textInput("Mother's Name", motherNameController),
                textInput("Father's Contact", fatherContactController, maxLength: 10, isNumber: true),
                textInput("Mother's Contact", motherContactController, maxLength: 10, isNumber: true),
                textInput("Guardian Email", guardianEmailController),

                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_color,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text("Next", style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: primary_color)),
    );
  }

  Widget textInput(String label, TextEditingController controller, {int? maxLength, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        decoration: InputDecoration(
          counterText: "",
          hintText: label,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          filled: true,
          fillColor: Color(0xFFF8F8F8),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget detailField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text("$title: $value", style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
      ),
    );
  }
}

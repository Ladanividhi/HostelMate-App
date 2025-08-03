import 'package:HostelMate/hostelite/HDashboard.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HSignUpPage extends StatefulWidget {
  final String hostelId;
  final String password;
  final String docId;

  HSignUpPage({
    required this.hostelId,
    required this.password,
    required this.docId,
  });

  @override
  _HSignUpPageState createState() => _HSignUpPageState();
}

class _HSignUpPageState extends State<HSignUpPage> {
  String roomNumber = "";
  String bedNumber = "";
  bool isLoading = true;

  final TextEditingController hostelIdController = TextEditingController();
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

  String? selectedRoomNumber;
  String? selectedBedNumber;
  final List<String> roomNumbers = [
    for (int floor = 1; floor <= 5; floor++)
      for (int room = 1; room <= 12; room++)
        '${floor}${room.toString().padLeft(2, '0')}',
  ];

  final List<String> bedNumbers = ['A', 'B', 'C'];

  void fetchHosteliteDetails() async {
    final doc =
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.docId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        roomNumber = data["RoomNumber"]?.toString() ?? "";
        bedNumber = data["BedNumber"]?.toString() ?? "";
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid Hostel ID")));
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHosteliteDetails();
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool isValidPhone(String phone) {
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    return phoneRegExp.hasMatch(phone);
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
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

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.docId)
        .update({
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
          "Password": widget.password,
        });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HDashboard()),
    );
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Hostelite Sign Up",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: primary_color,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  sectionTitle("Personal Details"),
                  fieldLabel("Hostel ID"),
                  detailField("Hostel ID", widget.hostelId),
                  fieldLabel("Full Name"),
                  textInputField(nameController, "Enter Full Name"),
                  fieldLabel("College"),
                  textInputField(collegeController, "Enter College"),
                  fieldLabel("Course"),
                  textInputField(courseController, "Enter Course"),
                  fieldLabel("Phone Number"),
                  textInputField(
                    numberController,
                    "Enter Phone Number",
                    maxLength: 10,
                    isNumber: true,
                  ),
                  fieldLabel("Email Address"),
                  textInputField(emailController, "Enter Email"),
                  fieldLabel("Address"),
                  textInputField(addressController, "Enter Address"),

                  SizedBox(height: 28),

                  sectionTitle("Guardian Information"),
                  fieldLabel("Father's Name"),
                  textInputField(fatherNameController, "Enter Father's Name"),
                  fieldLabel("Mother's Name"),
                  textInputField(motherNameController, "Enter Mother's Name"),
                  fieldLabel("Father's Contact Number"),
                  textInputField(
                    fatherContactController,
                    "Enter Contact Number",
                    maxLength: 10,
                    isNumber: true,
                  ),
                  fieldLabel("Mother's Contact Number"),
                  textInputField(
                    motherContactController,
                    "Enter Contact Number",
                    maxLength: 10,
                    isNumber: true,
                  ),
                  fieldLabel("Guardian Email Address"),
                  textInputField(guardianEmailController, "Enter Email"),

                  SizedBox(height: 28),

                  sectionTitle("Room Information"),
                  fieldLabel("Room Number"),
                  detailField("Room Number", roomNumber),
                  fieldLabel("Bed Number"),
                  detailField("Bed Number", bedNumber),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty) {
                          showError("Full Name is required");
                          return;
                        }
                        if (collegeController.text.isEmpty) {
                          showError("College name is required");
                          return;
                        }
                        if (courseController.text.isEmpty) {
                          showError("Course name is required");
                          return;
                        }
                        if (numberController.text.isEmpty ||
                            !isValidPhone(numberController.text)) {
                          showError("Enter a valid 10-digit phone number");
                          return;
                        }
                        if (emailController.text.isNotEmpty &&
                            !isValidEmail(emailController.text)) {
                          showError("Enter a valid Email Address");
                          return;
                        }
                        if (addressController.text.isEmpty) {
                          showError("Address is required");
                          return;
                        }
                        if (fatherNameController.text.isEmpty) {
                          showError("Father's name is required");
                          return;
                        }
                        if (motherNameController.text.isEmpty) {
                          showError("Mother's name is required");
                          return;
                        }

                        if (fatherContactController.text.isNotEmpty &&
                            !isValidPhone(fatherContactController.text)) {
                          showError("Father's Contact must be 10 digits");
                          return;
                        }
                        if (motherContactController.text.isNotEmpty &&
                            !isValidPhone(motherContactController.text)) {
                          showError("Mother's Contact must be 10 digits");
                          return;
                        }

                        if (guardianEmailController.text.isNotEmpty &&
                            !isValidEmail(guardianEmailController.text)) {
                          showError("Enter a valid Guardian Email Address");
                          return;
                        }

                        saveProfile();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_color,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary_color,
        ),
      ),
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
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

  Widget textInputField(
    TextEditingController controller,
    String hint, {
    int? maxLength,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "",
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

  Widget detailField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "$title: $value",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

import 'package:HostelMate/hostelite/HDashboard.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HSignUpPage extends StatefulWidget {
  @override
  _HSignUpPageState createState() => _HSignUpPageState();
}

class _HSignUpPageState extends State<HSignUpPage> {

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
        '${floor}${room.toString().padLeft(2, '0')}'
  ];

  final List<String> bedNumbers = ['A', 'B', 'C'];

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
                  textInputField(hostelIdController, "Enter Hostel ID"),
                  fieldLabel("Full Name"),
                  textInputField(nameController, "Enter Full Name"),
                  fieldLabel("College"),
                  textInputField(collegeController, "Enter College"),
                  fieldLabel("Course"),
                  textInputField(courseController, "Enter Course"),
                  fieldLabel("Phone Number"),
                  textInputField(numberController, "Enter Phone Number", maxLength: 10, isNumber: true),
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
                  textInputField(fatherContactController, "Enter Contact Number", maxLength: 10, isNumber: true),
                  fieldLabel("Mother's Contact Number"),
                  textInputField(motherContactController, "Enter Contact Number", maxLength: 10, isNumber: true),
                  fieldLabel("Guardian Email Address"),
                  textInputField(guardianEmailController, "Enter Email"),

                  SizedBox(height: 28),

                  sectionTitle("Room Information"),
                  fieldLabel("Room Number"),
                  roomDropdown(),
                  fieldLabel("Bed Number"),
                  bedDropdown(),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HDashboard()),
                        );
                        // if (hostelIdController.text.isEmpty ||
                        //     nameController.text.isEmpty ||
                        //     collegeController.text.isEmpty ||
                        //     courseController.text.isEmpty ||
                        //     numberController.text.length != 10 ||
                        //     selectedRoomNumber == null ||
                        //     selectedBedNumber == null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text("Please fill all required fields correctly"),
                        //       backgroundColor: Colors.redAccent,
                        //     ),
                        //   );
                        //   return;
                        // }
                        //
                        // // Submit action — print values for now
                        // print("Hostel ID: ${hostelIdController.text}");
                        // print("Name: ${nameController.text}");
                        // print("College: ${collegeController.text}");
                        // print("Course: ${courseController.text}");
                        // print("Room: $selectedRoomNumber, Bed: $selectedBedNumber");
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
                  )
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

  Widget textInputField(TextEditingController controller, String hint,
      {int? maxLength, bool isNumber = false}) {
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

  Widget roomDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRoomNumber,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: roomNumbers
          .map((room) => DropdownMenuItem(value: room, child: Text(room)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedRoomNumber = value;
        });
      },
      hint: Text("Select Room Number", style: GoogleFonts.poppins(color: Colors.grey.shade500)),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
    );
  }

  Widget bedDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedBedNumber,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF8F8F8),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: bedNumbers
          .map((bed) => DropdownMenuItem(value: bed, child: Text(bed)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedBedNumber = value;
        });
      },
      hint: Text("Select Bed Number", style: GoogleFonts.poppins(color: Colors.grey.shade500)),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
    );
  }
}

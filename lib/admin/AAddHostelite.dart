import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart'; // Ensure your primary_color is defined here

class AddHostelitePage extends StatefulWidget {
  @override
  _AddHostelitePageState createState() => _AddHostelitePageState();
}

class _AddHostelitePageState extends State<AddHostelitePage> {
  final TextEditingController hostelIdController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController bedController = TextEditingController();

  bool isLoading = false;

  void addHostelite() async {
    final hostelId = hostelIdController.text.trim();
    final room = roomController.text.trim();
    final bed = bedController.text.trim();

    if (hostelId.isEmpty || room.isEmpty || bed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("Users").add({
        "HostelId": hostelId,
        "RoomNumber": room,
        "BedNumber": bed,
        "Email": "a", // for signup logic
        "JoiningDate": Timestamp.now(),

        // Null/default values
        "Name": null,
        "College": null,
        "Course": null,
        "Phone": null,
        "Password": null,
        "Address": null,
        "FatherName": null,
        "MotherName": null,
        "FatherContact": null,
        "MotherContact": null,
        "GuardianEmail": null,
        "ScannerImg": null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hostelite added successfully!")),
      );

      // Clear fields
      hostelIdController.clear();
      roomController.clear();
      bedController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
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
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: primary_color,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            "Add Hostelite",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textField("Hostelite ID", hostelIdController),
                  textField("Room Number", roomController),
                  textField("Bed Number", bedController),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : addHostelite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary_color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "Add Hostelite",
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


  Widget textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}

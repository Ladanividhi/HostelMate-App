import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:HostelMate/utils/Constants.dart';

class HFeedbackPage extends StatefulWidget {
  @override
  _HFeedbackPageState createState() => _HFeedbackPageState();
}

class _HFeedbackPageState extends State<HFeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
  String? selectedMeal;
  double rating = 3;
  bool isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (selectedMeal == null || feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a meal and enter feedback")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final feedbackRef = FirebaseFirestore.instance.collection("Feedback");

      // Step 1: Check if today's doc exists
      final existing = await feedbackRef.where("Date", isEqualTo: today).limit(1).get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final data = doc.data();

        // Prevent duplicate submission
        if (selectedMeal == "Breakfast" && data["Breakfast"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You already submitted Breakfast feedback today")),
          );
          setState(() => isSubmitting = false);
          return;
        }
        if (selectedMeal == "Lunch" && data["Lunch"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You already submitted Lunch feedback today")),
          );
          setState(() => isSubmitting = false);
          return;
        }
        if (selectedMeal == "Dinner" && data["Dinner"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You already submitted Dinner feedback today")),
          );
          setState(() => isSubmitting = false);
          return;
        }

        // Update today's document
        await feedbackRef.doc(doc.id).update({
          selectedMeal!: rating.round(),
          "${selectedMeal![0]}Msg": feedbackController.text.trim(),
        });
      } else {
        // Create new doc for today
        await feedbackRef.add({
          "Date": today,
          "Breakfast": selectedMeal == "Breakfast" ? rating.round() : null,
          "BMsg": selectedMeal == "Breakfast" ? feedbackController.text.trim() : "",
          "Lunch": selectedMeal == "Lunch" ? rating.round() : null,
          "LMsg": selectedMeal == "Lunch" ? feedbackController.text.trim() : "",
          "Dinner": selectedMeal == "Dinner" ? rating.round() : null,
          "DMsg": selectedMeal == "Dinner" ? feedbackController.text.trim() : "",
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback submitted successfully")),
      );

      setState(() {
        selectedMeal = null;
        rating = 3;
        feedbackController.clear();
      });
    } catch (e) {
      print("❌ Error submitting feedback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildMealSelector(String meal) {
    final isSelected = selectedMeal == meal;
    return ChoiceChip(
      label: Text(meal, style: GoogleFonts.poppins(fontSize: 14)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedMeal = selected ? meal : null;
        });
      },
      selectedColor: primary_color.withOpacity(0.2),
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? primary_color : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: primary_color,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1.0;
            });
          },
        );
      }),
    );
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
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "Meal Feedback",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Meal selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMealSelector("Breakfast"),
                  _buildMealSelector("Lunch"),
                  _buildMealSelector("Dinner"),
                ],
              ),
              SizedBox(height: 20),

              // Rating
              Text("Rate your meal", style: GoogleFonts.poppins(fontSize: 16)),
              _buildRatingStars(),

              // Feedback text
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your feedback...",
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Submit Feedback",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

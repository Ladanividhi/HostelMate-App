import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:intl/intl.dart';

class AHostelitePage extends StatefulWidget {
  @override
  _AHostelitePageState createState() => _AHostelitePageState();
}

class _AHostelitePageState extends State<AHostelitePage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> hostelites = [];
  List<Map<String, dynamic>> filteredHostelites = [];

  @override
  void initState() {
    super.initState();
    fetchHostelites();
  }

  /// Fetch hostelites from Firestore (Users collection)
  Future<void> fetchHostelites() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Users').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        final d = doc.data();
        d["docId"] = doc.id; // keep docId separately (but we won’t display it)
        return d;
      }).toList();

      setState(() {
        hostelites = data;
        filteredHostelites = data;
      });
    } catch (e) {
      print("Error fetching hostelites: $e");
    }
  }

  void searchHostelite(String query) {
    final input = query.toLowerCase();
    final results = hostelites.where((hostelite) {
      final name = (hostelite["Name"] ?? "").toString().toLowerCase();
      final room = (hostelite["RoomNumber"] ?? "").toString().toLowerCase();
      final id = (hostelite["HostelId"] ?? "").toString().toLowerCase();

      return name.contains(input) ||
          room.contains(input) ||
          id.contains(input);
    }).toList();

    setState(() {
      filteredHostelites = results;
    });
  }

  /// Format Firestore Timestamp or DateTime into readable format
  String formatDate(dynamic dateValue, {bool onlyDate = false}) {
    if (dateValue == null) return "-";
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return dateValue.toString();
      }
      return DateFormat(onlyDate ? "dd MMM yyyy" : "dd MMM yyyy, h:mm a").format(date);
    } catch (e) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separate new admissions (Email == "a") and others
    final newAdmissions = filteredHostelites.where((h) => h["Email"] == "a").toList();
    final others = filteredHostelites.where((h) => h["Email"] != "a").toList();

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
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: primary_color,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            "Hostelites",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: searchController,
                  onChanged: searchHostelite,
                  decoration: InputDecoration(
                    hintText: "Search by name, hostel ID or room no.",
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),

              SizedBox(height: 18),

              // Hostelites list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (newAdmissions.isNotEmpty) ...[
                      Text(
                        "New Admissions",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      ...newAdmissions.map((h) => newAdmissionCard(h)).toList(),
                      Divider(thickness: 1.5, color: Colors.grey.shade400),
                    ],
                    ...others.map((h) => hosteliteCard(h)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card for NEW ADMISSIONS (only few fields)
  Widget newAdmissionCard(Map<String, dynamic> h) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: bg_color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow("Hostel ID", h["HostelId"]),
              infoRow("Room Number", h["RoomNumber"]),
              infoRow("Bed Number", h["BedNumber"]),
              infoRow("Secret Code", h["SecretCode"]),
              if (h["AdmissionDate"] != null)
                infoRow("Admission Date", formatDate(h["AdmissionDate"], onlyDate: true)),
            ],
          ),
        ),
      ),
    );
  }

  /// Card for OTHER hostelites (ordered fields)
  Widget hosteliteCard(Map<String, dynamic> h) {
    // define field order
    final fieldOrder = [
      "Name",
      "BedNumber",
      "RoomNumber",
      "PhoneNumber",
      "College",
      "Course",
      "FatherName",
      "FatherContact",
      "MotherName",
      "MotherContact",
      "AdmissionDate",
      "GuardianEmail",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: bg_color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              "${h["Name"] ?? "Unknown"}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primary_color,
              ),
            ),
            subtitle: Text(
              "Hostel ID: ${h["HostelId"] ?? "-"} | Room: ${h["RoomNumber"] ?? "-"}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            children: [
              for (var key in fieldOrder)
                if (h.containsKey(key))
                  detailRow(key, h[key], onlyDate: key == "AdmissionDate"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        "$title: ${value ?? "-"}",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget detailRow(String title, dynamic value, {bool onlyDate = false}) {
    String displayValue = (value is Timestamp || value is DateTime)
        ? formatDate(value, onlyDate: onlyDate)
        : (value?.toString() ?? "-");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

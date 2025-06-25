import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';

class AHostelitePage extends StatefulWidget {
  @override
  _AHostelitePageState createState() => _AHostelitePageState();
}

class _AHostelitePageState extends State<AHostelitePage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> hostelites = [
    {
      "hostelId": "H001",
      "name": "Vidhi Ladani",
      "room": "302",
      "bed": "B",
      "college": "Marwadi University",
      "course": "CE",
      "number": "9999988888",
      "email": "vidhi@gmail.com",
      "address": "Rajkot",
      "fatherName": "Avanish Ladani",
      "motherName": "Reshma Ladani",
      "fatherContact": "9999911111",
      "motherContact": "9999922222",
      "guardianEmail": "avanish@gmail.com",
    },
    {
      "hostelId": "H002",
      "name": "Aarav Mehta",
      "room": "305",
      "bed": "A",
      "college": "Darshan University",
      "course": "IT",
      "number": "9876543210",
      "email": "aaravmehta@gmail.com",
      "address": "Surat",
      "fatherName": "Hiren Mehta",
      "motherName": "Pooja Mehta",
      "fatherContact": "9977551122",
      "motherContact": "9966553344",
      "guardianEmail": "hiren.mehta@gmail.com",
    },
    {
      "hostelId": "H003",
      "name": "Ishita Shah",
      "room": "308",
      "bed": "C",
      "college": "Marwadi University",
      "course": "CSE",
      "number": "9012345678",
      "email": "ishita.shah@gmail.com",
      "address": "Vadodara",
      "fatherName": "Milan Shah",
      "motherName": "Neha Shah",
      "fatherContact": "9898989898",
      "motherContact": "9879879876",
      "guardianEmail": "milan.shah@gmail.com",
    },
    {
      "hostelId": "H004",
      "name": "Devansh Patel",
      "room": "210",
      "bed": "A",
      "college": "Silver Oak University",
      "course": "ME",
      "number": "9823001122",
      "email": "devansh.patel@gmail.com",
      "address": "Ahmedabad",
      "fatherName": "Jayant Patel",
      "motherName": "Kavita Patel",
      "fatherContact": "9876500012",
      "motherContact": "9876503344",
      "guardianEmail": "jayant.patel@gmail.com",
    },
    {
      "hostelId": "H005",
      "name": "Sanya Joshi",
      "room": "410",
      "bed": "C",
      "college": "Marwadi University",
      "course": "EEE",
      "number": "9988776655",
      "email": "sanya.joshi@gmail.com",
      "address": "Bhavnagar",
      "fatherName": "Dilip Joshi",
      "motherName": "Jaya Joshi",
      "fatherContact": "9988001100",
      "motherContact": "9988001122",
      "guardianEmail": "dilip.joshi@gmail.com",
    },
    {
      "hostelId": "H006",
      "name": "Krish Solanki",
      "room": "412",
      "bed": "B",
      "college": "Nirma University",
      "course": "CE",
      "number": "9823445566",
      "email": "krish.solanki@gmail.com",
      "address": "Jamnagar",
      "fatherName": "Bhavesh Solanki",
      "motherName": "Kiran Solanki",
      "fatherContact": "9811112233",
      "motherContact": "9811113344",
      "guardianEmail": "bhavesh.solanki@gmail.com",
    },
    {
      "hostelId": "H007",
      "name": "Meera Desai",
      "room": "503",
      "bed": "A",
      "college": "Marwadi University",
      "course": "CSE",
      "number": "9900990011",
      "email": "meera.desai@gmail.com",
      "address": "Anand",
      "fatherName": "Jignesh Desai",
      "motherName": "Payal Desai",
      "fatherContact": "9988997788",
      "motherContact": "9988776655",
      "guardianEmail": "jignesh.desai@gmail.com",
    },
    {
      "hostelId": "H008",
      "name": "Raghav Bhatt",
      "room": "205",
      "bed": "C",
      "college": "Parul University",
      "course": "IT",
      "number": "9090909090",
      "email": "raghav.bhatt@gmail.com",
      "address": "Gandhinagar",
      "fatherName": "Mahesh Bhatt",
      "motherName": "Kajal Bhatt",
      "fatherContact": "9876543456",
      "motherContact": "9876547890",
      "guardianEmail": "mahesh.bhatt@gmail.com",
    },
    {
      "hostelId": "H009",
      "name": "Riya Patel",
      "room": "304",
      "bed": "A",
      "college": "Marwadi University",
      "course": "ME",
      "number": "9123456780",
      "email": "riya.patel@gmail.com",
      "address": "Rajkot",
      "fatherName": "Kalpesh Patel",
      "motherName": "Sonali Patel",
      "fatherContact": "9900112233",
      "motherContact": "9900113344",
      "guardianEmail": "kalpesh.patel@gmail.com",
    },
    {
      "hostelId": "H010",
      "name": "Yash Shah",
      "room": "502",
      "bed": "B",
      "college": "Darshan University",
      "course": "CSE",
      "number": "9876547890",
      "email": "yash.shah@gmail.com",
      "address": "Surendranagar",
      "fatherName": "Rajesh Shah",
      "motherName": "Anita Shah",
      "fatherContact": "9811223344",
      "motherContact": "9811556677",
      "guardianEmail": "rajesh.shah@gmail.com",
    },
  ];


  List<Map<String, String>> filteredHostelites = [];

  @override
  void initState() {
    super.initState();
    filteredHostelites = hostelites;
  }

  void searchHostelite(String query) {
    final results = hostelites.where((hostelite) {
      final name = hostelite["name"]!.toLowerCase();
      final room = hostelite["room"]!;
      final id = hostelite["hostelId"]!.toLowerCase();
      final input = query.toLowerCase();

      return name.contains(input) ||
          room.contains(input) ||
          id.contains(input);
    }).toList();

    setState(() {
      filteredHostelites = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary_color,
        elevation: 0,
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

            // List of hostelites
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredHostelites.length,
                itemBuilder: (context, index) {
                  final h = filteredHostelites[index];
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
                          tilePadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            "${h["name"]}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primary_color,
                            ),
                          ),
                          subtitle: Text(
                            "Hostel ID: ${h["hostelId"]} | Room: ${h["room"]}",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          children: [
                            detailRow("Hostel ID", h["hostelId"]!),
                            detailRow("Name", h["name"]!),
                            detailRow("College", h["college"]!),
                            detailRow("Course", h["course"]!),
                            detailRow("Phone", h["number"]!),
                            detailRow("Email", h["email"]!),
                            detailRow("Address", h["address"]!),
                            detailRow("Father's Name", h["fatherName"]!),
                            detailRow("Mother's Name", h["motherName"]!),
                            detailRow("Father's Contact", h["fatherContact"]!),
                            detailRow("Mother's Contact", h["motherContact"]!),
                            detailRow("Guardian Email", h["guardianEmail"]!),
                            detailRow("Room", h["room"]!),
                            detailRow("Bed", h["bed"]!),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
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
              value,
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

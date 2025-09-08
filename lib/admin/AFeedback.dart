import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:HostelMate/utils/Constants.dart';

class AFeedbackPage extends StatefulWidget {
  @override
  State<AFeedbackPage> createState() => _AFeedbackPageState();
}

class _AFeedbackPageState extends State<AFeedbackPage> {
  List<Map<String, dynamic>> feedbackData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }
  List<PieChartSectionData> _generatePieSections() {
    int positive = 0;
    int neutral = 0;
    int negative = 0;

    for (var f in feedbackData) {
      for (var meal in ["breakfast", "lunch", "dinner"]) {
        final rating = f[meal] ?? 0;
        if (rating >= 4) {
          positive++;
        } else if (rating >= 2) {
          neutral++;
        } else {
          negative++;
        }
      }
    }

    final total = positive + neutral + negative;

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          title: "No Data",
          color: Colors.grey,
          radius: 60,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: positive.toDouble(),
        title: "Positive\n${((positive / total) * 100).toStringAsFixed(1)}%",
        color: Colors.green,
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: neutral.toDouble(),
        title: "Neutral\n${((neutral / total) * 100).toStringAsFixed(1)}%",
        color: Colors.orange,
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: negative.toDouble(),
        title: "Negative\n${((negative / total) * 100).toStringAsFixed(1)}%",
        color: Colors.red,
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }


  Future<void> fetchFeedback() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("Feedback").get();

      final data = snapshot.docs.map((doc) {
        final d = doc.data();

        DateTime date;
        if (d["Date"] is Timestamp) {
          date = (d["Date"] as Timestamp).toDate();
        } else if (d["Date"] is String) {
          date = DateTime.tryParse(d["Date"]) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        final breakfast = (d["Breakfast"] ?? 0).toDouble();
        final lunch = (d["Lunch"] ?? 0).toDouble();
        final dinner = (d["Dinner"] ?? 0).toDouble();

        final avg = ((breakfast + lunch + dinner) / 3);

        return {
          "date": date,
          "breakfast": breakfast,
          "lunch": lunch,
          "dinner": dinner,
          "avg": avg,
        };
      }).toList();

      // Sort by date (latest first)
      data.sort((a, b) => b["date"].compareTo(a["date"]));

      setState(() {
        feedbackData = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching feedback: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary_color,
        title: Text("Feedback Analysis",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Table
            // Pie Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _generatePieSections(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 4,
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(height: 30),

            // Graph
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: primary_color),
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Breakfast")),
                    DataColumn(label: Text("Lunch")),
                    DataColumn(label: Text("Dinner")),
                    DataColumn(label: Text("Average")),
                  ],
                  rows: feedbackData.map((f) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            DateFormat('dd MMM yyyy').format(f["date"]))),
                        DataCell(Text(f["breakfast"].toString())),
                        DataCell(Text(f["lunch"].toString())),
                        DataCell(Text(f["dinner"].toString())),
                        DataCell(Text(f["avg"].toStringAsFixed(1))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
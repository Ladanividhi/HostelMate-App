import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddHostelitePage extends StatefulWidget {
  @override
  _AddHostelitePageState createState() => _AddHostelitePageState();
}

class _AddHostelitePageState extends State<AddHostelitePage> {
  List<String> availableRooms = [];
  List<String> availableBeds = ['A', 'B', 'C'];
  String? selectedRoom;
  String? selectedBed;
  final TextEditingController secretCodeController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ensureSignedIn();
    fetchAvailableRooms();
  }
  Future<void> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }
  Future<void> fetchAvailableRooms() async {
    final snapshot = await FirebaseFirestore.instance.collection("Rooms").get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();

    Map<String, List<Map<String, dynamic>>> roomGroups = {};

    for (var doc in data) {
      final room = doc["RoomNumber"].toString();
      roomGroups.putIfAbsent(room, () => []).add(doc);
    }

    List<String> freeRooms = [];
    roomGroups.forEach((room, beds) {
      if (beds.length == 3 && beds.every((bed) => bed["Status"] == false)) {
        freeRooms.add(room);
      }
    });

    // Sort numerically
    freeRooms.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    setState(() {
      availableRooms = freeRooms;
    });
  }

  Future<String> generateUniqueHostelId() async {
    final rand = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    while (true) {
      // Generate ID like HOS_AB_123
      final xx = List.generate(2, (_) => letters[rand.nextInt(letters.length)]).join();
      final yyy = rand.nextInt(900) + 100;
      final hostelId = 'HOS_${xx}_$yyy';

      // Check if it already exists
      final existing = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hostelId)
          .limit(1)
          .get();

      // If not found in Users table, return it
      if (existing.docs.isEmpty) {
        return hostelId;
      }
      // Else loop continues to generate a new one
    }
  }
  Future<String?> generateAndUploadQrCode(String hostelId) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: hostelId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception("Invalid QR data");
      }

      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xFF000000),
        emptyColor: Colors.white,
        gapless: true,
      );

      final picData = await painter.toImageData(300);
      final bytes = picData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$hostelId.png');
      await file.writeAsBytes(bytes);

      final ref = FirebaseStorage.instance
          .ref()
          .child('qr_codes')
          .child('$hostelId.png');
      final uploadTask = await ref.putFile(file);

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("QR Generation/Upload error: $e");
      return null;
    }
  }



  void addHostelite(String hostelId) async {
    final room = selectedRoom!;
    final bed = selectedBed!;

    setState(() => isLoading = true);

    try {
      final String? qrUrl = await generateAndUploadQrCode(hostelId);
      await FirebaseFirestore.instance.collection("Users").add({
        "HostelId": hostelId,
        "RoomNumber": room,
        "BedNumber": bed,
        "Email": "a",
        "JoiningDate": Timestamp.now(),
        "SecretCode": secretCodeController.text,
        // Default/null values
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
        "ScannerImg": qrUrl,
      });

      final roomSnapshot = await FirebaseFirestore.instance
          .collection("Rooms")
          .where("RoomNumber", isEqualTo: room)
          .where("BedNumber", isEqualTo: bed)
          .limit(1)
          .get();

      if (roomSnapshot.docs.isNotEmpty) {
        final roomDocId = roomSnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection("Rooms")
            .doc(roomDocId)
            .update({"Status": true});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hostelite added successfully!")),
      );

      secretCodeController.clear();
      setState(() => selectedBed = null);
      setState(() => selectedRoom = null);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleAddPressed() async {
    final room = selectedRoom;
    final secret = secretCodeController.text.trim();

    if (room == null || selectedBed == null || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    final hostelId = await generateUniqueHostelId();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        title: Center(
          child: Text(
            "Confirm Details",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primary_color,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            infoRow("Hostel ID", hostelId),
            const SizedBox(height: 8),
            infoRow("Room Number", room),
            const SizedBox(height: 8),
            infoRow("Bed Number", selectedBed!),
            const SizedBox(height: 8),
            infoRow("Secret Code", secret),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                addHostelite(hostelId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }


  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text("$label:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
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
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: primary_color,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text("Add Hostelite", style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          ),
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
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Room Number", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRoom,
                    hint: Text("Select Room Number", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                    items: availableRooms.map((room) {
                      return DropdownMenuItem<String>(
                        value: room,
                        child: Text(room, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      setState(() {
                        selectedRoom = val;
                        // selectedBed = null;
                        // availableBeds = [];
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bed Number", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedBed,
                          hint: Text("Select Bed Number", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                          items: availableBeds.map((bed) {
                            return DropdownMenuItem<String>(
                              value: bed,
                              child: Text(bed, style: GoogleFonts.poppins()),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            if (selectedRoom == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please select Room Number first")),
                              );
                              return;
                            }

                            // Check if this bed is already occupied
                            final snapshot = await FirebaseFirestore.instance
                                .collection("Rooms")
                                .where("RoomNumber", isEqualTo: selectedRoom)
                                .where("BedNumber", isEqualTo: val)
                                .limit(1)
                                .get();

                            if (snapshot.docs.isNotEmpty) {
                              final status = snapshot.docs.first.data()["Status"];
                              if (status == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("This bed is not vacant. Please select another Room or Bed.")),
                                );
                                return;
                              }
                            }

                            setState(() => selectedBed = val);
                          },

                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8F8F8),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),
                  textField("Secret Code", secretCodeController),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleAddPressed,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
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
        ],
      ),
    );
  }

}
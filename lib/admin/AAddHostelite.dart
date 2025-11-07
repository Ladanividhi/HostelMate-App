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

  // Debug method to test QR generation
  Future<void> testQrGeneration() async {
    print("🧪 Testing QR generation...");
    final testId = "TEST_QR_123";
    
    // Test QR generation without upload first
    try {
      final painter = QrPainter(
        data: testId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        color: const Color(0xFF000000),
        emptyColor: Colors.white,
        gapless: true,
      );

      final picData = await painter.toImageData(200);
      if (picData != null) {
        print("✅ QR generation test successful - image data created");
        final bytes = picData.buffer.asUint8List();
        print("📊 Generated ${bytes.length} bytes");
        
        // Test file writing
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/test_qr.png');
        await file.writeAsBytes(bytes);
        print("✅ File written successfully: ${file.path}");
      } else {
        print("❌ QR generation test failed - no image data");
      }
    } catch (e) {
      print("❌ QR generation test error: $e");
      print("❌ Error stack trace: ${StackTrace.current}");
    }
  }

  // Alternative QR generation method using a simpler approach
  Future<String?> generateSimpleQrCode(String hostelId) async {
    try {
      print("🔍 Generating simple QR for hostel ID: $hostelId");
      
      // Create a simple QR code
      final painter = QrPainter(
        data: hostelId,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        color: const Color(0xFF000000),
        emptyColor: Colors.white,
        gapless: false,
      );

      // Convert to image data
      final picData = await painter.toImageData(100);
      if (picData == null) {
        print("❌ Simple QR generation failed");
        return null;
      }

      final bytes = picData.buffer.asUint8List();
      print("📊 Simple QR bytes: ${bytes.length}");

      // Save to file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/simple_$hostelId.png');
      await file.writeAsBytes(bytes);

      // Check Firebase Auth before upload
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        print("❌ No Firebase user signed in, cannot upload");
        throw Exception("Firebase authentication required");
      }

      // Upload to Firebase
      final ref = FirebaseStorage.instance
          .ref()
          .child('qr_codes')
          .child('simple_$hostelId.png');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      print("✅ Simple QR uploaded: $url");
      return url;
    } catch (e) {
      print("❌ Simple QR error: $e");
      return null;
    }
  }
  Future<void> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      try {
        await auth.signInAnonymously();
        print("✅ Firebase Auth: Signed in anonymously");
      } catch (e) {
        print("❌ Firebase Auth error: $e");
      }
    } else {
      print("✅ Firebase Auth: Already signed in as ${auth.currentUser?.uid}");
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
      print("🔍 Generating QR for hostel ID: $hostelId");
      
      // Ensure Firebase Auth is signed in
      await ensureSignedIn();
      
      // Method 1: Try with QrPainter
      try {
        final painter = QrPainter(
          data: hostelId,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          color: const Color(0xFF000000),
          emptyColor: Colors.white,
          gapless: true,
        );

        final picData = await painter.toImageData(200);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          print("📊 QR image bytes generated: ${bytes.length} bytes");

          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$hostelId.png');
          await file.writeAsBytes(bytes);

          print("📦 File written at: ${file.path}");

          // Check Firebase Auth before upload
          final auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            print("❌ No Firebase user signed in, cannot upload");
            throw Exception("Firebase authentication required");
          }

          // Upload to Firebase Storage
          final ref = FirebaseStorage.instance
              .ref()
              .child('qr_codes')
              .child('$hostelId.png');

          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          print("✅ Upload completed, bytes transferred: ${snapshot.bytesTransferred}");

          final url = await ref.getDownloadURL();
          print("✅ QR uploaded successfully: $url");
          return url;
        }
      } catch (e) {
        print("⚠️ Method 1 failed: $e");
      }

      // Method 2: Try with QrValidator first
      try {
        final qrValidationResult = QrValidator.validate(
          data: hostelId,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        );

        if (qrValidationResult.status == QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const Color(0xFF000000),
            emptyColor: Colors.white,
            gapless: true,
          );

          final picData = await painter.toImageData(200);
          if (picData != null) {
                      final bytes = picData.buffer.asUint8List();
          print("📊 QR image bytes generated (Method 2): ${bytes.length} bytes");

          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$hostelId.png');
          await file.writeAsBytes(bytes);

          // Check Firebase Auth before upload
          final auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            print("❌ No Firebase user signed in, cannot upload");
            throw Exception("Firebase authentication required");
          }

          final ref = FirebaseStorage.instance
              .ref()
              .child('qr_codes')
              .child('$hostelId.png');

          final uploadTask = ref.putFile(file);
          await uploadTask;

          final url = await ref.getDownloadURL();
          print("✅ QR uploaded successfully (Method 2): $url");
          return url;
          }
        }
      } catch (e) {
        print("⚠️ Method 2 failed: $e");
      }

      // Method 3: Try with a different size
      try {
        final painter = QrPainter(
          data: hostelId,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          color: const Color(0xFF000000),
          emptyColor: Colors.white,
          gapless: false,
        );

        final picData = await painter.toImageData(150);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          print("📊 QR image bytes generated (Method 3): ${bytes.length} bytes");

          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$hostelId.png');
          await file.writeAsBytes(bytes);

          // Check Firebase Auth before upload
          final auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            print("❌ No Firebase user signed in, cannot upload");
            throw Exception("Firebase authentication required");
          }

          final ref = FirebaseStorage.instance
              .ref()
              .child('qr_codes')
              .child('$hostelId.png');

          final uploadTask = ref.putFile(file);
          await uploadTask;

          final url = await ref.getDownloadURL();
          print("✅ QR uploaded successfully (Method 3): $url");
          return url;
        }
      } catch (e) {
        print("⚠️ Method 3 failed: $e");
      }

      // Method 4: Try simple QR generation
      try {
        final simpleUrl = await generateSimpleQrCode(hostelId);
        if (simpleUrl != null) {
          print("✅ Simple QR method succeeded: $simpleUrl");
          return simpleUrl;
        }
      } catch (e) {
        print("⚠️ Simple QR method failed: $e");
      }

      // Method 5: Check if QR code already exists in Firebase Storage
      try {
        print("🔍 Checking if QR code already exists in Firebase Storage for: $hostelId");
        final ref = FirebaseStorage.instance
            .ref()
            .child('qr_codes')
            .child('$hostelId.png');
        
        try {
          final existingUrl = await ref.getDownloadURL();
          print("✅ QR code already exists in Firebase Storage: $existingUrl");
          return existingUrl;
        } catch (e) {
          print("⚠️ QR code not found in Firebase Storage, will try to upload again");
        }
      } catch (e) {
        print("⚠️ Error checking Firebase Storage: $e");
      }

      // Method 6: Create local QR code without Firebase Storage (last resort)
      try {
        print("🔍 Creating local QR code for hostel ID: $hostelId");
        
        final painter = QrPainter(
          data: hostelId,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
          color: const Color(0xFF000000),
          emptyColor: Colors.white,
          gapless: false,
        );

        final picData = await painter.toImageData(150);
        if (picData != null) {
          final bytes = picData.buffer.asUint8List();
          print("📊 Local QR bytes: ${bytes.length}");

          // Try one more time to upload to Firebase Storage
          try {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/$hostelId.png');
            await tempFile.writeAsBytes(bytes);

            final auth = FirebaseAuth.instance;
            if (auth.currentUser != null) {
              final ref = FirebaseStorage.instance
                  .ref()
                  .child('qr_codes')
                  .child('$hostelId.png');

              final uploadTask = ref.putFile(tempFile);
              await uploadTask;
              final url = await ref.getDownloadURL();
              print("✅ Successfully uploaded to Firebase Storage: $url");
              return url;
            }
          } catch (uploadError) {
            print("⚠️ Final upload attempt failed: $uploadError");
          }

          // Save to app documents directory (persistent) as last resort
          final appDir = await getApplicationDocumentsDirectory();
          final qrDir = Directory('${appDir.path}/qr_codes');
          if (!await qrDir.exists()) {
            await qrDir.create(recursive: true);
          }
          
          final file = File('${qrDir.path}/$hostelId.png');
          await file.writeAsBytes(bytes);
          
          print("✅ Local QR saved: ${file.path}");
          print("⚠️ Warning: Using local file path. Firebase Storage URL preferred.");
          // Return a data URL or file path that can be used
          return "file://${file.path}";
        }
      } catch (e) {
        print("⚠️ Local QR method failed: $e");
      }

      // If all methods fail, create a placeholder URL
      print("⚠️ All QR generation methods failed, using placeholder");
      return "https://via.placeholder.com/200x200/000000/FFFFFF?text=QR+Failed";
      
    } catch (e) {
      print("❌ QR Generation/Upload error: $e");
      print("❌ Error stack trace: ${StackTrace.current}");
      return "https://via.placeholder.com/200x200/000000/FFFFFF?text=QR+Error";
    }
  }

//vbghvhyjb,jhb
  void addHostelite(String hostelId) async {
    final room = selectedRoom!;
    final bed = selectedBed!;

    setState(() => isLoading = true);

    try {
      print("🚀 Starting hostelite addition process...");
      print("📋 Details - Hostel ID: $hostelId, Room: $room, Bed: $bed");
      
      // Step 1: Generate QR Code
      print("🔍 Step 1: Generating QR code...");
      final String? qrUrl = await generateAndUploadQrCode(hostelId);
      print("✅✅✅✅✅QR URL: $qrUrl");

      if (qrUrl == null || qrUrl.contains("placeholder")) {
        print("❌ QR generation failed, showing error message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("QR generation failed. Please try again."),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      print("✅ QR URL obtained: $qrUrl");
      
      // Step 2: Add to Users collection
      print("🔍 Step 2: Adding to Users collection...");
      final userData = {
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
      };
      
      print("📋 User data to be added: $userData");
      
      final userDocRef = await FirebaseFirestore.instance.collection("Users").add(userData);
      print("✅ User added successfully with ID: ${userDocRef.id}");

      // Step 3: Update Room status
      print("🔍 Step 3: Updating room status...");
      final roomSnapshot = await FirebaseFirestore.instance
          .collection("Rooms")
          .where("RoomNumber", isEqualTo: room)
          .where("BedNumber", isEqualTo: bed)
          .limit(1)
          .get();

      print("📋 Found ${roomSnapshot.docs.length} room documents");

      if (roomSnapshot.docs.isNotEmpty) {
        final roomDocId = roomSnapshot.docs.first.id;
        print("📋 Updating room document: $roomDocId");
        
        await FirebaseFirestore.instance
            .collection("Rooms")
            .doc(roomDocId)
            .update({"Status": true});
        print("✅ Room status updated successfully");
      } else {
        print("⚠️ No room document found to update");
      }

      // Step 4: Verify the hostelite was added
      print("🔍 Step 4: Verifying hostelite was added...");
      final verifySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("HostelId", isEqualTo: hostelId)
          .limit(1)
          .get();
      
      if (verifySnapshot.docs.isNotEmpty) {
        print("✅ Hostelite verification successful: ${verifySnapshot.docs.first.id}");
      } else {
        print("⚠️ Hostelite verification failed: No document found");
      }

      // Step 5: Success message and cleanup
      print("✅ All operations completed successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hostelite added successfully!"),
        ),
      );

      secretCodeController.clear();
      setState(() => selectedBed = null);
      setState(() => selectedRoom = null);
      
      // Refresh available rooms
      await fetchAvailableRooms();

    } catch (e) {
      print("❌ Error in addHostelite: $e");
      print("❌ Error stack trace: ${StackTrace.current}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding hostelite: $e"),
        ),
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
                  const SizedBox(height: 16),
                  // Debug button - remove this in production

                  // Firestore test button

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
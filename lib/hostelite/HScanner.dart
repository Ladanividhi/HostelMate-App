import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HScannerPage extends StatefulWidget {
  const HScannerPage({Key? key}) : super(key: key);

  @override
  State<HScannerPage> createState() => _HScannerPageState();
}

class _HScannerPageState extends State<HScannerPage> {
  String? scannerImgUrl;
  String? hostelId;
  String? roomNumber;
  String? bedNumber;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";
  final TextEditingController hostelIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchScannerImage();
  }

  @override
  void dispose() {
    hostelIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchScannerImage() async {
    try {
      print("🔍 Starting to fetch scanner image...");
      
      // Method 1: Try to get hostelite data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final storedHostelId = prefs.getString('hostelite_id');
      final storedScannerImg = prefs.getString('hostelite_scanner_img');
      final storedRoom = prefs.getString('hostelite_room');
      final storedBed = prefs.getString('hostelite_bed');
      
      if (storedHostelId != null && storedHostelId.isNotEmpty) {
        print("✅ Found hostelite data in shared preferences:");
        print("   - Hostel ID: $storedHostelId");
        print("   - Scanner Image: $storedScannerImg");
        print("   - Room: $storedRoom");
        print("   - Bed: $storedBed");
        
        setState(() {
          hostelId = storedHostelId;
          scannerImgUrl = storedScannerImg;
          roomNumber = storedRoom;
          bedNumber = storedBed;
          isLoading = false;
        });
        return;
      }

      // Method 2: Try to get from current user document (if user is signed in with their HostelId)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print("👤 Current user UID: ${currentUser.uid}");
        
        // Try to find user document by UID first
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data()!;
            setState(() {
              scannerImgUrl = data['ScannerImg'];
              hostelId = data['HostelId'];
              roomNumber = data['RoomNumber'];
              bedNumber = data['BedNumber'];
              isLoading = false;
            });
            print("✅ Found user document by UID");
            return;
          }
        } catch (e) {
          print("⚠️ Could not find user by UID: $e");
        }
      }

      // Method 3: If no data found, ask user to enter their HostelId
      print("⚠️ No hostelite data found, asking user to enter Hostel ID");
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = "Please enter your Hostel ID to view your scanner";
      });
      
    } catch (e) {
      print("❌ Error fetching scanner image: $e");
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = "Error: $e";
      });
    }
  }

  Future<void> _fetchByHostelId(String hostelId) async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      print("🔍 Fetching scanner for Hostel ID: $hostelId");
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('HostelId', isEqualTo: hostelId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No hostelite found with Hostel ID: $hostelId");
      }

      final data = querySnapshot.docs.first.data();
      print("✅ Found hostelite data: $data");
      
      // Store the data in shared preferences for future use
      await _storeHosteliteData(hostelId, data);
      
      setState(() {
        scannerImgUrl = data['ScannerImg'];
        hostelId = data['HostelId'];
        roomNumber = data['RoomNumber'];
        bedNumber = data['BedNumber'];
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching by Hostel ID: $e");
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = "Error: $e";
      });
    }
  }

  Future<void> _storeHosteliteData(String hostelId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store hostelite ID and other useful data
      await prefs.setString('hostelite_id', hostelId);
      await prefs.setString('hostelite_room', userData['RoomNumber']?.toString() ?? '');
      await prefs.setString('hostelite_bed', userData['BedNumber']?.toString() ?? '');
      await prefs.setString('hostelite_scanner_img', userData['ScannerImg']?.toString() ?? '');
      await prefs.setString('hostelite_name', userData['Name']?.toString() ?? '');
      
      print("✅ Hostelite data stored in shared preferences:");
      print("   - Hostel ID: $hostelId");
      print("   - Room: ${userData['RoomNumber']}");
      print("   - Bed: ${userData['BedNumber']}");
      print("   - Scanner Image: ${userData['ScannerImg']}");
    } catch (e) {
      print("❌ Error storing hostelite data: $e");
    }
  }

  Future<void> _clearHosteliteData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all hostelite data
      await prefs.remove('hostelite_id');
      await prefs.remove('hostelite_room');
      await prefs.remove('hostelite_bed');
      await prefs.remove('hostelite_scanner_img');
      await prefs.remove('hostelite_name');
      
      print("✅ Hostelite data cleared from shared preferences");
    } catch (e) {
      print("❌ Error clearing hostelite data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary_color,
        title: Text(
          "My Scanner",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Hostel ID Input Section
              if (isError && scannerImgUrl == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Enter Your Hostel ID",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primary_color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hostelIdController,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _fetchByHostelId(value.trim());
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "e.g., HOS_AB_123",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primary_color, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final hostelId = hostelIdController.text.trim();
                            if (hostelId.isNotEmpty) {
                              _fetchByHostelId(hostelId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary_color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "View Scanner",
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
                ),
              
              const SizedBox(height: 24),
              
              // Scanner Display Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: primary_color),
                              const SizedBox(height: 16),
                              Text(
                                "Loading scanner...",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : isError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    errorMessage,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : scannerImgUrl == null || scannerImgUrl!.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_2,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No scanner image available",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Hostelite Info
                                    if (hostelId != null)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: primary_color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: primary_color,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Hostel ID: $hostelId",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: primary_color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (roomNumber != null && bedNumber != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.room,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Room $roomNumber, Bed $bedNumber",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    
                                    // QR Code Image
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          child: scannerImgUrl!.startsWith('file://')
                                              ? Image.file(
                                                  File(scannerImgUrl!.substring(7)),
                                                  width: 250,
                                                  height: 250,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      _buildErrorWidget(),
                                                )
                                              : Image.network(
                                                  scannerImgUrl!,
                                                  width: 250,
                                                  height: 250,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      _buildErrorWidget(),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          "Error loading scanner",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

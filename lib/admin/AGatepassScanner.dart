import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

class AGatepassScannerPage extends StatefulWidget {
  @override
  _AGatepassScannerPageState createState() => _AGatepassScannerPageState();
}

class _AGatepassScannerPageState extends State<AGatepassScannerPage> {
  String scannedData = "No gatepass scanned yet";
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  Map<String, dynamic>? scannedGatepass;

  void showSuccessPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.green.shade600,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void showErrorPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.red.shade600,
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  // Future<void> processGatepassQR(String gatepassId) async {
  //   if (isProcessing) return;
  //
  //   setState(() {
  //     isProcessing = true;
  //   });
  //
  //   try {
  //     // Get gatepass details from Firestore
  //     final gatepass = await GatepassService.getGatepassById(gatepassId);
  //
  //     if (gatepass == null) {
  //       showErrorPopup("Gatepass not found!");
  //       return;
  //     }
  //
  //     setState(() {
  //       scannedGatepass = gatepass;
  //     });
  //
  //     // Check if gatepass is valid
  //     final goingDate = (gatepass['goingDate'] as Timestamp).toDate();
  //     final returnDate = (gatepass['returnDate'] as Timestamp).toDate();
  //     final currentDate = DateTime.now();
  //     final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
  //     final goingDay = DateTime(goingDate.year, goingDate.month, goingDate.day);
  //     final returnDay = DateTime(returnDate.year, returnDate.month, returnDate.day);
  //
  //     if (gatepass['adminApproval'] != 'Approved') {
  //       showErrorPopup("Gatepass not approved by admin!");
  //       return;
  //     }
  //
  //     if (today.isBefore(goingDay)) {
  //       showErrorPopup("Gatepass is not yet valid. Valid from: ${goingDate.toString().substring(0, 10)}");
  //       return;
  //     }
  //
  //     if (today.isAfter(returnDay)) {
  //       showErrorPopup("Gatepass has expired. Valid until: ${returnDate.toString().substring(0, 10)}");
  //       return;
  //     }
  //
  //     showSuccessPopup("Valid gatepass! Student can proceed.");
  //
  //   } catch (e) {
  //     debugPrint("Error processing gatepass QR: $e");
  //     showErrorPopup("Error processing gatepass: ${e.toString()}");
  //   } finally {
  //     setState(() {
  //       isProcessing = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: primary_color,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "Gatepass Scanner",
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
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (capture) async {
                        if (isProcessing) return;
                        
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isEmpty) {
                          setState(() {
                            scannedData = "Failed to scan QR Code.";
                          });
                          return;
                        }

                        final String code = barcodes.first.rawValue ?? 'Failed to scan QR Code.';
                        setState(() {
                          scannedData = code;
                        });

                        // Process the gatepass QR code
                        // await processGatepassQR(code);
                      },
                    ),

                    // Scanning frame overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Processing indicator
                    if (isProcessing)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Gatepass Details Section
              if (scannedGatepass != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gatepass Details:",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primary_color,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow("Gatepass ID", scannedGatepass!['gatepassId']),
                      _buildDetailRow("Student Name", scannedGatepass!['hosteliteName']),
                      _buildDetailRow("Hostel ID", scannedGatepass!['hosteliteId']),
                      _buildDetailRow("Going Date", (scannedGatepass!['goingDate'] as Timestamp).toDate().toString().substring(0, 10)),
                      _buildDetailRow("Return Date", (scannedGatepass!['returnDate'] as Timestamp).toDate().toString().substring(0, 10)),
                      _buildDetailRow("Reason", scannedGatepass!['reason']),
                      _buildDetailRow("Status", scannedGatepass!['status']),
                      _buildDetailRow("Admin Approval", scannedGatepass!['adminApproval']),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                width: double.infinity,
                child: Text(
                  "Scanned: $scannedData",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primary_color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$title:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


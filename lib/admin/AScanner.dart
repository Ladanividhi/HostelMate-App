import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

class AScannerPage extends StatefulWidget {
  @override
  _AScannerPageState createState() => _AScannerPageState();
}

class _AScannerPageState extends State<AScannerPage> {
  String scannedData = "No code scanned yet";
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

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

    // Auto-close after 2 seconds
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

    // Auto-close after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> processQRCode(String hosteliteId) async {
    if (isProcessing) return; // Prevent multiple simultaneous processing
    
    setState(() {
      isProcessing = true;
    });

    try {
      // Step 1: Check if hostelite ID exists in the Scanner table
      final scannerQuery = await FirebaseFirestore.instance
          .collection('Scanner')
          .where('HostelID', isEqualTo: hosteliteId)
          .get();

      if (scannerQuery.docs.isEmpty) {
        // First time scanning - create new entry with exit time
        await FirebaseFirestore.instance.collection('Scanner').add({
          'HostelID': hosteliteId,
          'ExitTime': Timestamp.now(),
          'EntryTime': null,
        });
        showSuccessPopup("Exit recorded successfully!");
      } else {
        // Sort documents by ExitTime in descending order to get the latest
        final sortedDocs = scannerQuery.docs.toList()
          ..sort((a, b) {
            final aExitTime = a.data()['ExitTime'] as Timestamp?;
            final bExitTime = b.data()['ExitTime'] as Timestamp?;
            
            if (aExitTime == null && bExitTime == null) return 0;
            if (aExitTime == null) return 1;
            if (bExitTime == null) return -1;
            
            return bExitTime.compareTo(aExitTime); // Descending order
          });

        // Get the latest record
        final latestRecord = sortedDocs.first;
        final data = latestRecord.data();
        final exitTime = data['ExitTime'];
        final entryTime = data['EntryTime'];

        if (exitTime != null && entryTime != null) {
          // Both exit and entry times exist - create new record with exit time
          await FirebaseFirestore.instance.collection('Scanner').add({
            'HostelID': hosteliteId,
            'ExitTime': Timestamp.now(),
            'EntryTime': null,
          });
          showSuccessPopup("Exit recorded successfully!");
        } else if (exitTime != null && entryTime == null) {
          // Exit time exists but entry time is null - add entry time to existing document
          await FirebaseFirestore.instance
              .collection('Scanner')
              .doc(latestRecord.id)
              .update({'EntryTime': Timestamp.now()});
          showSuccessPopup("Entry recorded successfully!");
        } else {
          // This shouldn't happen, but handle it gracefully
          showErrorPopup("Invalid record state detected!");
        }
      }
    } catch (e) {
      debugPrint("Error processing QR scan: $e");
      showErrorPopup("Error processing scan: ${e.toString()}");
    } finally {
      setState(() {
        isProcessing = false;
      });
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "QR Scanner",
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
                        if (isProcessing) return; // Prevent multiple scans
                        
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

                        // Process the QR code
                        await processQRCode(code);
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

              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                width: double.infinity,
                child: Text(
                  "Result: $scannedData",
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

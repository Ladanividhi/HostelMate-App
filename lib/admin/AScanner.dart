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
                      controller: MobileScannerController(
                        torchEnabled: false,
                      ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? 'Failed to scan QR Code.';
                          setState(() {
                            scannedData = code;
                          });
                        } else {
                          setState(() {
                            scannedData = "Failed to scan QR Code.";
                          });
                        }
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
}

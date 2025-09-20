import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/Constants.dart';

class HPaymentPage extends StatefulWidget {
  @override
  State<HPaymentPage> createState() => _HPaymentPageState();
}

class _HPaymentPageState extends State<HPaymentPage> {
  List<Map<String, dynamic>> paymentSlots = [];
  String? currentHostelId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getHostelId();
    await _fetchPaymentSlots();
  }

  Future<void> _getHostelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hostelId = prefs.getString('hostelite_id');
      if (hostelId != null) {
        setState(() {
          currentHostelId = hostelId;
        });
      }
    } catch (e) {
      print("❌ Error getting hostel ID: $e");
    }
  }

  Future<void> _fetchPaymentSlots() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get all payment slots from PaymentAdmin table
      final snapshot = await FirebaseFirestore.instance
          .collection('PaymentAdmin')
          .orderBy('StartDate', descending: true)
          .get();

      List<Map<String, dynamic>> slots = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final paymentId = doc.id;
        
        // Check if this hostelite has paid for this payment slot
        bool isPaid = false;
        if (currentHostelId != null) {
          final paymentQuery = await FirebaseFirestore.instance
              .collection('Payment')
              .where('PaymentId', isEqualTo: paymentId)
              .where('HosteliteId', isEqualTo: currentHostelId)
              .limit(1)
              .get();
          
          isPaid = paymentQuery.docs.isNotEmpty;
        }

        final startDate = (data['StartDate'] as Timestamp).toDate();
        final endDate = (data['EndDate'] as Timestamp).toDate();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
        
        // Check if payment is active (today is within start and end dates)
        final isActive = (today.isAtSameMomentAs(startDateOnly) || 
                         today.isAtSameMomentAs(endDateOnly) || 
                         (today.isAfter(startDateOnly) && today.isBefore(endDateOnly)));

        slots.add({
          "id": paymentId,
          "amount": data['Amount'] ?? 0,
          "startDate": _formatDate(data['StartDate']),
          "endDate": _formatDate(data['EndDate']),
          "createdAt": _formatDate(data['CreatedAt']),
          "isPaid": isPaid,
          "isActive": isActive,
        });
      }

      setState(() {
        paymentSlots = slots;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching payment slots: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        final dateTime = date.toDate();
        return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
      }
      return "N/A";
    } catch (e) {
      return "N/A";
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
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: primary_color,
          elevation: 0,
          title: Text(
            "Payment Status",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                ),
              )
            : paymentSlots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No payment slots found",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Payment slots will appear here when created",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: paymentSlots.length,
                    itemBuilder: (context, index) {
                      final slot = paymentSlots[index];
                      return _buildPaymentSlotCard(slot);
                    },
                  ),
      ),
    );
  }

  Widget _buildPaymentSlotCard(Map<String, dynamic> slot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: bg_color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹ ${slot['amount']}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: slot['isPaid'] 
                          ? Colors.green[100] 
                          : slot['isActive'] 
                              ? Colors.red[100] 
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: slot['isPaid'] 
                            ? Colors.green[300]! 
                            : slot['isActive'] 
                                ? Colors.red[300]! 
                                : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      slot['isPaid'] 
                          ? "PAID" 
                          : slot['isActive'] 
                              ? "PENDING" 
                              : "EXPIRED",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: slot['isPaid'] 
                            ? Colors.green[800] 
                            : slot['isActive'] 
                                ? Colors.red[800] 
                                : Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Payment Details
              _buildDetailRow("Start Date", slot['startDate']),
              _buildDetailRow("End Date", slot['endDate']),
              _buildDetailRow("Created", slot['createdAt']),
              
              SizedBox(height: 12),
              
              // Payment Status Message
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: slot['isPaid'] 
                      ? Colors.green[50] 
                      : slot['isActive'] 
                          ? Colors.red[50] 
                          : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: slot['isPaid'] 
                        ? Colors.green[200]! 
                        : slot['isActive'] 
                            ? Colors.red[200]! 
                            : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      slot['isPaid'] 
                          ? Icons.check_circle 
                          : slot['isActive'] 
                              ? Icons.warning 
                              : Icons.info,
                      color: slot['isPaid'] 
                          ? Colors.green[700] 
                          : slot['isActive'] 
                              ? Colors.red[700] 
                              : Colors.grey[700],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        slot['isPaid'] 
                            ? "Payment completed successfully" 
                            : slot['isActive'] 
                                ? "Payment pending - Pay fees ASAP" 
                                : "Payment period has expired",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: slot['isPaid'] 
                              ? Colors.green[700] 
                              : slot['isActive'] 
                                  ? Colors.red[700] 
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class APaymentPage extends StatefulWidget {
  @override
  State<APaymentPage> createState() => _APaymentPageState();
}

class _APaymentPageState extends State<APaymentPage> {
  List<Map<String, dynamic>> paymentRecords = [];
  List<Map<String, dynamic>> allPayments = [];
  List<Map<String, dynamic>> pendingHostelites = [];
  List<Map<String, dynamic>> receivedPayments = [];
  bool isLoading = true;
  bool showPendingView = false;
  bool showReceivedView = false;
  String? selectedPaymentId;

  @override
  void initState() {
    super.initState();
    _fetchPaymentRecords();
  }

  Future<void> _fetchPaymentRecords() async {
    try {
      setState(() {
        isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('PaymentAdmin')
          .orderBy('StartDate', descending: true)
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      setState(() {
        paymentRecords = snapshot.docs.map((doc) {
          final data = doc.data();
          final startDate = (data['StartDate'] as Timestamp).toDate();
          final endDate = (data['EndDate'] as Timestamp).toDate();
          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
          final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
          
          // Check if today's date lies between start and end dates (inclusive)
          final isActive = (today.isAtSameMomentAs(startDateOnly) || 
                           today.isAtSameMomentAs(endDateOnly) || 
                           (today.isAfter(startDateOnly) && today.isBefore(endDateOnly)));
          
          return {
            "id": doc.id,
            "amount": data['Amount'] ?? 0,
            "startDate": _formatDate(data['StartDate']),
            "endDate": _formatDate(data['EndDate']),
            "createdAt": _formatDate(data['CreatedAt']),
            "isActive": isActive,
          };
        }).toList();

        // Show all payments instead of just active ones
        allPayments = paymentRecords;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching payment records: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Unknown";
    if (date is Timestamp) {
      return date.toDate().toString().substring(0, 10);
    }
    return date.toString().substring(0, 10);
  }

  void _showInitializePaymentDialog() {
    final TextEditingController amountController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: bg_color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Initialize Fee Payment",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: primary_color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount Field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  hintText: "Enter fee amount",
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixText: "₹ ",
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primary_color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              SizedBox(height: 16),

              // Start Date Field
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() {
                      startDate = date;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primary_color, size: 20),
                      SizedBox(width: 12),
                      Text(
                        startDate == null 
                            ? "Select Start Date" 
                            : "${startDate!.day}/${startDate!.month}/${startDate!.year}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: startDate == null ? Colors.grey.shade600 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // End Date Field
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() {
                      endDate = date;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primary_color, size: 20),
                      SizedBox(width: 12),
                      Text(
                        endDate == null 
                            ? "Select End Date" 
                            : "${endDate!.day}/${endDate!.month}/${endDate!.year}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: endDate == null ? Colors.grey.shade600 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey.shade800),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter amount")),
                  );
                  return;
                }
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select start date")),
                  );
                  return;
                }
                if (endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select end date")),
                  );
                  return;
                }
                if (endDate!.isBefore(startDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("End date must be after start date")),
                  );
                  return;
                }

                await _savePaymentRecord(
                  double.parse(amountController.text),
                  startDate!,
                  endDate!,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Initialize",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _savePaymentRecord(double amount, DateTime startDate, DateTime endDate) async {
    try {
      await FirebaseFirestore.instance.collection('PaymentAdmin').add({
        'Amount': amount,
        'StartDate': Timestamp.fromDate(startDate),
        'EndDate': Timestamp.fromDate(endDate),
        'CreatedAt': Timestamp.now(),
      });

      // Refresh the payment records
      await _fetchPaymentRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fee payment initialized successfully")),
      );
    } catch (e) {
      print("❌ Error saving payment record: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initialize payment. Please try again.")),
      );
    }
  }

  Future<void> _fetchPendingHostelites(String paymentId) async {
    try {
      setState(() {
        isLoading = true;
        selectedPaymentId = paymentId;
      });

      // Get all hostelites
      final hostelitesSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      // Get all payments for this payment ID
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('Payment')
          .where('PaymentId', isEqualTo: paymentId)
          .get();

      // Get list of hostelite IDs who have paid
      final paidHosteliteIds = paymentsSnapshot.docs
          .map((doc) => doc.data()['HosteliteId'])
          .toList();

      // Filter hostelites who haven't paid
      final pendingHostelitesList = hostelitesSnapshot.docs
          .where((doc) => !paidHosteliteIds.contains(doc.data()['HostelId']))
          .map((doc) {
            final data = doc.data();
            return {
              "hostelId": data['HostelId'],
              "name": data['Name'] ?? 'Unknown',
              "room": data['RoomNumber']?.toString() ?? 'N/A',
              "isSelected": false,
            };
          }).toList();

      setState(() {
        pendingHostelites = pendingHostelitesList;
        showPendingView = true;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching pending hostelites: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markPaymentsCompleted(List<Map<String, dynamic>> selectedHostelites) async {
    try {
      for (var hostelite in selectedHostelites) {
        await FirebaseFirestore.instance.collection('Payment').add({
          'HosteliteId': hostelite['hostelId'],
          'PaymentId': selectedPaymentId,
          'Amount': allPayments.firstWhere((p) => p['id'] == selectedPaymentId)['amount'],
          'DateOfPayment': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${selectedHostelites.length} payments marked as completed")),
      );

      // Refresh pending hostelites
      await _fetchPendingHostelites(selectedPaymentId!);
    } catch (e) {
      print("❌ Error marking payments completed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark payments. Please try again.")),
      );
    }
  }

  Future<void> _fetchReceivedPayments(String paymentId) async {
    try {
      setState(() {
        isLoading = true;
        selectedPaymentId = paymentId;
      });

      // Get all payments for this payment ID
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('Payment')
          .where('PaymentId', isEqualTo: paymentId)
          .get();

      List<Map<String, dynamic>> receivedPaymentsList = [];

      for (var doc in paymentsSnapshot.docs) {
        final paymentData = doc.data();
        final hosteliteId = paymentData['HosteliteId'];

        // Get user details
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('HostelId', isEqualTo: hosteliteId)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          receivedPaymentsList.add({
            "id": doc.id,
            "hostelId": hosteliteId,
            "name": userData['Name'] ?? 'Unknown',
            "room": userData['RoomNumber']?.toString() ?? 'N/A',
            "amount": paymentData['Amount'],
            "dateOfPayment": _formatDate(paymentData['DateOfPayment']),
          });
        }
      }

      setState(() {
        receivedPayments = receivedPaymentsList;
        showReceivedView = true;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching received payments: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPaymentReceived() {
    setState(() {
      showPendingView = false;
      showReceivedView = false;
      selectedPaymentId = null;
    });
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
          "All Payment Records",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Payment Records List or Pending Hostelites
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                      ),
                    )
                  : showPendingView
                      ? _buildPendingHostelitesView()
                      : showReceivedView
                          ? _buildReceivedPaymentsView()
                          : _buildAllPaymentsView(),
            ),


            // Sticky Initialize Button
            SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showInitializePaymentDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Initialize Fee Payment",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAllPaymentsView() {
    if (allPayments.isEmpty) {
      return Center(
        child: Text(
          "No payment records found",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Separate active and past payments
    final activePayments = allPayments.where((p) => p['isActive'] == true).toList();
    final pastPayments = allPayments.where((p) => p['isActive'] == false).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Payments Section
          if (activePayments.isNotEmpty) ...[
            Text(
              "Active Payment Records",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primary_color,
              ),
            ),
            SizedBox(height: 12),
            ...activePayments.map((record) => _buildPaymentCard(record)).toList(),
            SizedBox(height: 24),
          ],

          // Past Payments Section
          if (pastPayments.isNotEmpty) ...[
            Text(
              "Past Payment Records",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            ...pastPayments.map((record) => _buildPaymentCard(record)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> record) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                    "₹ ${record['amount']}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary_color,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: record['isActive'] == true ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: record['isActive'] == true ? Colors.green[300]! : Colors.red[300]!,
                      ),
                    ),
                    child: Text(
                      record['isActive'] == true ? "ACTIVE" : "INACTIVE",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: record['isActive'] == true ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              detailRow("Start Date", record['startDate']),
              detailRow("End Date", record['endDate']),
              detailRow("Created", record['createdAt']),
              SizedBox(height: 12),
              
              // Action Buttons - Show for both active and past payments
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchPendingHostelites(record['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        "Pending",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchReceivedPayments(record['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        "Received",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedPaymentsView() {
    return Column(
      children: [
        // Back Button
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showReceivedView = false;
                    selectedPaymentId = null;
                  });
                },
                icon: Icon(Icons.arrow_back, size: 18, color: Colors.white),
                label: Text(
                  "Back to Payments",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: receivedPayments.isEmpty
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
                        "No payments received yet",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Payments will appear here once completed",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.green[50],
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[800]),
                          SizedBox(width: 8),
                          Text(
                            "Received Payments (${receivedPayments.length})",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Received Payments List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: receivedPayments.length,
                        itemBuilder: (context, index) {
                          final payment = receivedPayments[index];
                          return Card(
                            color: bg_color,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green[800],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                payment['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hostel ID: ${payment['hostelId']} | Room: ${payment['room']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    "Paid: ${payment['dateOfPayment']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                "₹ ${payment['amount']}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primary_color,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPendingHostelitesView() {
    if (pendingHostelites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              "All payments completed!",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "No pending payments found",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.orange[50],
          child: Row(
            children: [
              Icon(Icons.pending_actions, color: Colors.orange[800]),
              SizedBox(width: 8),
              Text(
                "Pending Payments (${pendingHostelites.length})",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
        ),

        // Back Button
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showPendingView = false;
                    selectedPaymentId = null;
                  });
                },
                icon: Icon(Icons.arrow_back, size: 18, color: Colors.white),
                label: Text(
                  "Back to Payments",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),

        // Hostelites List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: pendingHostelites.length,
            itemBuilder: (context, index) {
              final hostelite = pendingHostelites[index];
              return Card(
                color: bg_color,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  value: hostelite['isSelected'],
                  onChanged: (value) {
                    setState(() {
                      pendingHostelites[index]['isSelected'] = value ?? false;
                    });
                  },
                  activeColor: primary_color,
                  title: Text(
                    hostelite['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "Hostel ID: ${hostelite['hostelId']} | Room: ${hostelite['room']}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Mark as Completed Button
        if (pendingHostelites.any((h) => h['isSelected']))
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final selectedHostelites = pendingHostelites
                    .where((h) => h['isSelected'] == true)
                    .toList();
                
                await _markPaymentsCompleted(selectedHostelites);
              },
              icon: Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                "Mark Selected as Completed (${pendingHostelites.where((h) => h['isSelected'] == true).length})",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                elevation: 3,
              ),
            ),
          ),
      ],
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:HostelMate/utils/Constants.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String? currentHostelId;
  String? currentUserName;
  String? currentRoomNumber;
  bool isAdmin = false;
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getUserData();
    await _fetchMessages();
    _setupMessageListener();
  }

  Future<void> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentHostelId = prefs.getString('hostelite_id');
      
      // Check if user is admin by looking for admin flag or checking if we're coming from admin dashboard
      // We can detect admin by checking if there's an admin flag or by checking the current route
      final isAdminUser = prefs.getBool('is_admin') ?? false;
      
      if (isAdminUser) {
        isAdmin = true;
        currentHostelId = 'admin';
        currentUserName = 'Admin';
        currentRoomNumber = '';
        print("🔍 Admin User Detected via admin flag");
      } else if (currentHostelId == null || currentHostelId!.isEmpty) {
        // Fallback: if no hostelite_id, assume admin
        isAdmin = true;
        currentHostelId = 'admin';
        currentUserName = 'Admin';
        currentRoomNumber = '';
        print("🔍 Admin User Detected via missing hostelite_id");
      } else {
        // Regular user - fetch user details from Firestore
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('HostelId', isEqualTo: currentHostelId)
            .limit(1)
            .get();
        
        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          currentUserName = userData['Name'] ?? 'Unknown';
          currentRoomNumber = userData['RoomNumber']?.toString() ?? 'N/A';
        }
        print("🔍 User Data - Hostel ID: $currentHostelId, Name: $currentUserName, Room: $currentRoomNumber");
      }
    } catch (e) {
      print("❌ Error getting user data: $e");
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Messages')
          .orderBy('DateTime', descending: false)
          .get();

      List<Map<String, dynamic>> messagesWithUserData = [];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final messageHostelId = data['HostelId'];
          
          String senderName = 'Unknown';
          String senderRoom = 'N/A';
          
          // Check if message is from admin
          if (messageHostelId == 'admin') {
            senderName = 'Admin';
            senderRoom = '';
          } else {
            // Fetch user details from Users collection for regular users
            final userSnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .where('HostelId', isEqualTo: messageHostelId)
                .limit(1)
                .get();
            
            if (userSnapshot.docs.isNotEmpty) {
              final userData = userSnapshot.docs.first.data();
              senderName = userData['Name'] ?? 'Unknown';
              senderRoom = userData['RoomNumber']?.toString() ?? 'N/A';
            }
          }
          
          messagesWithUserData.add({
            "id": doc.id,
            "message": data['Msg'] ?? '',
            "hostelId": messageHostelId ?? '',
            "dateTime": data['DateTime'],
            "isCurrentUser": messageHostelId == currentHostelId,
            "senderName": senderName,
            "senderRoom": senderRoom,
          });
        } catch (e) {
          print("❌ Error processing message doc: $e");
          messagesWithUserData.add({
            "id": doc.id,
            "message": 'Error loading message',
            "hostelId": '',
            "dateTime": Timestamp.now(),
            "isCurrentUser": false,
            "senderName": 'Unknown',
            "senderRoom": 'N/A',
          });
        }
      }

      setState(() {
        messages = messagesWithUserData;
        isLoading = false;
      });

      // Scroll to bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("❌ Error fetching messages: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setupMessageListener() {
    FirebaseFirestore.instance
        .collection('Messages')
        .orderBy('DateTime', descending: false)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> messagesWithUserData = [];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final messageHostelId = data['HostelId'];
          
          String senderName = 'Unknown';
          String senderRoom = 'N/A';
          
          // Check if message is from admin
          if (messageHostelId == 'admin') {
            senderName = 'Admin';
            senderRoom = '';
          } else {
            // Fetch user details from Users collection for regular users
            final userSnapshot = await FirebaseFirestore.instance
                .collection('Users')
                .where('HostelId', isEqualTo: messageHostelId)
                .limit(1)
                .get();
            
            if (userSnapshot.docs.isNotEmpty) {
              final userData = userSnapshot.docs.first.data();
              senderName = userData['Name'] ?? 'Unknown';
              senderRoom = userData['RoomNumber']?.toString() ?? 'N/A';
            }
          }
          
          messagesWithUserData.add({
            "id": doc.id,
            "message": data['Msg'] ?? '',
            "hostelId": messageHostelId ?? '',
            "dateTime": data['DateTime'],
            "isCurrentUser": messageHostelId == currentHostelId,
            "senderName": senderName,
            "senderRoom": senderRoom,
          });
        } catch (e) {
          print("❌ Error processing message doc in listener: $e");
          messagesWithUserData.add({
            "id": doc.id,
            "message": 'Error loading message',
            "hostelId": '',
            "dateTime": Timestamp.now(),
            "isCurrentUser": false,
            "senderName": 'Unknown',
            "senderRoom": 'N/A',
          });
        }
      }

      setState(() {
        messages = messagesWithUserData;
      });

      // Auto scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    if (currentHostelId == null || currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User data not found. Please sign in again.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Messages').add({
        'Msg': messageController.text.trim(),
        'HostelId': currentHostelId,
        'DateTime': Timestamp.now(),
      });

      messageController.clear();
    } catch (e) {
      print("❌ Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message. Please try again.")),
      );
    }
  }

  String _formatTime(Timestamp timestamp) {
    try {
      if (timestamp == null) return "Unknown";
      
      final date = timestamp.toDate();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate == today) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print("❌ Error formatting time: $e");
      return "Unknown";
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
            "Group Chat",
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
            // Messages List
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary_color),
                      ),
                    )
                  : messages.isEmpty
                      ? Center(
                          child: Text(
                            "No messages yet. Start the conversation!",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
            ),

            // Message Input
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primary_color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    try {
      final isCurrentUser = message['isCurrentUser'] ?? false;
      final messageText = message['message'] ?? '';
      final senderName = message['senderName'] ?? 'Unknown';
      final senderRoom = message['senderRoom'] ?? 'N/A';
      final time = _formatTime(message['dateTime']);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            // Sender info for others' messages
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     senderRoom.isEmpty ? senderName : "$senderName | Room $senderRoom",
                     style: GoogleFonts.poppins(
                       fontSize: 12,
                       fontWeight: FontWeight.w500,
                       color: primary_color,
                     ),
                   ),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(messageText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Current user's message
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: primary_color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary_color.withOpacity(0.3),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
         ],
       ),
     );
    } catch (e) {
      print("❌ Error building message bubble: $e");
      return Container(
        padding: EdgeInsets.all(16),
        child: Text(
          "Error loading message",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.red,
          ),
        ),
      );
    }
  }
}

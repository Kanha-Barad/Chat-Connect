import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../database/chat_db_helper.dart';
import '../../model/message_model.dart';
import '../../model/user_models.dart';
import '../../services/FCM_services.dart';
import '../../utils/Responsive_Utils.dart';
import '../../utils/colors.dart';
import '../../utils/defaultAppbar.dart';
import '../../view model/auth_view_model.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherEmail;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherEmail,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LocalDBService _dbService = LocalDBService();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToFirestoreMessages();

    _markMessagesAsRead();
  }

  Future<void> _loadMessages() async {
    final msgs = await _dbService.getMessagesBetween(
        widget.currentUserId, widget.otherUserId);
    print("Loaded ${msgs.length} messages from local DB");
    setState(() {
      _messages = msgs;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _sendMessage(UserModel user) async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final timestamp = DateTime.now().toString();

    final docRef = await FirebaseFirestore.instance.collection('messages').add({
      'senderId': widget.currentUserId,
      'receiverId': widget.otherUserId,
      'message': messageText,
      'timestamp': timestamp,
      'isRead': false,
    });

    final newMessage = ChatMessage(
      messageId: docRef.id,
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: messageText,
      timestamp: timestamp,
    );

    await _dbService.insertMessage(newMessage);
    _messageController.clear();
    _loadMessages();
    await _sendNotification(messageText, user);
  }

  void _listenToFirestoreMessages() {
    FirebaseFirestore.instance
        .collection('messages')
        .where('timestamp', isGreaterThan: '2000-01-01') // basic filter
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final sender = data['senderId'];
        final receiver = data['receiverId'];

        // Only sync messages between the current user and the other user
        final isRelevant = (sender == widget.currentUserId &&
                receiver == widget.otherUserId) ||
            (sender == widget.otherUserId && receiver == widget.currentUserId);

        if (isRelevant) {
          final msg = ChatMessage(
            messageId: doc.id,
            senderId: sender,
            receiverId: receiver,
            message: data['message'],
            timestamp: data['timestamp'],
          );
          print("Received snapshot with ${snapshot.docs.length} documents");

          final exists = await _dbService.messageExists(doc.id);
          if (!exists) {
            await _dbService.insertMessage(msg);
          }
        }
      }
      _loadMessages();
    });
  }

  Future<void> _sendNotification(
      String messageText, UserModel currentUser) async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();

      final fcmToken = receiverDoc.data()?['fcmToken'];
      if (fcmToken == null || fcmToken.isEmpty) {
        print("❌ No FCM token for receiver");
        return;
      }
      print("📨 FCM Params:");
      print("Token: $fcmToken");
      print("Title: ${currentUser.userName}");
      print("Body: $messageText");

      await FCMService().sendPushNotification(
          title: currentUser.userName,
          body: messageText,
          toUserId: widget.otherUserId,
          sender: currentUser);
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }

  Future<void> _markMessagesAsRead() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId)
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dt);
  }

  String _formatDate(String timestamp) {
    final dt = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    String? lastDate;

    final authViewModel = context.read<AuthViewModel>();

    final currentUser = authViewModel.userData;

    final responsive = ResponsiveUtils(context);

    return Scaffold(
      appBar: DefaultAppBar(
          showBackIcon: true,
          label:
              "${widget.otherUserName}"), // AppBar(title: Text("${widget.otherUserName}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == widget.currentUserId;
                final date = _formatDate(msg.timestamp);
                final showDateHeader = lastDate != date;
                lastDate = date;

                return Column(
                  children: [
                    if (showDateHeader)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: responsive.screenHeight * 0.01,
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: responsive.getBodyFontSize(),
                            fontWeight: FontWeight.bold,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: responsive.screenHeight * 0.005,
                          horizontal: responsive.screenWidth * 0.02,
                        ),
                        padding: EdgeInsets.all(
                          responsive.screenWidth * 0.03,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? senderBubbleColor : receiverBubbleColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(
                                color: textColor,
                                fontSize: responsive.getBodyFontSize(),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _formatTime(msg.timestamp),
                              style: TextStyle(
                                fontSize: responsive.getNormalRangeFontSize(),
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.screenWidth * 0.02,
              vertical: responsive.screenHeight * 0.005,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(fontSize: responsive.getBodyFontSize()),
                    decoration: InputDecoration(
                      hintText: "type_message".tr(),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.5),
                        fontSize: responsive.getBodyFontSize(),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.screenWidth * 0.04,
                        vertical: responsive.screenHeight * 0.015,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: primaryColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
                  onPressed: () => _sendMessage(currentUser!),
                  iconSize: responsive.screenWidth * 0.07,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

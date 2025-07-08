import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/Responsive_Utils.dart';
import '../../utils/colors.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _chatUsersFuture;

  @override
  void initState() {
    super.initState();
    _chatUsersFuture = _fetchChatUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchChatUsers() async {
    final messages = await FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    final usersMap = <String, Map<String, dynamic>>{};

    for (var msg in messages.docs) {
      final data = msg.data();
      final sender = data['senderId'];
      final receiver = data['receiverId'];

      String otherUserId;
      if (sender == widget.currentUserId) {
        otherUserId = receiver;
      } else if (receiver == widget.currentUserId) {
        otherUserId = sender;
      } else {
        continue;
      }

      // Only add if not already added (to keep latest message due to orderBy)
      if (!usersMap.containsKey(otherUserId)) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          usersMap[otherUserId] = {
            'uid': otherUserId,
            'userName': userData['userName'],
            'email': userData['email'],
            'lastMessage': data['message'],
            'timestamp': data['timestamp'] is Timestamp
                ? data['timestamp']
                : Timestamp.fromDate(
                    DateTime.tryParse(data['timestamp']) ?? DateTime.now()),
          };
        }
      }
    }

    return usersMap.values.toList();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final messageTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(messageTime); // e.g. 03:54 PM
    } else if (difference.inDays == 1) {
      return "yesterday".tr(); // Use localized "Yesterday"
    } else {
      return DateFormat('dd/MM/yy').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _chatUsersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatUsers = snapshot.data!;

          if (chatUsers.isEmpty) {
            return Center(
              child: Text(
                "no_chats".tr(),
                style: TextStyle(
                  fontSize: responsive.getTitleFontSize(),
                  color: textColor,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              final user = chatUsers[index];
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('receiverId', isEqualTo: widget.currentUserId)
                    .where('senderId', isEqualTo: user['uid'])
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, unreadSnap) {
                  final unreadCount = unreadSnap.data?.docs.length ?? 0;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        padding: const EdgeInsets.all(6),
                        decoration: ShapeDecoration(
                          color: senderBubbleColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.5, color: Color(0xFFE6E9EF)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Icon(Icons.person,
                            color: backgroundPageColor, size: 20),
                      ),
                      title: Text(
                        user['userName'],
                        style: TextStyle(
                          fontSize: responsive.getTitleFontSize(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        user['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: responsive.getBodyFontSize(),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTimestamp(user['timestamp'] as Timestamp),
                            style: TextStyle(
                              fontSize: responsive.getNormalRangeFontSize(),
                              color: Colors.grey,
                            ),
                          ),
                          if (unreadCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: accentColor,
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    fontSize:
                                        responsive.getNormalRangeFontSize(),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              currentUserId: widget.currentUserId,
                              otherUserId: user['uid'],
                              otherEmail: user['email'],
                              otherUserName: user['userName'],
                            ),
                          ),
                        );

                        final unread = await FirebaseFirestore.instance
                            .collection('messages')
                            .where('receiverId',
                                isEqualTo: widget.currentUserId)
                            .where('senderId', isEqualTo: user['uid'])
                            .where('isRead', isEqualTo: false)
                            .get();

                        for (var doc in unread.docs) {
                          await doc.reference.update({'isRead': true});
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

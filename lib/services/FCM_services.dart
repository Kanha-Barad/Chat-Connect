import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user_models.dart';

class FCMService {
  Future<void> sendPushNotification({
    required String toUserId,
    required UserModel sender,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse(
      'https://us-central1-chatconnect-b5073.cloudfunctions.net/sendPushNotification',
    );

    final payload = {
      "toUserId": toUserId,
      "fromUserId": sender.uid,
      "title": title,
      "body": body,
      "data": {
        "route": "/chat",
        "senderUserId": sender.uid,
        "targetUserId": toUserId,
        "key1": "value1",
        "key2": "value2"
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}

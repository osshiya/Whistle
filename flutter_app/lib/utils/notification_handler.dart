import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart';

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token, String type) {
  type = type[0].toUpperCase() + type.substring(1);
  String title;
  String body;
  if (type == "Emergency") {
    title = type;
    body = "You have a $type";
  } else if (type == "Buzz") {
    title = type;
    body = type;
  } else {
    title = type;
    body = "You have received a $type";
  }

  final notificationData = {
    'message': {
      'token': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'type': type,
        'id': "2nWd2YJjRnpiV58djvBz"
      }
    },
  };

  return jsonEncode(
    notificationData
  );
}

Future<void> sendPushMessage(String uid, String type) async {
  final jsonCredentials = await rootBundle
      .loadString('assets/gdsc-2024-7d8314390899.json');
  final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

  final client = await auth.clientViaServiceAccount(
    creds,
    ['https://www.googleapis.com/auth/cloud-platform'],
  );

  String senderId = "962935829636";

  // print(accessToken);
  // if (accessToken != null) {
    String token =
        "d7chJKo8S3eVXktEoTR5sV:APA91bElZdLzWpl8vZAVKnan1p7m1-rfjdDmZpPRw1shM25IjAz2CV7jXWpTVci-sYsM5crEXSCNxyHQJHEsXfF0xFbcZptBeNNTr7V0M9z-xCbhR-7bpExJoPbIoHlqa3E7b7Xq-AzB";
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      final response = await client.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
        headers: {
          'content-type': 'application/json',
        },
        body: constructFCMPayload(token, type),
      );

      if (response.statusCode == 200) {
        print('FCM request for device sent!');
      } else {
        print('Failed to send FCM request: ${response.statusCode}');
        print('Failed to send FCM request body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM request: $e');
    }
  // } else {
  //   print("No OAuth Token");
  // }
}

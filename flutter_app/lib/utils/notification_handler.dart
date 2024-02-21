import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_app/models/authDB.dart' as AuthDB;

/// The API endpoint here accepts a raw FCM payload.
Future<String> constructFCMPayload(
    String? token, String uid, String id, String type) async {
  type = type[0].toUpperCase() + type.substring(1);
  String title;
  String body;
  String name = await AuthDB.FirebaseHelper().getUsername(uid);

  if (type == "Emergency") {
    title = "Emergency Activated";
    body = "$name has activated an emergency alert.";
  } else if (type == "Buzz") {
    title = "Buzz Alert";
    body = "$name has triggered the alarm.";
  } else if (type == "Report"){
    title = "Report";
    body = "$name has made a report.";
  } else {
    title = "Notification";
    body = "You have received a $type notification.";
  }

  final notificationData = {
    'message': {
      'token': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {'type': type, 'id': id, 'uid': uid}
    },
  };
  return jsonEncode(notificationData);
}

Future<void> sendPushMessage(
    String uid, String id, String token, String type) async {
  final jsonCredentials =
      await rootBundle.loadString('assets/gdsc-2024-7d8314390899.json');
  final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

  final client = await auth.clientViaServiceAccount(
    creds,
    ['https://www.googleapis.com/auth/cloud-platform'],
  );

  String senderId = "962935829636";

  try {
    final response = await client.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
      headers: {
        'content-type': 'application/json',
      },
      body: await constructFCMPayload(token, uid, id, type),
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
}

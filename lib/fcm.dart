import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    // Request permissions (optional for Android, but good practice)
    await _firebaseMessaging.requestPermission();

    // Get the token
    await _fetchAndSaveTokenWithRetry();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message!');
      if (message.notification != null) {
        print('Message Notification Title: ${message.notification!.title}');
        print('Message Notification Body: ${message.notification!.body}');
        // Optionally, show a dialog or a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${message.notification!.title}: ${message.notification!.body}'),
          ),
        );
      }
    });

    // Handle messages that opened the app from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to a specific screen if needed
      // For example:
      // Navigator.pushNamed(context, '/someScreen');
    });
  }

  Future<void> _fetchAndSaveTokenWithRetry({int retries = 3}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        await _getToken();
        return;
      } catch (e) {
        print('Attempt ${attempt + 1} failed: $e');
        if (attempt < retries - 1) {
          await Future.delayed(Duration(seconds: 2));
        } else {
          print('Failed to get token after $retries attempts');
        }
      }
    }
  }

  Future<void> _getToken() async {
    // Retrieve the FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken'); // Print the FCM token for debugging

    if (fcmToken != null) {
      // Retrieve SharedPreferences values
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String colCode = prefs.getString('colCode') ?? '';
      String collegeId = prefs.getString('collegeId') ?? '';
      String admnNo = prefs.getString('admnNo') ?? '';
      String betStudMobile = prefs.getString('betStudMobile') ?? '';

      // Call saveTokenToServer with the necessary parameters
      await saveTokenToServer(
        fcmToken,
        grpCodeValue,
        colCode,
        collegeId,
        admnNo,
        betStudMobile,
      );
    } else {
      throw Exception('FCM token is not set');
    }
  }

  Future<void> saveTokenToServer(
      String token,
      String grpCodeValue,
      String colCode,
      String collegeId,
      String admnNo,
      String betStudMobile,
      ) async {
    final Map<String, dynamic> body = {
      "GrpCode": grpCodeValue,
      "CollegeId": collegeId,
      "ColCode": colCode,
      "Admnno": admnNo,
      "Token": token,
    };

    print('Request Body: ${json.encode(body)}'); // For debugging

    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FMCTokenSaving';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Token saved successfully');
      } else {
        // Handle server error
        print('Failed to save token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error saving token: $e');
    }
  }
}

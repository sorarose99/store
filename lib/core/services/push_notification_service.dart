import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Save notification to shared preferences in background
  if (message.notification != null) {
    await PushNotificationService.saveNotificationLocally(message);
  }
}

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // ignore: unused_field
  final ApiClient _apiClient;

  PushNotificationService(this._apiClient);

  Future<void> init() async {
    // Request permissions for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      await _uploadToken();
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) async {
      await _handleFCMTokenLocally(newToken);
    });

    // Background message handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
        await saveNotificationLocally(message);
      }
    });

    // Subscribe to topics
    try {
      await _messaging.subscribeToTopic('all_users');
      if (kDebugMode) {
        print('Subscribed to all_users topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to topic: $e');
      }
    }
  }

  static Future<void> saveNotificationLocally(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications =
          prefs.getStringList('local_notifications') ?? [];

      final notificationData = {
        'title': message.notification?.title ?? 'إشعار جديد',
        'body': message.notification?.body ?? '',
        'time': DateTime.now().toIso8601String(),
        'read': false,
        'data': message.data,
      };

      notifications.insert(0, jsonEncode(notificationData));
      await prefs.setStringList('local_notifications', notifications);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save notification locally: $e');
      }
    }
  }

  Future<void> _uploadToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("FCM Token: $token");
        }
        await _handleFCMTokenLocally(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
    }
  }

  Future<void> _handleFCMTokenLocally(String token) async {
    // Only upload to backend if the user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        print('FCM token not uploaded — user not logged in yet.');
      }
      return;
    }

    try {
      await _apiClient.post(ApiEndpoints.saveFcmToken, data: {
        'token': token,
        'device_id': 'flutter_app_device',
        'platform': 'android',
        'device_name': 'KDX App',
      });
      if (kDebugMode) {
        print('FCM Token uploaded to backend successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload FCM token to backend: $e');
      }
    }
  }
}

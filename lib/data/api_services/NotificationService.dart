// notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Service Account Key Data 
  static final Map<String, dynamic> _serviceAccountKey = {
    "type": "service_account",
    "project_id": "carpooling-app-5ae7c",
    "private_key_id": "c069d0b294784e1ef0bc142ab3a403c8b23869a9",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC9FgPh0PRMavsg\njAnG0GLPUTG5PO9uCZvElWnheDdLIoXWOZ3GQtWBC2VaGJy4Jnsy2rqxZ7hYxMES\nQoJom8nZNWaHTMQ82KWfHU3S/sGmPfKk4WgEz6MdZthF12JYg3tcgAoHvxSgSYIs\nNp1Xg3GGPEdbIkfWo8/S9M6DPjDDJxPWkOqguyaXIVToKYYxtDO6hSuf2MCpbPBH\npVwUIGd/YpaxY7nxv2RmhDbAhUJTXWCZ7nztP23bt1dEWKh8trh1+P6Y0dsYY8oX\noKJQXyfTMQZBXmn1FC1G5UuxhUM31JNuiad0yi7pjK89eVfFyPlLcgZHxdJ+hfbi\n6Jm9/cxbAgMBAAECggEAA9YDADKekEBQ+nKaj7IDFylJjGgi8bvyBmZAKIbaIUUD\nz9WoHNLTwhBGGQfYLMBQPue/+tk9LwHvamiViO/lrmNgsBXClO7azeE09G3VkJte\nN5nDiJThsj0rcBnDMoArNq42xeDvPrxbOXCK3tuQKDKMby9TfvXjkMOkCAj3N0iR\npJnssb2a3iyJ3cDeQVimQZV9klEvaJuGIoZEsXUJVg43PCZirHAAD8b7Ih72m1bC\nkr1G8QUll1LWyUDz+uHZXAV99BkUBeVyzs4iUK60UcsoMz4Nk8+J1oUijBrjBT/Z\nI8M65gd9vDL+CP13zJX+fpp4NP2D8CMnG77L85eV0QKBgQDtbDGM3E+xlxM/Zd21\nEW3lTgP/CRYNGHcw+d8AmZmMDUw98xyQyFNZ/lWk6xqIPE88TK2or8olaemf7AIQ\nyq8AGFB0aeJp0JFUsooHKKfp65qdNF9l//guz8vyJiMPtGK4zkMIhHV6AU8ilcVF\nQTnq6IogdndSPrD2WGzL92mZ0QKBgQDL4Zd94tuc6LvO9AJrE4em0UOy7DTY6hSu\nqqyg96yyHOhQNcDAVyjfxfB6EQ0VG0CymTWq9HYa6IpYUIkKZweKawAMQ25MXe8M\nk+SW6vMleXpv8TT472gsMDqNFkcIVXcRzSxpos042iUylVLi0MFjF7uBod2A7Qra\nqAjuHhDiawKBgAogIiDayH9PbR+4DXOKccBkymDXF1ypnXO2RF93LYg+jPDbbG10\nTbG52hc1e6UxxUNSFdnq3VkpIjCS1Se4LSx43P2KAoD2xyvwjVhu0HJ2fNqVgDgO\naZw9enoyTC6AR/GPwmYbmBMC+UgFUSt586lkD3gA9WfJiqyG6uTsAVHxAoGBAJfZ\n0idkzAU2Ioulmhd+WE6bFj0xSLs2vWjKngDV975BYZY8MvAO+taQaue/w2qw/aMI\nEbzejwjDoibc9PTWf/tMbqCzqHcgj2diz6LII4kJzXOKx9WRGpmu4i0rJoTCgwiz\nNB0JsKhjcckXBsEAksjnaDTJBl18L9VjyiLwKcs5AoGBAItFUxvUHJ/1JBEnLgW7\nrH4GPUwgbzqlG4MqK1Rkh0OY5K22rAPvcJi6MwvVLXc2QT7Op09rSBl6/dIFoR7p\n5qch8lbB/t/pv4YWSHPRsYbL6CIaRt983ToheT9aEGwwmmP9Aj/zGFXr4VBotN0E\nHUoEQMCIxzB32VY6ZqZ+ek7x\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@carpooling-app-5ae7c.iam.gserviceaccount.com",
    "client_id": "116640602057141786435",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40carpooling-app-5ae7c.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };

  // get Access Token
  static Future<String> _getAccessToken() async {
    final accountCredentials = auth.ServiceAccountCredentials.fromJson(
      _serviceAccountKey,
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(
      accountCredentials,
      scopes,
    );
    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  // ⬇️ Initialize Notifications
  static Future<void> initialize() async {
    // طلب إذن الإشعارات
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('*****-> User granted notification permission');
    } else {
      print('*****-> User declined or has not accepted notification permission');
    }

    // Local Notifications settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(initializationSettings);

    // crate notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'carpooling_channel',
      'Carpooling Notifications',
      description: 'Notifications for carpooling app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // notification foreground handler
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

    // click on notification and app in background handler
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleBackgroundNotificationTap,
    );

    // the app is closed and opened from notification 
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundNotificationTap(message);
      }
    });
  }

  //  save user token to Firestore
  static Future<void> saveUserToken(String userId) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('Users').doc(userId).update(
          {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
        );
        print('*****-> FCM Token saved: $token');
      }
    } catch (e) {
      print('******-> Error saving FCM token: $e');
    }
  }

  //  send notification to specific user and handle if no token
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? fcmToken = userData['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _sendPushNotificationV1(
            fcmToken: fcmToken,
            title: title,
            body: body,
            data: data,
          );
        } else {
          print('*****-> No FCM Token found for user: $userId');
        }
      }
    } catch (e) {
      print(' ******-> Error sending notification: $e');
    }
  }

  // send push notification using FCM v1 API
  static Future<void> _sendPushNotificationV1({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      String accessToken = await _getAccessToken();

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/carpooling-app-5ae7c/messages:send',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {'title': title, 'body': body},
            'data': data?.map((k, v) => MapEntry(k, v.toString())) ?? {},
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id': 'carpooling_channel',

                'sound': 'default',
              },
            },
            'apns': {
              'payload': {
                'aps': {
                  'alert': {'title': title, 'body': body},
                  'sound': 'default',
                  'badge': 1,
                },
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('*****-> Notification sent successfully');
      } else {
        print('******-> Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('*****-> Error sending push notification: $e');
    }
  }

  // handle foreground notification
  static void _handleForegroundNotification(RemoteMessage message) {
    print('*****> Foreground notification: ${message.notification?.title}');

    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  // handleing tap on notification when app in background or terminated
  static void _handleBackgroundNotificationTap(RemoteMessage message) {
    print('*****> Notification tapped: ${message.data}');
    // here you can navigate to specific screen based on message.data
  }

  // show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'carpooling_channel',
          'Carpooling Notifications',
          channelDescription: 'Notifications for carpooling app',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: jsonEncode(data ?? {}),
    );
  }
}

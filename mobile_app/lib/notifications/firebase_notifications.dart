import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/geo_api/services/notifications/notifications_service.dart';

import '../logger/logger.dart';

/// Service responsible for handling Firebase Cloud Messaging notifications.
class FirebaseNotificationService {
  String? _token;

  FirebaseNotificationService._privateConstructor();

  static final FirebaseNotificationService _instance = FirebaseNotificationService._privateConstructor();

  /// Singleton instance
  static FirebaseNotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> registerToken() async {
    if (token == null) {
      throw Exception("token is not initialized");
    }

    final service = NotificationService();
    await service.registerToken(token);
  }

  Future<void> deleteToken() async {
    final service = NotificationService();
    await service.deleteToken(token);
  }

  /// Initialize Firebase, request permissions, configure listeners
  Future<void> init() async {
    // Ensure Firebase is initialized

    // Request permissions for iOS
    await _requestPermission();

    // Get device token
    String? token = await _messaging.getToken();
    Logger().debug('got FCM Token: $token');
    _token = token;

    // Configure local notifications for foreground messages
    await _initializeLocalNotifications();

    // Handlers
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Background handler (must be a top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  get token => _token;

  /// Request notification permissions on iOS (Android auto grants)
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      Logger().debug('User granted permission: ${settings.authorizationStatus}');
    }
  }

  /// Init local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        // Handle tap on notification
        Logger().debug('Notification payload: $payload');
      },
    );
  }

  /// Foreground message handler
  Future<void> _onMessage(RemoteMessage message) async {
    Logger().info('Got a message whilst in the foreground!');

    if (message.notification != null) {
      Logger().info('Message also contained a notification: ${message.notification}');
    }
    await _showLocalNotification(message);
  }

  /// User tapped on notification
  void _onMessageOpenedApp(RemoteMessage message) {
    Logger().debug('Notification opened: ${message.messageId}');
    // Navigate to a specific screen, etc.
  }

  /// Display a local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }
}

/// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  Logger().debug('Handling background message: ${message.messageId}');
  // Optionally process data and show notifications
}

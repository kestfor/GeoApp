import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/geo_api/services/notifications/notifications_service.dart';
import 'package:mobile_app/geo_api/services/users/users_service.dart';
import 'package:mobile_app/repositories/event_repository/event_repository.dart';
import 'package:mobile_app/screens/events_screen/detailed_event.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:provider/provider.dart';

import '../logger/logger.dart';
import '../screens/user_screens/profile/user_screen.dart';

/// Enum representing the type of notification message.
enum MessageType {
  events("post_create"),
  friendship("friend_response"),
  empty(null);

  final String? value;

  const MessageType(this.value);
}

/// Service responsible for handling Firebase Cloud Messaging notifications.
class FirebaseNotificationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          final Map<String, dynamic> data = jsonDecode(details.payload!);
          handleNotificationTap(data);
        }
      },
    );
  }

  /// Foreground message handler
  Future<void> _onMessage(RemoteMessage message) async {
    Logger().debug('Handling foreground message: ${message.messageId}');
    await _showLocalNotification(message);
    await handleNotification(message.data);
  }

  /// User tapped on notification
  void _onMessageOpenedApp(RemoteMessage message) async {
    Logger().debug('Notification opened: ${message.messageId}');
    await handleNotificationTap(message.data);
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
      payload: jsonEncode(message.data),
    );
  }

  Future<void> handleNotification(Map<String, dynamic> data) async {
    MessageType type = MessageType.values.firstWhere((e) => e.value == data["type"], orElse: () => MessageType.empty);

    if (type == MessageType.empty) {
      Logger().error("Unknown notification type: ${data["type"]}");
      return;
    }

    Logger().debug("Handling notification of type: ${type.value}");
    switch (type) {
      case MessageType.events:
        // Handle event notifications
        await _handleEventNotification(data);
        break;
      case MessageType.friendship:
        // Handle friendship notifications
        await _handleFriendshipNotification(data);
        break;
      case MessageType.empty:
        break;
    }
  }

  Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    MessageType type = MessageType.values.firstWhere((e) => e.value == data["type"], orElse: () => MessageType.empty);

    if (type == MessageType.empty) {
      Logger().error("Unknown notification type: ${data["type"]}");
      return;
    }

    Logger().debug("Handling notification tap of type: ${type.value}");
    switch (type) {
      case MessageType.events:
        // Handle event notification tap
        await _handleEventNotificationTap(data);
        break;
      case MessageType.friendship:
        // Handle friendship notification tap
        await __handleFriendshipNotificationTap(data);
        break;
      case MessageType.empty:
        break;
    }
  }

  Future<PureEvent> _getEventFromNotification(Map<String, dynamic> data) async {
    Logger().debug("Handling event notification with data: $data");
    final apiInstance = EventsRepository();
    String? eventId = data["event_id"];
    if (eventId == null) {
      throw Exception("Event ID is missing in notification data");
    }

    final detailed = await apiInstance.getDetailedEvent(eventId);
    final pure = PureEvent.fromEvent(detailed);
    return pure;
  }

  Future<PureUser> _getUserFromNotification(Map<String, dynamic> data) async {
    Logger().debug("Handling friendship notification with data: $data");
    final apiInstance = UsersService();
    String? userId = data["from_user_id"];
    if (userId == null) {
      throw Exception("User ID is missing in notification data");
    }

    final user = await apiInstance.getUserFromId(userId);
    return user;
  }

  Future<void> _handleEventNotification(Map<String, dynamic> data) async {
    final pure = await _getEventFromNotification(data);
    Provider.of<MainUserController>(navigatorKey.currentContext!, listen: false).addEvent(pure);
    Logger().debug("added event in background");
  }

  Future<void> _handleEventNotificationTap(Map<String, dynamic> data) async {
    final pure = await _getEventFromNotification(data);
    Logger().debug("Handling event notification tap with data: $data");
    navigatorKey.currentState?.pushNamed(DetailedEvent.routeName, arguments: {"event": pure});
  }

  Future<void> __handleFriendshipNotificationTap(Map<String, dynamic> data) async {
    Logger().debug("Handling friendship notification tap with data: $data");
    String? userId = data["from_user_id"];
    if (userId == null) {
      Logger().error("User ID is missing in notification data");
      return;
    }

    navigatorKey.currentState?.pushNamed(UserScreen.routeName, arguments: {"user": userId});
  }

  Future<void> _handleFriendshipNotification(Map<String, dynamic> data) async {
    Logger().debug("Handling friendship notification with data: $data");
    String? toUserId = data["to_user_id"];
    String? fromUserId = data["from_user_id"];

    if (fromUserId == null) {
      Logger().error("From User ID is missing in notification data");
      return;
    }

    if (toUserId == null) {
      Logger().error("User ID is missing in notification data");
      return;
    }

    final MainUserController controller = Provider.of<MainUserController>(navigatorKey.currentContext!, listen: false);
    if (controller.user == null || controller.user!.id != toUserId) {
      Logger().debug("Current user is not involved in this friendship notification");
      return;
    }

    String status = data["status"] ?? "none";
    Logger().debug("Friendship status: $status");

    if (status == "friends") {
      PureUser newFriend = await _getUserFromNotification(data);
      if (!controller.friend.contains(newFriend)) {
        Provider.of<MainUserController>(navigatorKey.currentContext!, listen: false).addFriend(newFriend);
      }
      Logger().debug("Added new friend in background: ${newFriend.id}");
    }

    Logger().debug("Friendship notification handled for user: $toUserId, from: $fromUserId, status: $status");
  }
}

/// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  Logger().debug('Handling background message: ${message.messageId}');
  //await handleNotification(message.data);
  // Optionally process data and show notifications
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'alaguard_channel',
      'AlaGuard Notifications',
      description: 'Notifications from AlaGuard app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    await _showLocalNotification(
      message.notification?.title ?? 'AlaGuard',
      message.notification?.body ?? 'New notification',
      message.data,
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
    
    // Show local notification
    _showLocalNotification(
      message.notification?.title ?? 'AlaGuard',
      message.notification?.body ?? 'New notification',
      message.data,
    );
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked: ${message.messageId}');
    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle local notification tap
    if (response.payload != null) {
      // Parse payload and navigate accordingly
      _handleNotificationNavigation({'route': response.payload});
    }
  }

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    // This would typically use a navigation service or global navigator key
    // For now, we'll just print the intended navigation
    print('Navigate to: ${data['route'] ?? 'dashboard'}');
  }

  static Future<void> _showLocalNotification(
    String title, 
    String body, 
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'alaguard_channel',
      'AlaGuard Notifications',
      channelDescription: 'Notifications from AlaGuard app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data['route'],
    );
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Send notification to parent
  static Future<void> sendWarningToParent({
    required String parentId,
    required String childId,
    required String title,
    required String message,
    required String warningType,
  }) async {
    try {
      // Save notification to Firestore
      await _firestore.collection('notifications').add({
        'parentId': parentId,
        'childId': childId,
        'title': title,
        'message': message,
        'type': warningType,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'route': '/warnings',
          'childId': childId,
        },
      });

      // Save warning to warnings collection
      await _firestore.collection('warnings').add({
        'parentId': parentId,
        'childId': childId,
        'warningType': warningType,
        'message': message,
        'severity': _getSeverityLevel(warningType),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Warning notification sent successfully');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send activity notification
  static Future<void> sendActivityNotification({
    required String parentId,
    required String childId,
    required String childName,
    required String activityType,
    required String appName,
    required int duration,
  }) async {
    try {
      String title = 'Activity Alert';
      String message = '$childName used $appName for ${duration} minutes';

      await _firestore.collection('notifications').add({
        'parentId': parentId,
        'childId': childId,
        'title': title,
        'message': message,
        'type': 'activity_alert',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'data': {
          'route': '/activity-monitor',
          'childId': childId,
        },
      });

      print('Activity notification sent successfully');
    } catch (e) {
      print('Error sending activity notification: $e');
    }
  }

  // Send screen time warning
  static Future<void> sendScreenTimeWarning({
    required String parentId,
    required String childId,
    required String childName,
    required int screenTime,
    required int limit,
  }) async {
    try {
      String title = 'Screen Time Warning';
      String message = '$childName has exceeded the daily screen time limit. '
          'Used: ${screenTime} minutes, Limit: ${limit} minutes';

      await sendWarningToParent(
        parentId: parentId,
        childId: childId,
        title: title,
        message: message,
        warningType: 'excessive_screen_time',
      );

      print('Screen time warning sent successfully');
    } catch (e) {
      print('Error sending screen time warning: $e');
    }
  }

  // Send inappropriate content warning
  static Future<void> sendInappropriateContentWarning({
    required String parentId,
    required String childId,
    required String childName,
    required String content,
  }) async {
    try {
      String title = 'Inappropriate Content Alert';
      String message = '$childName may have accessed inappropriate content: $content';

      await sendWarningToParent(
        parentId: parentId,
        childId: childId,
        title: title,
        message: message,
        warningType: 'inappropriate_content',
      );

      print('Inappropriate content warning sent successfully');
    } catch (e) {
      print('Error sending inappropriate content warning: $e');
    }
  }

  static String _getSeverityLevel(String warningType) {
    switch (warningType.toLowerCase()) {
      case 'inappropriate_content':
      case 'suspicious_activity':
        return 'high';
      case 'excessive_screen_time':
      case 'new_app_installed':
        return 'medium';
      case 'location_alert':
      case 'activity_alert':
        return 'low';
      default:
        return 'low';
    }
  }

  // Update FCM token for user
  static Future<void> updateFCMToken(String userId) async {
    try {
      String? token = await getFCMToken();
      if (token != null) {
        await _firestore.collection('parents').doc(userId).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}

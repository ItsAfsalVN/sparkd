import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  NotificationService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
  }) : _messaging = messaging,
       _firestore = firestore;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');

        // Get FCM token
        final token = await _messaging.getToken();
        _logger.i('FCM Token: $token');

        return;
      } else {
        _logger.w('User declined notification permission');
      }
    } catch (e) {
      _logger.e('Error initializing notifications: $e');
    }
  }

  /// Save FCM token to user document
  Future<void> saveTokenToUser(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        _logger.i('FCM token saved for user: $userId');
      }
    } catch (e) {
      _logger.e('Error saving FCM token: $e');
    }
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        _logger.w('No FCM token found for user: $userId');
        return;
      }

      // Store notification in Firestore for in-app display
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Notification saved for user: $userId');

      // Note: Actual FCM message sending requires a backend service
      // This is typically done via Cloud Functions or your backend server
      // Example Cloud Function trigger would be:
      // exports.sendNotification = functions.firestore
      //   .document('notifications/{notificationId}')
      //   .onCreate(async (snap, context) => { /* send FCM */ });
    } catch (e) {
      _logger.e('Error sending notification: $e');
      rethrow;
    }
  }

  /// Listen to foreground messages
  void listenToForegroundMessages(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Handle notification tap when app is in background
  void handleBackgroundNotificationTap(
    void Function(RemoteMessage) onMessageOpenedApp,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  /// Get initial message if app was opened from terminated state
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }
}

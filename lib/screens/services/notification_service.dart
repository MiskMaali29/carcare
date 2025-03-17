import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
        tz.initializeTimeZones();

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(initializationSettings);

      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      _fcm.onTokenRefresh.listen(_saveFcmToken);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    }
  }

  Future<void> _saveFcmToken(String token) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // First check if document exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      } else {
        // Create new document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
              'fcmToken': token,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    }
  } catch (e) {
    print('Error saving FCM token: $e');
  }
}

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Notifications for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'Appointment Reminder',
      message.notification?.body,
      details,
    );
  }

  Future<void> sendPushNotification(
    String fcmToken,
    String title,
    String body,
  ) async {
    try {
      // Create notification document in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'fcmToken': fcmToken,
        'title': title,
        'body': body,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending',
        'type': 'push_notification'
      });

      // Show local notification
      const androidDetails = AndroidNotificationDetails(
        'appointment_updates',
        'Appointment Updates',
        channelDescription: 'Updates about your appointments',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
      );
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> scheduleAppointmentReminder(DateTime appointmentTime, String title, String body) async {
  try {
    // Schedule 24h before
    final notification24h = appointmentTime.subtract(const Duration(hours: 24));
    if (notification24h.isAfter(DateTime.now())) {
      print('Scheduling 24h notification for: ${notification24h.toString()}');
      await _scheduleLocalNotification(
        notification24h,
        '24h Reminder: $title',
        body,
      );
    } else {
      print('24h notification time has already passed: ${notification24h.toString()}');
    }

     // Schedule on the day
    final notificationSameDay = appointmentTime.subtract(const Duration(hours: 2));
    if (notificationSameDay.isAfter(DateTime.now())) {
      print('Scheduling same-day notification for: ${notificationSameDay.toString()}');
      await _scheduleLocalNotification(
        notificationSameDay,
        'Today: $title',
        body,
      );
    } else {
      print('Same-day notification time has already passed: ${notificationSameDay.toString()}');
    }
  } catch (e) {
    print('Error scheduling appointment reminder: $e');
    rethrow;
  }
}

  Future<void> _scheduleLocalNotification(DateTime scheduledDate, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Notifications for upcoming appointments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      DateTime.now().millisecond,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
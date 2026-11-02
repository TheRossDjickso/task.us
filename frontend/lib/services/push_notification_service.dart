import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/navigation.dart';
import 'notification_navigation_helper.dart';
import 'notification_service.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
/// This must be a top-level function (not a class method) and cannot be anonymous.
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  developer.log('Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  Ref? _ref;

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  /// Initializes FCM listeners, requests permission, and registers the
  /// device token with the backend.
  Future<void> initialize({
    Ref? ref,
    void Function(RemoteMessage)? onForegroundMessage,
  }) async {
    _ref = ref;
    try {
      // 1. Request notification permissions (required for iOS and Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // 2. Fetch the FCM token
        String? token = await _messaging.getToken();
        if (token != null) {
          developer.log('FCM Token: $token');
          await _registerToken(token);
        }

        // 3. Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          developer.log('FCM Token refreshed: $newToken');
          await _registerToken(newToken);
        });

        // 4. Register background handler
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        // 5. Listen to foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          developer.log('Got a message whilst in the foreground!');
          developer.log('Message data: ${message.data}');

          if (onForegroundMessage != null) {
            onForegroundMessage(message);
          }

          final notification = message.notification;
          final context = navigatorKey.currentContext;
          if (notification != null && context != null) {
            developer.log('Message also contained a notification: '
                '${notification.title}');
            
            // Show a SnackBar in the foreground
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? 'Nouvelle notification',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFDFCFC),
                      ),
                    ),
                    if (notification.body != null)
                      Text(
                        notification.body!,
                        style: const TextStyle(color: Color(0xFFFDFCFC)),
                      ),
                  ],
                ),
                backgroundColor: const Color(0xFFF87941),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Ouvrir',
                  textColor: const Color(0xFFFDFCFC),
                  onPressed: () {
                    _handleNotificationClick(message);
                  },
                ),
              ),
            );
          }
        });

        // 6. Handle notification tap when app is opened from terminated state
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          developer.log(
              'App opened from terminated state via FCM: '
              '${initialMessage.data}');
          _handleNotificationClick(initialMessage);
        }

        // 7. Handle notification tap when app is in background but running
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          developer.log(
              'App opened from background state via FCM: '
              '${message.data}');
          _handleNotificationClick(message);
        });
      }
    } catch (e) {
      developer.log('Error initializing PushNotificationService: $e');
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final type = message.data['type']?.toString() ?? '';
    NotificationNavigationHelper.handleNotificationTap(
      type: type,
      payload: message.data,
      containerRef: _ref,
    );
  }

  /// Sends the token to the backend server.
  Future<void> _registerToken(String token) async {
    try {
      await _notificationService.registerDeviceToken(token);
      developer.log('Device token registered successfully on backend.');
    } catch (e) {
      developer.log('Failed to register device token on backend: $e');
    }
  }

  /// Unregisters the current device token from the backend and deletes it.
  Future<void> cleanUp() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _notificationService.unregisterDeviceToken(token);
        developer.log('Device token unregistered successfully on backend.');
      }
      await _messaging.deleteToken();
      developer.log('FCM token deleted locally.');
    } catch (e) {
      developer.log('Error cleaning up FCM token: $e');
    }
  }
}

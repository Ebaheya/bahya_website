import 'dart:developer';
import 'dart:ui';

import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String _pushLogTag = 'PUSH_NOTIFICATION';
const String _androidChannelId = 'default_channel';
const String _androidChannelName = 'Rifq notifications';
const String _androidChannelDescription =
    'Notifications for Rifq service requests and updates.';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

bool _localNotificationsInitialized = false;

void _pushLog(String message) => log(message, name: _pushLogTag);

String _messageSummary(RemoteMessage message) {
  return 'messageId=${message.messageId}, '
      'sentTime=${message.sentTime}, '
      'from=${message.from}, '
      'collapseKey=${message.collapseKey}, '
      'notificationTitle=${message.notification?.title}, '
      'notificationBody=${message.notification?.body}, '
      'data=${message.data}';
}

bool _isSystemArabic() {
  return PlatformDispatcher.instance.locale.languageCode
      .toLowerCase()
      .startsWith('ar');
}

String _localizedTitle(String? type, RemoteMessage message) {
  final title = message.notification?.title ?? message.data['title'];
  if (title != null && title.toString().trim().isNotEmpty) {
    return title.toString();
  }

  final isArabic = _isSystemArabic();

  switch (type) {
    case 'SERVICE_REQUEST_SUBMITTED':
      return isArabic ? 'طلب خدمة جديد' : 'New service request';
    case 'SERVICE_REQUEST_APPROVED':
      return isArabic ? 'تم قبول طلب الخدمة' : 'Service request approved';
    case 'SERVICE_REQUEST_REJECTED':
      return isArabic ? 'تم رفض طلب الخدمة' : 'Service request rejected';
    case 'SERVICE_REQUEST_DECIDED':
      return isArabic ? 'تحديث طلب الخدمة' : 'Service request update';
    case 'FORM_PUBLISHED':
    case 'FORM_ASSIGNMENT_PUBLISHED':
      return isArabic ? 'استبيان جديد' : 'New questionnaire';
    default:
      return isArabic ? 'إشعار جديد' : 'New notification';
  }
}

String _localizedBody(String? type, RemoteMessage message) {
  final body = message.notification?.body ?? message.data['body'];
  if (body != null && body.toString().trim().isNotEmpty) {
    return body.toString();
  }

  final isArabic = _isSystemArabic();

  switch (type) {
    case 'SERVICE_REQUEST_SUBMITTED':
      return isArabic
          ? 'تم إرسال طلب خدمة جديد من بطلة'
          : 'A patient sent a new service request';
    case 'SERVICE_REQUEST_APPROVED':
      return isArabic
          ? 'تم قبول طلبك للانضمام إلى الخدمة'
          : 'Your service request has been approved';
    case 'SERVICE_REQUEST_REJECTED':
      return isArabic
          ? 'تم رفض طلبك للانضمام إلى الخدمة'
          : 'Your service request has been rejected';
    case 'SERVICE_REQUEST_DECIDED':
      return isArabic
          ? 'تم تحديث طلب الخدمة الخاص بك'
          : 'Your service request has been updated';
    case 'FORM_PUBLISHED':
    case 'FORM_ASSIGNMENT_PUBLISHED':
      return isArabic
          ? 'تم إرسال استبيان جديد لك'
          : 'A new questionnaire has been assigned to you';
    default:
      return isArabic
          ? 'افتح التطبيق لمتابعة التفاصيل'
          : 'Open the app to view the details';
  }
}

String _payloadFromMessage(RemoteMessage message) {
  final type = message.data['type']?.toString() ?? '';
  final notificationId = message.data['notificationId']?.toString() ?? '';
  return 'type=$type;notificationId=$notificationId';
}

Map<String, String> _payloadToMap(String payload) {
  final data = <String, String>{};

  for (final part in payload.split(';')) {
    final separatorIndex = part.indexOf('=');
    if (separatorIndex <= 0) continue;
    data[part.substring(0, separatorIndex)] = part.substring(
      separatorIndex + 1,
    );
  }

  return data;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _pushLog('BACKGROUND MESSAGE RECEIVED => ${_messageSummary(message)}');
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _lastRegisteredToken;
  bool _initialized = false;
  bool _registering = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _pushLog('initialize started');

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _requestPermission();
    await _logCurrentToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      _pushLog('FCM TOKEN REFRESHED => $token');
      _lastRegisteredToken = null;
      await registerDeviceTokenIfLoggedIn(source: 'tokenRefresh');
    });

    FirebaseMessaging.onMessage.listen((message) async {
      _pushLog('FOREGROUND MESSAGE RECEIVED => ${_messageSummary(message)}');
      await _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _pushLog('MESSAGE OPENED APP => ${_messageSummary(message)}');
      _handleNotificationTap(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pushLog(
        'INITIAL MESSAGE FROM TERMINATED => ${_messageSummary(initialMessage)}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    } else {
      _pushLog('no initial message from terminated state');
    }

    _pushLog('initialize finished');
  }

  Future<void> registerDeviceTokenIfLoggedIn({String source = 'manual'}) async {
    _pushLog(
      'registerDeviceTokenIfLoggedIn called '
      'source=$source, isLoggedIn=${authNotifier.isLoggedIn}, '
      'isRegistering=$_registering',
    );

    if (_registering) return;

    if (!authNotifier.isLoggedIn) {
      _pushLog('device token registration skipped: user is not logged in');
      return;
    }

    _registering = true;
    try {
      final token = await _messaging.getToken();
      _pushLog('current FCM token before backend registration => $token');

      if (token == null || token.isEmpty) return;
      if (token == _lastRegisteredToken) return;

      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'IOS'
          : 'ANDROID';

      await WebService().registerDeviceToken(token: token, platform: platform);

      _lastRegisteredToken = token;
      _pushLog('FCM TOKEN REGISTERED SUCCESSFULLY');
    } catch (e, stackTrace) {
      _pushLog('FCM TOKEN REGISTRATION FAILED => $e');
      _pushLog(stackTrace.toString());
    } finally {
      _registering = false;
    }
  }

  Future<void> unregisterCurrentDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await WebService().unregisterDeviceToken(token: token);
      if (_lastRegisteredToken == token) _lastRegisteredToken = null;

      _pushLog('FCM TOKEN UNREGISTERED SUCCESSFULLY');
    } catch (e, stackTrace) {
      _pushLog('FCM TOKEN UNREGISTER FAILED => $e');
      _pushLog(stackTrace.toString());
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    try {
      const initializationSettingsAndroid = AndroidInitializationSettings(
        'ic_notification_heart',
      );

      const initializationSettingsDarwin = DarwinInitializationSettings();

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          handleNotificationPayload(payload);
        },
      );

      const androidChannel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
        playSound: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(androidChannel);
      await androidPlugin?.requestNotificationsPermission();

      _localNotificationsInitialized = true;
      _pushLog('local notifications initialized successfully');
    } catch (e, stackTrace) {
      _pushLog('local notifications initialization failed => $e');
      _pushLog(stackTrace.toString());
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      if (!_localNotificationsInitialized) {
        await _initializeLocalNotifications();
      }

      if (!_localNotificationsInitialized) {
        _pushLog(
          'foreground notification skipped: local notifications not ready',
        );
        return;
      }

      final type = message.data['type']?.toString();
      final title = _localizedTitle(type, message);
      final body = _localizedBody(type, message);

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );

      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: 'ic_notification_heart',
        color: Color(0xffEA4C89),
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.status,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: _payloadFromMessage(message),
      );

      _pushLog(
        'FOREGROUND LOCAL NOTIFICATION SHOWN => id=$notificationId, '
        'title=$title, body=$body, type=$type',
      );
    } catch (e, stackTrace) {
      _pushLog('FOREGROUND LOCAL NOTIFICATION FAILED => $e');
      _pushLog(stackTrace.toString());
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _pushLog('FCM PERMISSION STATUS => ${settings.authorizationStatus}');
    } catch (e, stackTrace) {
      _pushLog('FCM PERMISSION REQUEST FAILED => $e');
      _pushLog(stackTrace.toString());
    }
  }

  Future<void> _logCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      _pushLog('FCM TOKEN => $token');
    } catch (e, stackTrace) {
      _pushLog('FCM GET TOKEN FAILED => $e');
      _pushLog(stackTrace.toString());
    }
  }

  void handleNotificationPayload(String payload) {
    _pushLog('HANDLE LOCAL NOTIFICATION PAYLOAD => $payload');
    _handleNotificationData(_payloadToMap(payload));
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    _pushLog('HANDLE NOTIFICATION TAP DATA => $data');
    _handleNotificationData(data);
  }

  void _handleNotificationData(Map<String, String> data) {
    _openRouteForType(data['type']);
  }

  void _openRouteForType(String? type) {
    final route = _routeForType(type);
    _pushLog('OPEN ROUTE FOR TYPE type=$type route=$route');

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamed(route);
  }

  String _routeForType(String? type) {
    switch (type) {
      case 'SERVICE_REQUEST_SUBMITTED':
        return '/patientRequestsDetails';
      case 'SERVICE_REQUEST_APPROVED':
      case 'SERVICE_REQUEST_REJECTED':
      case 'SERVICE_REQUEST_DECIDED':
        return '/requestedService';
      case 'FORM_PUBLISHED':
      case 'FORM_ASSIGNMENT_PUBLISHED':
        return '/formGate';
      default:
        return authNotifier.homeRoute;
    }
  }
}

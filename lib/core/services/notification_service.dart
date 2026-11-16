import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifications locales : affiche les alertes (venant du flux temps reel ou de FCM au premier plan)
/// et remonte les touchers pour ouvrir l'ecran d'alerte.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<String>.broadcast();
  var _ready = false;

  static const channelId = 'flood_alerts';

  /// Identifiant d'alerte (payload) a chaque toucher de notification.
  Stream<String> get onTap => _taps.stream;

  Future<void> init({required String channelName, required String channelDescription}) async {
    if (_ready || kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
        ),
        onDidReceiveNotificationResponse: (r) {
          if (r.payload != null) _taps.add(r.payload!);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            AndroidNotificationChannel(channelId, channelName, description: channelDescription, importance: Importance.max),
          );
      _ready = true;
    } catch (e) {
      debugPrint('[Notifications] init impossible : $e');
    }
  }

  /// Payload de la notification qui a lance l'application, s'il y en a une.
  Future<String?> launchPayload() async {
    if (!_ready) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true ? details?.notificationResponse?.payload : null;
  }

  Future<void> requestPermission() async {
    if (!_ready) return;
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> show({required String id, required String title, required String body, required String channelName, bool urgent = true}) async {
    if (!_ready) return;
    await _plugin.show(
      id: id.hashCode & 0x7fffffff,
      title: title,
      body: body,
      payload: id,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: urgent ? Importance.max : Importance.high,
          priority: urgent ? Priority.max : Priority.high,
          color: const Color(0xFFDC2626),
          styleInformation: BigTextStyleInformation(body),
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, interruptionLevel: urgent ? InterruptionLevel.timeSensitive : InterruptionLevel.active),
      ),
    );
  }

  void dispose() => _taps.close();
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final s = NotificationService();
  ref.onDispose(s.dispose);
  return s;
});

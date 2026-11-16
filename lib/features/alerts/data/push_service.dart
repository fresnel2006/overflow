import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

/// Contenu attendu d'un message FCM envoye par le backend :
///   notification: {title, body}
///   data: {alert_id: "...", commune: "Cocody", severity: "danger"}
class PushMessage {
  const PushMessage({required this.alertId, this.title, this.body});
  final String alertId;
  final String? title;
  final String? body;
}

/// Firebase Cloud Messaging : enregistre l'appareil aupres de FastAPI et abonne au sujet de la commune.
///   POST /devices {token, platform, commune}
///   Sujet FCM : `zone_<commune>` (ex : zone_cocody)
class PushService {
  PushService(this._api, {FirebaseMessaging? messaging}) : _fcm = messaging ?? FirebaseMessaging.instance;

  final ApiClient _api;
  final FirebaseMessaging _fcm;
  final _foreground = StreamController<PushMessage>.broadcast();
  final _opened = StreamController<String>.broadcast();
  final _subs = <StreamSubscription<Object?>>[];
  String? _topic;
  String? _commune;

  /// Messages recus pendant que l'application est ouverte.
  Stream<PushMessage> get onForegroundMessage => _foreground.stream;

  /// Alerte ouverte en touchant une notification systeme.
  Stream<String> get onOpened => _opened.stream;

  Future<void> start({required String commune}) async {
    try {
      await _fcm.requestPermission(alert: true, sound: true, badge: true, criticalAlert: true);
      await subscribeToCommune(commune);
      _subs
        // Le jeton FCM arrive (et se renouvelle) via onRegistered une fois register() appele.
        ..add(_fcm.onRegistered.listen((t) => _register(t, _commune ?? commune)))
        ..add(FirebaseMessaging.onMessage.listen((m) {
          final p = _parse(m);
          if (p != null) _foreground.add(p);
        }))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) {
          final id = m.data['alert_id']?.toString();
          if (id != null) _opened.add(id);
        }));
      await _fcm.register();
      final initial = await _fcm.getInitialMessage();
      final id = initial?.data['alert_id']?.toString();
      if (id != null) _opened.add(id);
    } catch (e) {
      debugPrint('[Push] demarrage impossible : $e');
    }
  }

  Future<void> subscribeToCommune(String commune) async {
    final folded = commune.toLowerCase().replaceAll(RegExp('[éèêë]'), 'e').replaceAll(RegExp('[àâ]'), 'a').replaceAll(RegExp('[ôö]'), 'o');
    final topic = 'zone_${folded.replaceAll(RegExp('[^a-z0-9]'), '')}';
    _commune = commune;
    if (topic == _topic) return;
    if (_topic != null) await _fcm.unsubscribeFromTopic(_topic!);
    await _fcm.subscribeToTopic(topic);
    _topic = topic;
  }

  Future<void> _register(String token, String commune) async {
    try {
      await _api.post<dynamic>('/devices', data: {'token': token, 'platform': Platform.operatingSystem, 'commune': commune});
    } catch (e) {
      debugPrint('[Push] enregistrement du jeton impossible : $e');
    }
  }

  PushMessage? _parse(RemoteMessage m) {
    final id = m.data['alert_id']?.toString();
    if (id == null) return null;
    return PushMessage(alertId: id, title: m.notification?.title, body: m.notification?.body);
  }

  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _foreground.close();
    await _opened.close();
  }
}

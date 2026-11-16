import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/severity.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/settings_providers.dart';
import '../data/push_service.dart';
import '../domain/flood_alert.dart';
import 'alert_providers.dart';

/// Recoit les alertes (flux temps reel, push FCM), affiche la notification et ouvre l'ecran
/// d'alerte plein ecran quand la zone suivie est en danger. Place au-dessus du routeur.
class AlertCenter extends ConsumerStatefulWidget {
  const AlertCenter({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AlertCenter> createState() => _AlertCenterState();
}

class _AlertCenterState extends ConsumerState<AlertCenter> {
  final _subs = <StreamSubscription<Object?>>[];
  final _handled = <String>{};
  PushService? _push;
  StreamSubscription<FloodAlert>? _incoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final l = AppLocalizations.of(context);
    final notifications = ref.read(notificationServiceProvider);
    await notifications.init(channelName: l.notifChannelName, channelDescription: l.notifChannelDesc);
    _subs.add(notifications.onTap.listen(_open));
    final launch = await notifications.launchPayload();
    if (launch != null) _open(launch);

    _listenIncoming();
    // L'utilisateur peut se connecter apres le demarrage : on (re)branche les sources a ce moment.
    ref.listenManual(currentUserProvider.select((u) => (u?.id, u?.commune)), (prev, next) {
      if (next.$1 != null) {
        notifications.requestPermission();
        _startPush(next.$2 ?? 'Cocody');
      }
    }, fireImmediately: true);
    ref.listenManual(alertRepositoryProvider, (_, _) => _listenIncoming());
  }

  void _listenIncoming() {
    _incoming?.cancel();
    _incoming = ref.read(alertRepositoryProvider).watchIncoming().listen(_onAlert);
  }

  Future<void> _startPush(String commune) async {
    if (!ref.read(appConfigProvider).firebaseEnabled) return;
    if (_push != null) {
      await _push!.subscribeToCommune(commune);
      return;
    }
    final push = PushService(ref.read(apiClientProvider));
    _push = push;
    final channelName = AppLocalizations.of(context).notifChannelName;
    _subs
      ..add(push.onOpened.listen(_open))
      ..add(push.onForegroundMessage.listen((m) async {
        try {
          final alert = await ref.read(alertRepositoryProvider).getAlert(m.alertId);
          _onAlert(alert);
        } catch (_) {
          // Alerte introuvable via l'API : on affiche au moins la notification recue.
          ref.read(notificationServiceProvider).show(
            id: m.alertId,
            title: m.title ?? 'Overflow',
            body: m.body ?? '',
            channelName: channelName,
          );
        }
      }));
    await push.start(commune: commune);
  }

  void _onAlert(FloodAlert alert) {
    if (!_handled.add(alert.id) || !mounted) return;
    ref.invalidate(alertsProvider);

    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final prefs = ref.read(notificationPrefsProvider);
    final mine = alert.commune == user.commune;
    if (!mine && !prefs.allCommunes) return;
    if (alert.severity == Severity.vigilance && !prefs.vigilance) return;

    final l = AppLocalizations.of(context);
    final kind = switch (alert.kind) {
      AlertKind.flood => l.alertKindFlood,
      AlertKind.warning => l.alertKindWarning,
      AlertKind.ended => l.alertKindEnded,
    };
    if (prefs.push) {
      ref.read(notificationServiceProvider).show(
        id: alert.id,
        title: '$kind - ${alert.location}',
        body: alert.message ?? alert.instructions.map((i) => i.text).join('. '),
        channelName: l.notifChannelName,
        urgent: alert.severity == Severity.danger,
      );
    }
    // Danger dans la zone suivie : ecran d'alerte rouge immediatement.
    if (mine && alert.severity == Severity.danger && alert.active) _open(alert.id);
  }

  void _open(String alertId) {
    if (ref.read(currentUserProvider) == null) return;
    ref.read(routerProvider).push(Routes.alert(alertId));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _incoming?.cancel();
    _push?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

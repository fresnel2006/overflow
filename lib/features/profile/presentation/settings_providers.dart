import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';

class NotificationPrefs {
  const NotificationPrefs({this.push = true, this.vigilance = true, this.allCommunes = false, this.sms = true});

  final bool push;
  final bool vigilance;
  final bool allCommunes;
  final bool sms;

  NotificationPrefs copyWith({bool? push, bool? vigilance, bool? allCommunes, bool? sms}) => NotificationPrefs(
    push: push ?? this.push,
    vigilance: vigilance ?? this.vigilance,
    allCommunes: allCommunes ?? this.allCommunes,
    sms: sms ?? this.sms,
  );
}

/// Preferences locales de notification (conservees sur l'appareil).
class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  static const _prefix = 'prefs.notif.';

  @override
  NotificationPrefs build() {
    final p = ref.watch(sharedPreferencesProvider);
    return NotificationPrefs(
      push: p.getBool('${_prefix}push') ?? true,
      vigilance: p.getBool('${_prefix}vigilance') ?? true,
      allCommunes: p.getBool('${_prefix}all') ?? false,
      sms: p.getBool('${_prefix}sms') ?? true,
    );
  }

  Future<void> update(NotificationPrefs next) async {
    state = next;
    final p = ref.read(sharedPreferencesProvider);
    await Future.wait([
      p.setBool('${_prefix}push', next.push),
      p.setBool('${_prefix}vigilance', next.vigilance),
      p.setBool('${_prefix}all', next.allCommunes),
      p.setBool('${_prefix}sms', next.sms),
    ]);
  }
}

final notificationPrefsProvider = NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(NotificationPrefsNotifier.new);

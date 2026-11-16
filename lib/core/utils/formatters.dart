import 'package:intl/intl.dart';

/// Formats d'affichage (francais, heure d'Abidjan = UTC).
abstract final class Fmt {
  static final _time = DateFormat('HH:mm', 'fr');
  static final _date = DateFormat('dd/MM/yyyy', 'fr');
  static final _dayShort = DateFormat('EEE', 'fr');
  static final _dayLong = DateFormat('EEEE d MMMM', 'fr');

  static DateTime _local(DateTime d) => d.toLocal();

  /// 14:20
  static String time(DateTime d) => _time.format(_local(d));

  /// 12/10/2025
  static String date(DateTime d) => _date.format(_local(d));

  /// 12/10/2025 · 14:32
  static String dateTime(DateTime d) => '${date(d)} · ${time(d)}';

  /// Sam
  static String dayShort(DateTime d) {
    final s = _dayShort.format(_local(d)).replaceAll('.', '');
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  /// samedi 12 octobre
  static String dayLong(DateTime d) => _dayLong.format(_local(d));

  /// 14h
  static String hour(DateTime d) => '${_local(d).hour}h';

  /// 158 cm
  static String cm(num v) => '${v.round()} cm';

  /// 0,55 m
  static String meters(num v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} m';

  /// +225 07 00 00 00 00
  static String phone(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('225') && digits.length == 13) {
      final local = digits.substring(3);
      final groups = [for (var i = 0; i < local.length; i += 2) local.substring(i, i + 2)];
      return '+225 ${groups.join(' ')}';
    }
    return e164;
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

/// Lecture tolerante des dates JSON (ISO 8601 ou millisecondes).
DateTime parseDate(Object? v) {
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}

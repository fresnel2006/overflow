import 'package:flutter/material.dart';

import '../domain/severity.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../theme/severity_style.dart';

/// Pastille "• Normal", "• Vigilance", "• Danger".
class SeverityBadge extends StatelessWidget {
  const SeverityBadge(this.severity, {super.key, this.label});

  final Severity severity;
  final String? label;

  @override
  Widget build(BuildContext context) => StatusPill(label: label ?? severity.label(context.l10n), color: severity.textColor, dot: severity.color, background: severity.softColor);
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, required this.background, this.dot, this.icon});

  final String label;
  final Color color;
  final Color background;
  final Color? dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot != null) ...[
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
        ],
        if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
        Text(label, style: AppText.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    ),
  );
}

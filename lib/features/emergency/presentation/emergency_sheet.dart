import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/domain/commune.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/emergency_repositories.dart';
import '../domain/emergency.dart';
import 'emergency_providers.dart';

/// Ouvre la fiche Urgence : appel direct des secours, SOS geolocalise, partage de position.
Future<void> showEmergencySheet(BuildContext context, {String? alertId}) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => EmergencySheet(alertId: alertId),
  );
}

/// Ouvre le composeur avec le numero (aucune permission d'appel requise).
Future<bool> callNumber(String number) => launchUrl(Uri(scheme: 'tel', path: number));

extension EmergencyServiceStyle on EmergencyService {
  IconData get icon => switch (this) {
    EmergencyService.firefighters => LucideIcons.flame,
    EmergencyService.medical => LucideIcons.ambulance,
    EmergencyService.police => LucideIcons.shieldAlert,
    EmergencyService.gendarmerie => LucideIcons.badgeAlert,
    EmergencyService.civilProtection => LucideIcons.lifeBuoy,
    EmergencyService.other => LucideIcons.phoneCall,
  };
}

class EmergencySheet extends ConsumerStatefulWidget {
  const EmergencySheet({super.key, this.alertId});
  final String? alertId;

  @override
  ConsumerState<EmergencySheet> createState() => _EmergencySheetState();
}

class _EmergencySheetState extends ConsumerState<EmergencySheet> {
  var _sendingSos = false;
  var _sharing = false;
  SosReceipt? _receipt;
  String? _error;

  /// Position GPS si possible, sinon centre de la commune suivie.
  Future<(GeoPoint?, bool precise)> _position() async {
    try {
      return (await ref.read(locationServiceProvider).current(), true);
    } on LocationException {
      final c = communeByName(ref.read(userCommuneProvider));
      return (c == null ? null : GeoPoint(c.lat, c.lon), false);
    }
  }

  Future<void> _sendSos() async {
    final l = context.l10n;
    setState(() {
      _sendingSos = true;
      _error = null;
    });
    try {
      final (point, _) = await _position();
      final user = ref.read(currentUserProvider);
      final receipt = await ref.read(emergencyRepositoryProvider).sendSos(
        SosRequest(commune: ref.read(userCommuneProvider), lat: point?.lat, lon: point?.lon, alertId: widget.alertId, phone: user?.phone),
      );
      if (mounted) setState(() => _receipt = receipt);
      HapticFeedback.heavyImpact();
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e is NetworkException ? l.emergencySosOffline : describeError(l, e).message);
    } finally {
      if (mounted) setState(() => _sendingSos = false);
    }
  }

  Future<void> _shareBySms() async {
    final l = context.l10n;
    setState(() => _sharing = true);
    try {
      final (point, _) = await _position();
      final commune = ref.read(userCommuneProvider);
      final where = point == null ? '' : ' https://maps.google.com/?q=${point.lat.toStringAsFixed(5)},${point.lon.toStringAsFixed(5)}';
      final body = l.emergencySmsBody(commune, where);
      final ok = await launchUrl(Uri.parse('sms:?body=${Uri.encodeComponent(body)}'));
      if (!ok && mounted) setState(() => _error = l.emergencyLaunchError);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _call(EmergencyContact c) async {
    HapticFeedback.selectionClick();
    final ok = await callNumber(c.number);
    if (!ok && mounted) setState(() => _error = context.l10n.emergencyCallError(c.number));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final contacts = ref.watch(emergencyContactsProvider).value ?? defaultEmergencyContacts;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.siren, color: AppColors.danger, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.emergencyTitle, style: AppText.h2),
                      Text(l.emergencySubtitle, style: AppText.caption.copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // SOS geolocalise vers les autorites.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _receipt == null
                  ? PrimaryButton(
                      key: const ValueKey('sos'),
                      label: l.emergencySendSos,
                      icon: LucideIcons.send,
                      color: AppColors.danger,
                      loading: _sendingSos,
                      onPressed: _sendSos,
                    )
                  : Container(
                      key: const ValueKey('sent'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.circleCheck, color: AppColors.success, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.emergencySosSent(_receipt!.id), style: AppText.title.copyWith(color: AppColors.success)),
                                const SizedBox(height: 2),
                                Text(l.emergencySosSentDetail, style: AppText.caption.copyWith(color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(l.emergencySosHint, textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 11)),

            const SizedBox(height: 18),
            Text(l.emergencyCallTitle, style: AppText.h3),
            const SizedBox(height: 10),
            for (final c in contacts) ...[_ContactRow(contact: c, onCall: () => _call(c)), const SizedBox(height: 10)],

            const SizedBox(height: 4),
            OutlinePillButton(
              label: l.emergencyShareSms,
              loading: _sharing,
              leading: const Icon(LucideIcons.messageSquareShare, size: 18, color: AppColors.primary),
              onPressed: _shareBySms,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: AppText.caption.copyWith(color: AppColors.danger, fontSize: 12.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.onCall});
  final EmergencyContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Semantics(
      button: true,
      label: l.emergencyCallSemantics(contact.name, contact.number),
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onCall,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
                  child: Icon(contact.service.icon, size: 20, color: AppColors.danger),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name, style: AppText.title.copyWith(fontSize: 13.5)),
                      if (contact.description != null) Text(contact.description!, style: AppText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(contact.number, style: AppText.h3.copyWith(color: AppColors.danger)),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.phone, size: 19, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton SOS rouge flottant, affiche quand la zone suivie est en danger.
class SosButton extends ConsumerWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(inDangerZoneProvider);
    return AnimatedScale(
      scale: show ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: FloatingActionButton.extended(
        heroTag: 'sos',
        onPressed: show ? () => showEmergencySheet(context) : null,
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(LucideIcons.siren, size: 20),
        label: Text(context.l10n.emergencySos, style: AppText.button.copyWith(color: Colors.white, letterSpacing: 1)),
      ),
    );
  }
}

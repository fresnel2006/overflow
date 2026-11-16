import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/domain/commune.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../../core/widgets/pill_chips.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/widgets/commune_picker.dart';
import '../domain/citizen_report.dart';
import 'report_providers.dart';
import 'report_style.dart';

/// Formulaire "Signaler un probleme" (maquette 9).
class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

enum _LocState { locating, auto, manual, unavailable }

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  static const _maxChars = 200;

  final _description = TextEditingController();
  final _picker = ImagePicker();
  var _type = ReportType.blockedDrain;
  XFile? _photo;
  var _loc = _LocState.locating;
  GeoPoint? _point;
  String? _commune;
  var _sending = false;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    _description.addListener(() => setState(() {}));
    _commune = ref.read(userCommuneProvider);
    _locate();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _loc = _LocState.locating);
    try {
      final p = await ref.read(locationServiceProvider).current();
      if (!mounted) return;
      setState(() {
        _point = p;
        _commune = nearestCommune(p.lat, p.lon).name;
        _loc = _LocState.auto;
      });
    } on LocationException {
      if (mounted) setState(() => _loc = _LocState.unavailable);
    }
  }

  Future<void> _pickPhoto() async {
    final l = context.l10n;
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(LucideIcons.camera), title: Text(l.reportTakePhoto), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(LucideIcons.image), title: Text(l.reportFromGallery), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
            if (_photo != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppColors.danger),
                title: Text(l.reportRemovePhoto, style: const TextStyle(color: AppColors.danger)),
                onTap: () {
                  setState(() => _photo = null);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      // Photo compressee pour les connexions lentes.
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 75);
      if (file != null && mounted) setState(() => _photo = file);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.reportErrorPhoto)));
    }
  }

  Future<void> _chooseCommune() async {
    final l = context.l10n;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.75,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Text(l.reportPickCommune, style: AppText.h3)),
            Expanded(child: CommunePicker(selected: _commune, onSelected: (c) => Navigator.pop(ctx, c.name))),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _commune = picked;
        _loc = _LocState.manual;
        final c = communeByName(picked);
        _point = c == null ? null : GeoPoint(c.lat, c.lon);
      });
    }
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final text = _description.text.trim();
    setState(() => _descriptionError = text.length < 5 ? l.reportErrorDescription : null);
    if (_descriptionError != null || _commune == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final report = await ref.read(reportRepositoryProvider).submit(
        NewReport(type: _type, description: text, commune: _commune!, lat: _point?.lat, lon: _point?.lon, photoPath: _photo?.path),
      );
      ref.invalidate(myReportsProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(LucideIcons.circleCheck, color: AppColors.success, size: 40),
          title: Text(l.reportSentTitle, textAlign: TextAlign.center),
          content: Text(l.reportSentMessage, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
              child: Text(l.reportTrack),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.pop();
      context.push(Routes.report(report.id));
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(l, e).message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: l.reportFormTitle, fallback: Routes.reports),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  _PhotoZone(photo: _photo, prompt: l.reportPhotoPrompt, onTap: _pickPhoto),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _pickPhoto,
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                      icon: const Icon(LucideIcons.camera, size: 16),
                      label: Text(_photo == null ? l.reportTakePhoto : l.reportChangePhoto, style: AppText.link),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l.reportDescription, style: AppText.title),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _description,
                    maxLines: 4,
                    minLines: 3,
                    maxLength: _maxChars,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.body,
                    decoration: InputDecoration(
                      hintText: l.reportDescriptionHint,
                      errorText: _descriptionError,
                      fillColor: AppColors.surfaceMuted,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
                      counterStyle: AppText.caption.copyWith(fontSize: 10.5),
                    ),
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                        Text('$currentLength/$maxLength', style: AppText.caption.copyWith(fontSize: 10.5)),
                  ),
                  const SizedBox(height: 14),
                  Text(l.reportLocation, style: AppText.title),
                  const SizedBox(height: 8),
                  _LocationBox(
                    commune: _commune,
                    state: _loc,
                    onModify: _chooseCommune,
                    onRetry: _locate,
                  ),
                  const SizedBox(height: 18),
                  Text(l.reportType, style: AppText.title),
                  const SizedBox(height: 10),
                  PillChips<ReportType>(
                    scrollable: false,
                    padding: EdgeInsets.zero,
                    items: [for (final t in ReportType.values) (t, t.label(l))],
                    selected: _type,
                    onSelected: (t) => setState(() => _type = t),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(label: l.reportSend, loading: _sending, onPressed: _commune == null ? null : _submit),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoZone extends StatelessWidget {
  const _PhotoZone({required this.photo, required this.prompt, required this.onTap});
  final XFile? photo;
  final String prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: prompt,
    child: GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.75,
        child: CustomPaint(
          foregroundPainter: photo == null ? const _DashedBorder() : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: photo != null
                ? Image.file(File(photo!.path), fit: BoxFit.cover)
                : ColoredBox(
                    color: AppColors.primarySoft.withValues(alpha: 0.6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(LucideIcons.camera, size: 54, color: AppColors.primary),
                              Positioned(left: -16, top: -8, child: Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(prompt, textAlign: TextAlign.center, style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.lg));
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationBox extends StatelessWidget {
  const _LocationBox({required this.commune, required this.state, required this.onModify, required this.onRetry});
  final String? commune;
  final _LocState state;
  final VoidCallback onModify;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final subtitle = switch (state) {
      _LocState.locating => l.reportLocationLocating,
      _LocState.auto => l.reportLocationAuto,
      _LocState.manual => l.reportLocationManual,
      _LocState.unavailable => l.reportLocationUnavailable,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: state == _LocState.locating
                ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(LucideIcons.mapPin, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commune == null ? '-' : '$commune, Abidjan', style: AppText.title.copyWith(fontSize: 13.5)),
                Text(subtitle, style: AppText.caption.copyWith(color: state == _LocState.unavailable ? AppColors.warningText : null)),
              ],
            ),
          ),
          if (state == _LocState.unavailable)
            IconButton(tooltip: l.commonRetry, onPressed: onRetry, icon: const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.primary)),
          TextButton(onPressed: onModify, child: Text(l.reportModify, style: AppText.link)),
        ],
      ),
    );
  }
}

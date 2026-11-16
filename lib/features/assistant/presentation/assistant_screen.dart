import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/headers.dart';
import '../../alerts/domain/flood_alert.dart';
import '../../alerts/presentation/alert_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../domain/assistant.dart';
import 'assistant_providers.dart';

/// Assistant Overflow (Gemini) : conseils de securite et explication d'une alerte.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.alertId, this.initialQuestion});

  /// Alerte a expliquer (depuis l'ecran d'alerte).
  final String? alertId;
  final String? initialQuestion;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  var _thinking = false;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = context.l10n;
      if (widget.alertId != null) {
        _send(l.assistantSuggestExplain);
      } else if (widget.initialQuestion != null) {
        _send(widget.initialQuestion!);
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Resume de la situation transmis a l'IA (zone, mesures, alertes en cours).
  Future<AssistantContext> _context() async {
    final commune = ref.read(userCommuneProvider);
    final stations = ref.read(myZoneStationsProvider).value ?? const [];
    final active = ref.read(activeAlertsProvider);
    final situation = [
      for (final s in stations) '${s.name} (${s.place}) : ${Fmt.cm(s.levelCm)}, niveau ${s.severity.name}, tendance ${s.trend.name}',
      for (final a in active) 'Alerte en cours : ${a.location}, ${a.severity.name}',
    ].join('; ');

    String? explain;
    if (widget.alertId != null) {
      try {
        final FloodAlert a = await ref.read(alertByIdProvider(widget.alertId!).future);
        explain = '${a.kind.name} (${a.severity.name}) a ${a.location}, le ${Fmt.dateTime(a.createdAt)}'
            '${a.levelCm == null ? '' : ', niveau mesure ${Fmt.cm(a.levelCm!)} (${a.trend.name})'}. ${a.message ?? ''}';
      } catch (_) {
        explain = null;
      }
    }
    return AssistantContext(commune: commune, situation: situation.isEmpty ? null : situation, alertToExplain: explain);
  }

  Future<void> _send(String text, {bool retry = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _thinking) return;
    setState(() {
      if (retry) {
        final i = _messages.lastIndexWhere((m) => m.role == ChatRole.user);
        if (i >= 0) _messages[i] = _messages[i].copyWith(failed: false);
      } else {
        _messages.add(ChatMessage(role: ChatRole.user, text: trimmed, time: DateTime.now()));
      }
      _thinking = true;
      _input.clear();
    });
    _scrollToEnd();
    try {
      final reply = await ref.read(assistantRepositoryProvider).reply(List.of(_messages), await _context());
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage(role: ChatRole.assistant, text: reply, time: DateTime.now())));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final i = _messages.lastIndexWhere((m) => m.role == ChatRole.user);
        if (i >= 0) _messages[i] = _messages[i].copyWith(failed: true);
      });
    } finally {
      if (mounted) setState(() => _thinking = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final connected = ref.watch(assistantRepositoryProvider).isConnectedToAi;
    final suggestions = [if (widget.alertId != null) l.assistantSuggestExplain, l.assistantSuggest1, l.assistantSuggest2, l.assistantSuggest3];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: l.assistantTitle,
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: connected ? l.assistantSubtitleAi : l.assistantSubtitleOffline,
                  child: Icon(connected ? LucideIcons.sparkles : LucideIcons.wifiOff, size: 20, color: connected ? AppColors.primary : AppColors.textMuted),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Align(alignment: Alignment.centerLeft, child: Text(connected ? l.assistantSubtitleAi : l.assistantSubtitleOffline, style: AppText.caption)),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _Bubble(message: ChatMessage(role: ChatRole.assistant, text: l.assistantWelcome, time: DateTime.now())),
                  for (final m in _messages)
                    _Bubble(message: m, onRetry: m.failed ? () => _send(m.text, retry: true) : null, errorText: l.assistantError),
                  if (_thinking) const _Typing(),
                  if (_messages.isEmpty && !_thinking) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in suggestions)
                          ActionChip(
                            label: Text(s, style: AppText.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.border),
                            shape: const StadiumBorder(),
                            onPressed: () => _send(s),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Text(l.assistantDisclaimer, textAlign: TextAlign.center, style: AppText.caption.copyWith(fontSize: 10.5)),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 10, 10),
              decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: l.assistantInputHint,
                        fillColor: AppColors.surfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l.assistantSend,
                    onPressed: _input.text.trim().isEmpty || _thinking ? null : () => _send(_input.text),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.border),
                    icon: const Icon(LucideIcons.send, size: 19, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onRetry, this.errorText});
  final ChatMessage message;
  final VoidCallback? onRetry;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!mine) ...[const OverflowLogo(size: 26), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: mine ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(mine ? 18 : 4),
                      bottomRight: Radius.circular(mine ? 4 : 18),
                    ),
                    boxShadow: mine ? null : AppShadows.soft,
                  ),
                  child: SelectableText(message.text, style: AppText.body.copyWith(color: mine ? Colors.white : AppColors.textPrimary, fontSize: 13.5)),
                ),
              ),
            ],
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.danger),
              label: Text(errorText ?? '', style: AppText.caption.copyWith(color: AppColors.danger)),
            ),
        ],
      ),
    );
  }
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const OverflowLogo(size: 26),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), boxShadow: AppShadows.soft),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3 + 0.7 * (((_c.value * 3 - i) % 3) < 1 ? 1 : 0)),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

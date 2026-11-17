import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Lecture vocale (synthese vocale du telephone) des consignes de securite en cas d'inondation.
/// L'etat vaut true pendant la lecture.
class VoiceGuide extends Notifier<bool> {
  FlutterTts? _tts;

  @override
  bool build() {
    ref.onDispose(() => _tts?.stop());
    return false;
  }

  Future<FlutterTts> _engine() async {
    final existing = _tts;
    if (existing != null) return existing;
    final tts = FlutterTts();
    await tts.setLanguage('fr-FR');
    await tts.setSpeechRate(0.45); // un peu lent : consignes comprises du premier coup
    await tts.setVolume(1);
    await tts.awaitSpeakCompletion(false);
    tts.setCompletionHandler(() => state = false);
    tts.setCancelHandler(() => state = false);
    tts.setErrorHandler((_) => state = false);
    return _tts = tts;
  }

  /// Lit [text] ; renvoie false si la synthese vocale est indisponible.
  Future<bool> speak(String text) async {
    try {
      final tts = await _engine();
      await tts.stop();
      final ok = await tts.speak(text);
      state = ok == 1;
      return state;
    } catch (_) {
      state = false;
      return false;
    }
  }

  Future<void> stop() async {
    state = false;
    await _tts?.stop();
  }
}

final voiceGuideProvider = NotifierProvider<VoiceGuide, bool>(VoiceGuide.new);

/// Bouton "Ecouter les consignes" / "Arreter la lecture".
class VoiceGuideButton extends ConsumerWidget {
  const VoiceGuideButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final speaking = ref.watch(voiceGuideProvider);
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () async {
          final voice = ref.read(voiceGuideProvider.notifier);
          if (speaking) return voice.stop();
          final ok = await voice.speak(l.voiceGuidance);
          if (!ok && context.mounted) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.voiceUnavailable)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(speaking ? LucideIcons.squareStop : LucideIcons.volume2, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(speaking ? l.voiceStop : l.voiceListen, style: AppText.title.copyWith(color: AppColors.primary, fontSize: 14)),
              ),
              if (speaking) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

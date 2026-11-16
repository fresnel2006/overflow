import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/headers.dart';
import '../../auth/presentation/auth_providers.dart';
import 'abidjan_skyline.dart';

/// Ecran d'accueil (maquette 1) : logo, slogan, photo d'Abidjan et bouton "Commencer".
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final restoring = ref.watch(authStateProvider).isLoading;
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.brand,
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3599E5), Color(0xFF5AA7DC)]),
                ),
              ),
            ),
            // Photo d'Abidjan (assets/images/splash_abidjan.jpg si present, sinon illustration vectorielle).
            Positioned(left: 0, right: 0, bottom: 70, height: size.height * 0.46, child: const AbidjanSkyline()),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: compact ? 28 : size.height * 0.1),
                  Container(
                    width: compact ? 104 : 124,
                    height: compact ? 104 : 124,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const OverflowLogo(size: 90),
                  ),
                  const SizedBox(height: 18),
                  Text(l.appName, style: AppText.display.copyWith(color: Colors.white, fontSize: compact ? 32 : 38, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(l.appTagline, style: AppText.body.copyWith(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      l.splashHeadline,
                      textAlign: TextAlign.center,
                      style: AppText.h3.copyWith(color: Colors.white, fontSize: compact ? 16 : 18, fontWeight: FontWeight.w700, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 22, 24, 22 + MediaQuery.paddingOf(context).bottom),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
                child: PrimaryButton(
                  label: l.splashStart,
                  color: AppColors.brand,
                  loading: restoring,
                  onPressed: () => context.push(Routes.login),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

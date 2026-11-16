import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/alert_detail_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/alerts/presentation/article_screen.dart';
import '../../features/assistant/presentation/assistant_screen.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/zone_setup_screen.dart';
import '../../features/digital_twin/presentation/digital_twin_screen.dart';
import '../../features/home/presentation/app_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/profile/presentation/help_screen.dart';
import '../../features/profile/presentation/personal_info_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/terms_screen.dart';
import '../../features/profile/presentation/zone_screen.dart';
import '../../features/reports/presentation/new_report_screen.dart';
import '../../features/reports/presentation/report_detail_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/water_levels/presentation/station_detail_screen.dart';
import '../../features/water_levels/presentation/stations_screen.dart';
import '../../features/weather/presentation/weather_screen.dart';

/// Chemins de l'application.
///
/// Carte de navigation :
///   /welcome -> /login <-> /register -> /otp -> (/zone-setup si nouveau compte) -> /home
///   Onglets (barre du bas) : /home, /map, /alerts, /reports, /profile
///   /home -> /home/weather, /home/stations, /station/:id, /alert/:id, /assistant, /twin, /report/new
///   /home/stations -> /station/:id -> /twin?station=..., /map?station=...
///   /map -> fiche de zone -> /station/:id, /twin?site=...
///   /alerts -> /alert/:id -> /map?zone=..., /assistant?alert=..., /station/:id ; Conseils -> /awareness/:id
///   /reports -> /report/new, /report/:id
///   /profile -> /profile/info, /profile/zone, /profile/settings, /profile/help, /terms
///   Notification ou alerte en direct -> /alert/:id (plein ecran)
abstract final class Routes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const zoneSetup = '/zone-setup';
  static const terms = '/terms';

  static const home = '/home';
  static const weather = '/home/weather';
  static const stations = '/home/stations';
  static const map = '/map';
  static const alerts = '/alerts';
  static const reports = '/reports';
  static const profile = '/profile';
  static const personalInfo = '/profile/info';
  static const zone = '/profile/zone';
  static const settings = '/profile/settings';
  static const help = '/profile/help';

  static const newReport = '/report/new';
  static const assistantPath = '/assistant';
  static const twinPath = '/twin';

  static String station(String id) => '/station/$id';
  static String alert(String id) => '/alert/$id';
  static String article(String id) => '/awareness/$id';
  static String report(String id) => '/report/$id';
  static String mapFocus({String? zone, String? station}) =>
      Uri(path: map, queryParameters: {'zone': ?zone, 'station': ?station}).toString();
  static String alertsFilter(String filter) => '$alerts?filter=$filter';
  static String assistant({String? alertId, String? question}) =>
      Uri(path: assistantPath, queryParameters: {'alert': ?alertId, 'q': ?question}).toString();
  static String twin({String? site, String? station}) =>
      Uri(path: twinPath, queryParameters: {'site': ?site, 'station': ?station}).toString();
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

const _publicRoutes = {Routes.welcome, Routes.login, Routes.register, Routes.otp, Routes.terms};

String? authRedirect(AsyncValue<AppUser?> auth, String path) {
  // Session pas encore restauree : on reste sur l'ecran d'accueil.
  if (auth.isLoading && !auth.hasValue) return path == Routes.welcome ? null : Routes.welcome;
  final user = auth.value;
  final public = _publicRoutes.contains(path);
  if (user == null) return public ? null : Routes.welcome;
  if (path == Routes.terms) return null;
  if (user.needsZone) return path == Routes.zoneSetup ? null : Routes.zoneSetup;
  if (public || path == Routes.zoneSetup) return Routes.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  Page<void> fade(GoRouterState s, Widget child) => CustomTransitionPage(
    key: s.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: c),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(ref.read(authStateProvider), state.matchedLocation),
    routes: [
      GoRoute(path: Routes.welcome, pageBuilder: (_, s) => fade(s, const WelcomeScreen())),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (_, s) {
          final v = s.extra;
          return v is PhoneVerification ? OtpScreen(verification: v) : const LoginScreen();
        },
      ),
      GoRoute(path: Routes.zoneSetup, pageBuilder: (_, s) => fade(s, const ZoneSetupScreen())),
      GoRoute(path: Routes.terms, builder: (_, _) => const TermsScreen()),

      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const HomeScreen(),
                routes: [
                  GoRoute(path: 'weather', builder: (_, _) => const WeatherScreen()),
                  GoRoute(path: 'stations', builder: (_, _) => const StationsScreen()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.map,
                builder: (_, s) => MapScreen(focusZoneId: s.uri.queryParameters['zone'], focusStationId: s.uri.queryParameters['station']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.alerts, builder: (_, s) => AlertsScreen(initialFilter: AlertsFilter.fromName(s.uri.queryParameters['filter']))),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.reports, builder: (_, _) => const ReportsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(path: 'info', builder: (_, _) => const PersonalInfoScreen()),
                  GoRoute(path: 'zone', builder: (_, _) => const ZoneScreen()),
                  GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
                  GoRoute(path: 'help', builder: (_, _) => const HelpScreen()),
                ],
              ),
            ],
          ),
        ],
      ),

      // Ecrans plein ecran, au-dessus de la barre d'onglets.
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/alert/:id', builder: (_, s) => AlertDetailScreen(alertId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/station/:id', builder: (_, s) => StationDetailScreen(stationId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/awareness/:id', builder: (_, s) => ArticleScreen(articleId: s.pathParameters['id']!)),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: Routes.newReport, builder: (_, _) => const NewReportScreen()),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: '/report/:id', builder: (_, s) => ReportDetailScreen(reportId: s.pathParameters['id']!)),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: Routes.assistantPath,
        builder: (_, s) => AssistantScreen(alertId: s.uri.queryParameters['alert'], initialQuestion: s.uri.queryParameters['q']),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: Routes.twinPath,
        builder: (_, s) => DigitalTwinScreen(siteId: s.uri.queryParameters['site'], stationId: s.uri.queryParameters['station']),
      ),
    ],
  );
});

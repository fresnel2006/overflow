import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/severity.dart';
import '../../../core/network/api_client.dart';
import '../../alerts/presentation/alert_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../water_levels/presentation/station_providers.dart';
import '../data/emergency_repositories.dart';
import '../domain/emergency.dart';

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  if (ref.watch(appConfigProvider).useMocks) return MockEmergencyRepository();
  return ApiEmergencyRepository(ref.watch(apiClientProvider));
});

final emergencyContactsProvider = FutureProvider<List<EmergencyContact>>((ref) async {
  try {
    return await ref.watch(emergencyRepositoryProvider).fetchContacts(commune: ref.watch(userCommuneProvider));
  } catch (_) {
    return defaultEmergencyContacts;
  }
});

/// true quand la zone suivie est en danger (alerte en cours ou capteur au seuil de danger) :
/// le bouton SOS apparait alors sur tous les onglets.
final inDangerZoneProvider = Provider<bool>((ref) {
  final alert = ref.watch(myZoneActiveAlertProvider);
  if (alert != null && alert.severity == Severity.danger) return true;
  return ref.watch(myZoneSeverityProvider) == Severity.danger;
});

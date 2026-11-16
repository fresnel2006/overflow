import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _online(List<ConnectivityResult> r) => r.any((c) => c != ConnectivityResult.none);

/// true si l'appareil a un reseau (Wi-Fi, mobile, ethernet...). Optimiste tant que l'etat est inconnu.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  try {
    yield _online(await connectivity.checkConnectivity());
  } catch (_) {
    yield true;
  }
  yield* connectivity.onConnectivityChanged.map(_online).distinct();
});

extension OnlineX on WidgetRef {
  bool get isOffline => watch(isOnlineProvider).value == false;
}

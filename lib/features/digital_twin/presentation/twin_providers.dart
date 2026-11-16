import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/twin_repositories.dart';
import '../domain/models.dart';
import '../domain/twin_repository.dart';

final twinRepositoryProvider = Provider<TwinRepository>((ref) {
  if (ref.watch(appConfigProvider).useMocks) return const AssetTwinRepository();
  return ApiTwinRepository(ref.watch(apiClientProvider));
});

final twinSitesProvider = FutureProvider<List<FloodDataset>>((ref) => ref.watch(twinRepositoryProvider).loadSites());

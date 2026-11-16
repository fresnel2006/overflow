import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/report_repositories.dart';
import '../domain/citizen_report.dart';
import '../domain/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final c = ref.watch(appConfigProvider);
  if (c.useMocks) return MockReportRepository();
  return ApiReportRepository(
    ref.watch(apiClientProvider),
    storage: c.firebaseEnabled ? FirebaseStorage.instance : null,
    userId: ref.watch(currentUserProvider)?.id,
  );
});

final myReportsProvider = FutureProvider<List<CitizenReport>>((ref) => ref.watch(reportRepositoryProvider).fetchMyReports());

final reportByIdProvider = FutureProvider.autoDispose.family<CitizenReport, String>((ref, id) async {
  final cached = ref.read(myReportsProvider).value?.where((r) => r.id == id).firstOrNull;
  return cached ?? ref.watch(reportRepositoryProvider).getReport(id);
});

import 'citizen_report.dart';

abstract interface class ReportRepository {
  /// Signalements de l'utilisateur connecte, du plus recent au plus ancien.
  Future<List<CitizenReport>> fetchMyReports();

  Future<CitizenReport> getReport(String id);

  Future<CitizenReport> submit(NewReport report);
}

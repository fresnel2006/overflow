import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/mock/mock_latency.dart';
import '../../../core/network/api_client.dart';
import '../domain/citizen_report.dart';
import '../domain/report_repository.dart';

/// Signalements fictifs gardes en memoire pendant la session.
class MockReportRepository implements ReportRepository {
  MockReportRepository() {
    final now = DateTime.now();
    _reports = [
      CitizenReport(
        id: 'sg-1042',
        type: ReportType.blockedDrain,
        description: 'Caniveau bouché par des déchets devant le marché, l\'eau stagne depuis hier.',
        commune: 'Cocody',
        lat: 5.3541,
        lon: -4.0102,
        status: ReportStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        history: [
          ReportStatusEvent(ReportStatus.sent, now.subtract(const Duration(days: 1, hours: 3))),
          ReportStatusEvent(ReportStatus.inReview, now.subtract(const Duration(days: 1, hours: 1)), 'Pris en charge par la mairie de Cocody.'),
          ReportStatusEvent(ReportStatus.inProgress, now.subtract(const Duration(hours: 6)), 'Équipe de curage programmée.'),
        ],
      ),
      CitizenReport(
        id: 'sg-0987',
        type: ReportType.floodedRoad,
        description: 'Route inondée au carrefour, les voitures ne passent plus.',
        commune: 'Cocody',
        lat: 5.3712,
        lon: -3.9562,
        status: ReportStatus.resolved,
        createdAt: now.subtract(const Duration(days: 9)),
        history: [
          ReportStatusEvent(ReportStatus.sent, now.subtract(const Duration(days: 9))),
          ReportStatusEvent(ReportStatus.inReview, now.subtract(const Duration(days: 9, hours: -2))),
          ReportStatusEvent(ReportStatus.resolved, now.subtract(const Duration(days: 7)), 'Eau évacuée, caniveau dégagé.'),
        ],
      ),
    ];
  }

  late List<CitizenReport> _reports;

  @override
  Future<List<CitizenReport>> fetchMyReports() async {
    await mockDelay();
    return List.unmodifiable(_reports);
  }

  @override
  Future<CitizenReport> getReport(String id) async {
    await mockDelay(150, 400);
    return _reports.firstWhere((r) => r.id == id, orElse: () => throw NotFoundException('signalement $id'));
  }

  @override
  Future<CitizenReport> submit(NewReport report) async {
    await mockDelay(900, 1600);
    final now = DateTime.now();
    final created = CitizenReport(
      id: 'sg-${1043 + _reports.length}',
      type: report.type,
      description: report.description,
      commune: report.commune,
      lat: report.lat,
      lon: report.lon,
      localPhotoPath: report.photoPath,
      status: ReportStatus.sent,
      createdAt: now,
      history: [ReportStatusEvent(ReportStatus.sent, now)],
    );
    _reports = [created, ..._reports];
    return created;
  }
}

/// FastAPI :
///   GET  /reports/me     -> [CitizenReport]
///   GET  /reports/{id}   -> CitizenReport
///   POST /reports        -> CitizenReport
/// La photo est envoyee dans Firebase Storage si Firebase est configure (le champ photo_url est
/// alors transmis en JSON), sinon en multipart/form-data au champ "photo".
class ApiReportRepository implements ReportRepository {
  ApiReportRepository(this._api, {this.storage, this.userId});

  final ApiClient _api;
  final FirebaseStorage? storage;
  final String? userId;

  @override
  Future<List<CitizenReport>> fetchMyReports() async {
    final data = await _api.get<List<dynamic>>('/reports/me');
    return [for (final j in data) CitizenReport.fromJson(j as Map<String, dynamic>)]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<CitizenReport> getReport(String id) async => CitizenReport.fromJson(await _api.get<Map<String, dynamic>>('/reports/$id'));

  @override
  Future<CitizenReport> submit(NewReport report) async {
    final path = report.photoPath;
    if (path == null) return _post(report.toJson());

    if (storage != null) {
      final url = await _uploadToStorage(path);
      return _post(report.toJson(photoUrl: url));
    }
    final form = FormData.fromMap({
      ...report.toJson()..removeWhere((_, v) => v == null),
      'photo': await MultipartFile.fromFile(path, filename: path.split(Platform.pathSeparator).last),
    });
    return _post(form);
  }

  Future<CitizenReport> _post(Object body) async => CitizenReport.fromJson(await _api.post<Map<String, dynamic>>('/reports', data: body));

  Future<String> _uploadToStorage(String path) async {
    try {
      final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage!.ref('reports/${userId ?? 'anonymous'}/$name');
      await ref.putFile(File(path), SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw NetworkException(e.message);
    }
  }
}

import 'dart:async';

import 'fir_model.dart';

// TODO(Phase 9): replace with SupabaseFirRepository
class FirRepository {
  FirRepository();

  final List<FirModel> _seedFirs = [
    FirModel(
      id: 'fir-001',
      deviceId: 'dev-001',
      deviceInfo: 'Apple iPhone 15 Pro · IMEI 356938 09 123456 7',
      policeStation: 'Clifton P.S.',
      incidentDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Phone snatched near Sea View.',
      caseStatus: CaseStatus.firUnderReview,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FirModel(
      id: 'fir-002',
      deviceId: 'dev-003',
      deviceInfo: 'Xiaomi Redmi Note 13 · IMEI 869912 04 789012 3',
      policeStation: 'Gulberg P.S.',
      incidentDate: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Lost in market.',
      caseStatus: CaseStatus.firRejected,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      rejectReason: 'Insufficient proof of purchase attached.',
    ),
    FirModel(
      id: 'fir-003',
      deviceId: 'dev-004',
      deviceInfo: 'Samsung Galaxy S24 · IMEI 359123 10 987654 1',
      policeStation: 'DHA Phase 6 P.S.',
      incidentDate: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Stolen from car at red light.',
      caseStatus: CaseStatus.firUnderReview,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    FirModel(
      id: 'fir-004',
      deviceId: 'dev-005',
      deviceInfo: 'Google Pixel 8 · IMEI 990000 86 123456 7',
      policeStation: 'Saddar P.S.',
      incidentDate: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Pickpocketed in busy street.',
      caseStatus: CaseStatus.firUnderReview,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    FirModel(
      id: 'fir-005',
      deviceId: 'dev-006',
      deviceInfo: 'OnePlus 12 · IMEI 861234 05 987654 3',
      policeStation: 'Malir P.S.',
      incidentDate: DateTime.now().subtract(const Duration(days: 15)),
      description: 'Snatched by armed men on bike.',
      caseStatus: CaseStatus.firVerified,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  Future<List<FirModel>> fetchUserFirs() async {
    await _delay();
    return List.unmodifiable(_seedFirs);
  }

  Future<FirModel> fetchFirById(String id) async {
    await _delay();
    return _seedFirs.firstWhere((f) => f.id == id);
  }

  Future<FirModel> submitFir({
    required String deviceId,
    required String deviceInfo,
    required String policeStation,
    required DateTime incidentDate,
    required String description,
  }) async {
    await _delay();
    final newFir = FirModel(
      id: 'fir-${DateTime.now().millisecondsSinceEpoch}',
      deviceId: deviceId,
      deviceInfo: deviceInfo,
      policeStation: policeStation,
      incidentDate: incidentDate,
      description: description,
      caseStatus: CaseStatus.firSubmitted,
      createdAt: DateTime.now(),
    );
    _seedFirs.insert(0, newFir);
    return newFir;
  }

  Future<void> updateFirStatus(
    String id,
    CaseStatus status, [
    String? rejectReason,
  ]) async {
    await _delay();
    final index = _seedFirs.indexWhere((f) => f.id == id);
    if (index >= 0) {
      _seedFirs[index] = _seedFirs[index].copyWith(
        caseStatus: status,
        rejectReason: rejectReason,
      );
    }
  }
}

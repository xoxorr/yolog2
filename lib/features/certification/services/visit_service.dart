import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../models/visit_model.dart';

class VisitService {
  final FirebaseFirestore _firestore;
  final String userId;

  VisitService({
    FirebaseFirestore? firestore,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _visitsRef =>
      _firestore.collection('users').doc(userId).collection('visits');

  // 방문 기록 생성
  Future<Visit> createVisit({
    required String placeId,
    required String placeName,
    required LatLng location,
    required List<String> photos,
    String? note,
    required String verificationType,
    Map<String, dynamic>? verificationData,
  }) async {
    final visitData = Visit(
      id: '',
      userId: userId,
      placeId: placeId,
      placeName: placeName,
      location: location,
      visitedAt: DateTime.now(),
      photos: photos,
      note: note,
      isVerified: false,
      verificationType: verificationType,
      verificationData: verificationData,
    );

    final docRef = await _visitsRef.add(visitData.toFirestore());
    return visitData.copyWith(id: docRef.id);
  }

  // 방문 기록 가져오기
  Future<List<Visit>> getVisits({
    DateTime? startDate,
    DateTime? endDate,
    String? placeId,
    int? limit,
  }) async {
    Query query = _visitsRef.orderBy('visitedAt', descending: true);

    if (startDate != null) {
      query = query.where('visitedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('visitedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    if (placeId != null) {
      query = query.where('placeId', isEqualTo: placeId);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();
  }

  // 방문 기록 업데이트
  Future<void> updateVisit(
    String visitId, {
    List<String>? photos,
    String? note,
    bool? isVerified,
    Map<String, dynamic>? verificationData,
  }) async {
    final updates = <String, dynamic>{};
    if (photos != null) updates['photos'] = photos;
    if (note != null) updates['note'] = note;
    if (isVerified != null) updates['isVerified'] = isVerified;
    if (verificationData != null)
      updates['verificationData'] = verificationData;

    await _visitsRef.doc(visitId).update(updates);
  }

  // 방문 기록 삭제
  Future<void> deleteVisit(String visitId) async {
    await _visitsRef.doc(visitId).delete();
  }

  // 방문 인증
  Future<void> verifyVisit(
    String visitId, {
    required bool isVerified,
    required String verificationType,
    Map<String, dynamic>? verificationData,
  }) async {
    await _visitsRef.doc(visitId).update({
      'isVerified': isVerified,
      'verificationType': verificationType,
      'verificationData': verificationData,
    });

    if (isVerified) {
      // 사용자 통계 업데이트
      await _firestore.collection('users').doc(userId).update({
        'totalVisits': FieldValue.increment(1),
        'points': FieldValue.increment(10), // 방문당 10포인트
      });
    }
  }

  // 방문 통계 가져오기
  Future<Map<String, dynamic>> getVisitStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _visitsRef.where('isVerified', isEqualTo: true);

    if (startDate != null) {
      query = query.where('visitedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('visitedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    final visits =
        snapshot.docs.map((doc) => Visit.fromFirestore(doc)).toList();

    final placeVisits = <String, int>{};
    final verificationTypes = <String, int>{};

    for (var visit in visits) {
      placeVisits[visit.placeId] = (placeVisits[visit.placeId] ?? 0) + 1;
      verificationTypes[visit.verificationType] =
          (verificationTypes[visit.verificationType] ?? 0) + 1;
    }

    return {
      'totalVisits': visits.length,
      'uniquePlaces': placeVisits.length,
      'placeVisits': placeVisits,
      'verificationTypes': verificationTypes,
    };
  }

  // 최근 방문한 장소 근처의 방문 기록 가져오기
  Future<List<Visit>> getNearbyVisits(LatLng location,
      {double radiusInKm = 1.0}) async {
    final center = GeoPoint(location.latitude, location.longitude);
    final bounds = _getBoundsFromRadius(location, radiusInKm);

    final snapshot = await _visitsRef
        .where('location', isGreaterThan: GeoPoint(bounds.south, bounds.west))
        .where('location', isLessThan: GeoPoint(bounds.north, bounds.east))
        .get();

    return snapshot.docs
        .map((doc) => Visit.fromFirestore(doc))
        .where((visit) => visit.isNearby(location, radiusInKm: radiusInKm))
        .toList();
  }

  // 반경 계산을 위한 헬퍼 메서드
  _BoundingBox _getBoundsFromRadius(LatLng center, double radiusInKm) {
    const double earthRadius = 6371.0; // 지구 반지름 (km)
    final double latRadian = radiusInKm / earthRadius;
    final double lonRadian =
        asin(sin(latRadian) / cos(center.latitude * pi / 180.0));

    final double latChange = latRadian * 180.0 / pi;
    final double lonChange = lonRadian * 180.0 / pi;

    return _BoundingBox(
      north: center.latitude + latChange,
      south: center.latitude - latChange,
      east: center.longitude + lonChange,
      west: center.longitude - lonChange,
    );
  }
}

class _BoundingBox {
  final double north;
  final double south;
  final double east;
  final double west;

  _BoundingBox({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Visit {
  final String id;
  final String userId;
  final String placeId;
  final String placeName;
  final LatLng location;
  final DateTime visitedAt;
  final List<String> photos;
  final String? note;
  final bool isVerified;
  final String verificationType; // 'gps', 'photo', 'qr', 'manual'
  final Map<String, dynamic>? verificationData;

  Visit({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    required this.location,
    required this.visitedAt,
    required this.photos,
    this.note,
    required this.isVerified,
    required this.verificationType,
    this.verificationData,
  });

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;

    return Visit(
      id: doc.id,
      userId: data['userId'],
      placeId: data['placeId'],
      placeName: data['placeName'],
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      visitedAt: (data['visitedAt'] as Timestamp).toDate(),
      photos: List<String>.from(data['photos']),
      note: data['note'],
      isVerified: data['isVerified'],
      verificationType: data['verificationType'],
      verificationData: data['verificationData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'placeId': placeId,
      'placeName': placeName,
      'location': GeoPoint(location.latitude, location.longitude),
      'visitedAt': Timestamp.fromDate(visitedAt),
      'photos': photos,
      'note': note,
      'isVerified': isVerified,
      'verificationType': verificationType,
      'verificationData': verificationData,
    };
  }

  Visit copyWith({
    String? id,
    String? userId,
    String? placeId,
    String? placeName,
    LatLng? location,
    DateTime? visitedAt,
    List<String>? photos,
    String? note,
    bool? isVerified,
    String? verificationType,
    Map<String, dynamic>? verificationData,
  }) {
    return Visit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      location: location ?? this.location,
      visitedAt: visitedAt ?? this.visitedAt,
      photos: photos ?? List<String>.from(this.photos),
      note: note ?? this.note,
      isVerified: isVerified ?? this.isVerified,
      verificationType: verificationType ?? this.verificationType,
      verificationData: verificationData ?? this.verificationData,
    );
  }

  bool isRecentVisit() {
    final now = DateTime.now();
    final difference = now.difference(visitedAt);
    return difference.inDays <= 7;
  }

  bool isNearby(LatLng currentLocation, {double radiusInKm = 0.1}) {
    final distance = const Distance().as(
      LengthUnit.Kilometer,
      location,
      currentLocation,
    );
    return distance <= radiusInKm;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TravelStyle {
  final String id;
  final String userId;
  final List<String> preferredDestinations; // 선호하는 여행지 유형
  final List<String> travelMethods; // 선호하는 이동 수단
  final List<String> accommodationTypes; // 선호하는 숙박 유형
  final List<String> activities; // 선호하는 활동
  final String budgetRange; // 선호하는 예산 범위
  final int tripDuration; // 선호하는 여행 기간
  final DateTime lastUpdated;

  TravelStyle({
    required this.id,
    required this.userId,
    required this.preferredDestinations,
    required this.travelMethods,
    required this.accommodationTypes,
    required this.activities,
    required this.budgetRange,
    required this.tripDuration,
    required this.lastUpdated,
  });

  factory TravelStyle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelStyle(
      id: doc.id,
      userId: data['userId'],
      preferredDestinations: List<String>.from(data['preferredDestinations']),
      travelMethods: List<String>.from(data['travelMethods']),
      accommodationTypes: List<String>.from(data['accommodationTypes']),
      activities: List<String>.from(data['activities']),
      budgetRange: data['budgetRange'],
      tripDuration: data['tripDuration'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'preferredDestinations': preferredDestinations,
      'travelMethods': travelMethods,
      'accommodationTypes': accommodationTypes,
      'activities': activities,
      'budgetRange': budgetRange,
      'tripDuration': tripDuration,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TravelStats {
  final String id;
  final String userId;
  final int totalTrips;
  final int totalCountries;
  final int totalCities;
  final int totalDays;
  final Map<String, int> destinationTypes; // 예: {'해변': 5, '도시': 3}
  final Map<String, int> activities; // 예: {'등산': 10, '수영': 5}
  final double totalDistance;
  final DateTime lastUpdated;

  TravelStats({
    required this.id,
    required this.userId,
    required this.totalTrips,
    required this.totalCountries,
    required this.totalCities,
    required this.totalDays,
    required this.destinationTypes,
    required this.activities,
    required this.totalDistance,
    required this.lastUpdated,
  });

  factory TravelStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelStats(
      id: doc.id,
      userId: data['userId'],
      totalTrips: data['totalTrips'],
      totalCountries: data['totalCountries'],
      totalCities: data['totalCities'],
      totalDays: data['totalDays'],
      destinationTypes: Map<String, int>.from(data['destinationTypes']),
      activities: Map<String, int>.from(data['activities']),
      totalDistance: data['totalDistance'].toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'totalTrips': totalTrips,
      'totalCountries': totalCountries,
      'totalCities': totalCities,
      'totalDays': totalDays,
      'destinationTypes': destinationTypes,
      'activities': activities,
      'totalDistance': totalDistance,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  double get averageTripDuration {
    return totalDays / totalTrips;
  }

  String get mostVisitedDestinationType {
    return destinationTypes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get mostFrequentActivity {
    return activities.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

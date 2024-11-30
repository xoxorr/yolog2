import 'package:cloud_firestore/cloud_firestore.dart';

class TravelHistory {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? accommodation;
  final List<String> activities;
  final double totalExpense;
  final String currency;
  final List<String> photos;
  final String? notes;
  final List<GeoPoint> visitedLocations;

  TravelHistory({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.accommodation,
    required this.activities,
    required this.totalExpense,
    required this.currency,
    required this.photos,
    this.notes,
    required this.visitedLocations,
  });

  factory TravelHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelHistory(
      id: doc.id,
      userId: data['userId'],
      destination: data['destination'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      accommodation: data['accommodation'],
      activities: List<String>.from(data['activities']),
      totalExpense: data['totalExpense'].toDouble(),
      currency: data['currency'],
      photos: List<String>.from(data['photos']),
      notes: data['notes'],
      visitedLocations: List<GeoPoint>.from(data['visitedLocations']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'accommodation': accommodation,
      'activities': activities,
      'totalExpense': totalExpense,
      'currency': currency,
      'photos': photos,
      'notes': notes,
      'visitedLocations': visitedLocations,
    };
  }

  int get tripDuration {
    return endDate.difference(startDate).inDays + 1;
  }

  double get dailyExpense {
    return totalExpense / tripDuration;
  }
}

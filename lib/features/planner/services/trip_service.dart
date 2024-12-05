import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _firestore;
  final String _collection = 'trips';

  TripService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create a new trip
  Future<Trip> createTrip(Trip trip) async {
    final docRef = await _firestore.collection(_collection).add(trip.toFirestore());
    return trip.copyWith(id: docRef.id);
  }

  // Get a trip by ID
  Future<Trip?> getTrip(String tripId) async {
    final doc = await _firestore.collection(_collection).doc(tripId).get();
    return doc.exists ? Trip.fromFirestore(doc) : null;
  }

  // Get all trips for a user
  Stream<List<Trip>> getUserTrips(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

  // Update a trip
  Future<void> updateTrip(String tripId, Trip trip) async {
    await _firestore
        .collection(_collection)
        .doc(tripId)
        .update(trip.toFirestore());
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection(_collection).doc(tripId).delete();
  }

  // Get upcoming trips
  Stream<List<Trip>> getUpcomingTrips(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('startDate', isGreaterThanOrEqualTo: now)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

  // Get ongoing trips
  Stream<List<Trip>> getOngoingTrips(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

  // Get completed trips
  Stream<List<Trip>> getCompletedTrips(String userId) {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('endDate', isLessThan: now)
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList());
  }

  // Search trips by destination
  Future<List<Trip>> searchTripsByDestination(
      String userId, String destination) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('destination', isGreaterThanOrEqualTo: destination)
        .where('destination',
            isLessThanOrEqualTo: '$destination\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
  }

  // Get trips by date range
  Future<List<Trip>> getTripsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('startDate', isGreaterThanOrEqualTo: startDate)
        .where('startDate', isLessThanOrEqualTo: endDate)
        .get();
    return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
  }

  // Get trip statistics
  Future<Map<String, dynamic>> getTripStatistics(String userId) async {
    final trips = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    final tripList = trips.docs.map((doc) => Trip.fromFirestore(doc)).toList();

    return {
      'totalTrips': tripList.length,
      'upcomingTrips':
          tripList.where((trip) => trip.startDate.isAfter(DateTime.now())).length,
      'completedTrips':
          tripList.where((trip) => trip.endDate.isBefore(DateTime.now())).length,
      'ongoingTrips': tripList.where((trip) {
        final now = DateTime.now();
        return trip.startDate.isBefore(now) && trip.endDate.isAfter(now);
      }).length,
      'destinations': tripList
          .map((trip) => trip.destination)
          .toSet()
          .length, // unique destinations
      'totalDays': tripList.fold(
          0,
          (sum, trip) =>
              sum + trip.endDate.difference(trip.startDate).inDays + 1),
    };
  }
}

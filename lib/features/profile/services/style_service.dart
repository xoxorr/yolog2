import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_style/style_model.dart';
import '../models/travel_style/preference_model.dart';

class StyleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 여행 스타일 관련 메서드
  Future<TravelStyle?> getTravelStyle(String userId) async {
    final doc = await _firestore
        .collection('travelStyles')
        .where('userId', isEqualTo: userId)
        .get();

    if (doc.docs.isEmpty) return null;
    return TravelStyle.fromFirestore(doc.docs.first);
  }

  Future<void> updateTravelStyle(TravelStyle style) async {
    await _firestore
        .collection('travelStyles')
        .doc(style.id)
        .set(style.toFirestore());
  }

  // 선호도 관련 메서드
  Future<List<TravelPreference>> getUserPreferences(String userId) async {
    final snapshot = await _firestore
        .collection('preferences')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => TravelPreference.fromFirestore(doc))
        .toList();
  }

  Future<void> addPreference(TravelPreference preference) async {
    await _firestore
        .collection('preferences')
        .doc(preference.id)
        .set(preference.toFirestore());
  }

  Future<void> updatePreference(TravelPreference preference) async {
    await _firestore
        .collection('preferences')
        .doc(preference.id)
        .update(preference.toFirestore());
  }

  Future<void> deletePreference(String preferenceId) async {
    await _firestore.collection('preferences').doc(preferenceId).delete();
  }

  // 스타일 분석 메서드
  Future<Map<String, int>> analyzeTopDestinations(String userId) async {
    final preferences = await getUserPreferences(userId);
    final Map<String, int> destinations = {};

    for (var pref in preferences) {
      if (pref.category == 'destination') {
        destinations[pref.item] = (destinations[pref.item] ?? 0) + pref.rating;
      }
    }

    return Map.fromEntries(
      destinations.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<Map<String, double>> calculateCategoryAverages(String userId) async {
    final preferences = await getUserPreferences(userId);
    final Map<String, List<int>> categoryRatings = {};

    for (var pref in preferences) {
      if (!categoryRatings.containsKey(pref.category)) {
        categoryRatings[pref.category] = [];
      }
      categoryRatings[pref.category]!.add(pref.rating);
    }

    final Map<String, double> averages = {};
    categoryRatings.forEach((category, ratings) {
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      averages[category] = average;
    });

    return averages;
  }
}

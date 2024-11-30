import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio/history_model.dart';
import '../models/portfolio/story_model.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 여행 이력 관련 메서드
  Future<List<TravelHistory>> getUserHistory(String userId) async {
    final snapshot = await _firestore
        .collection('travelHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TravelHistory.fromFirestore(doc))
        .toList();
  }

  Future<void> addTravelHistory(TravelHistory history) async {
    await _firestore
        .collection('travelHistory')
        .doc(history.id)
        .set(history.toFirestore());
  }

  Future<void> updateTravelHistory(TravelHistory history) async {
    await _firestore
        .collection('travelHistory')
        .doc(history.id)
        .update(history.toFirestore());
  }

  Future<void> deleteTravelHistory(String historyId) async {
    await _firestore.collection('travelHistory').doc(historyId).delete();
  }

  // 여행 스토리 관련 메서드
  Future<List<TravelStory>> getUserStories(String userId) async {
    final snapshot = await _firestore
        .collection('travelStories')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => TravelStory.fromFirestore(doc)).toList();
  }

  Future<void> addTravelStory(TravelStory story) async {
    await _firestore
        .collection('travelStories')
        .doc(story.id)
        .set(story.toFirestore());
  }

  Future<void> updateTravelStory(TravelStory story) async {
    await _firestore
        .collection('travelStories')
        .doc(story.id)
        .update(story.toFirestore());
  }

  Future<void> deleteTravelStory(String storyId) async {
    await _firestore.collection('travelStories').doc(storyId).delete();
  }

  // 포트폴리오 분석 메서드
  Future<Map<String, int>> getVisitedCountries(String userId) async {
    final histories = await getUserHistory(userId);
    final Map<String, int> countries = {};

    for (var history in histories) {
      final country = history.destination.split(',').last.trim();
      countries[country] = (countries[country] ?? 0) + 1;
    }

    return Map.fromEntries(
      countries.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<Map<String, double>> getActivityDistribution(String userId) async {
    final histories = await getUserHistory(userId);
    final Map<String, int> activityCounts = {};
    int totalActivities = 0;

    for (var history in histories) {
      for (var activity in history.activities) {
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
        totalActivities++;
      }
    }

    final Map<String, double> distribution = {};
    activityCounts.forEach((activity, count) {
      distribution[activity] = count / totalActivities * 100;
    });

    return distribution;
  }
}

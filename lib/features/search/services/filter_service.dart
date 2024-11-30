import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_filter_model.dart';
import '../models/emotion_tag_model.dart';

class FilterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 필터 관련 메서드
  Future<List<String>> getAvailableDestinations() async {
    final snapshot = await _firestore
        .collection('destinations')
        .orderBy('popularity', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getAvailableActivities() async {
    final snapshot = await _firestore
        .collection('activities')
        .orderBy('popularity', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<EmotionTag>> getAvailableEmotionTags() async {
    final snapshot = await _firestore
        .collection('emotionTags')
        .orderBy('usageCount', descending: true)
        .get();

    return snapshot.docs.map((doc) => EmotionTag.fromFirestore(doc)).toList();
  }

  // 필터 프리셋 관련 메서드
  Future<void> saveFilterPreset(String userId, SearchFilter filter) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('filterPresets')
        .doc(filter.id)
        .set(filter.toFirestore());
  }

  Future<List<SearchFilter>> getFilterPresets(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('filterPresets')
        .orderBy('lastUsed', descending: true)
        .get();

    return snapshot.docs.map((doc) => SearchFilter.fromFirestore(doc)).toList();
  }

  Future<void> deleteFilterPreset(String userId, String presetId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('filterPresets')
        .doc(presetId)
        .delete();
  }

  // 필터 추천 메서드
  Future<SearchFilter> getRecommendedFilter(String userId) async {
    // 사용자의 여행 스타일과 선호도를 기반으로 필터 추천
    final userPreferences = await _firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .get();

    final List<String> recommendedDestinations = [];
    final List<String> recommendedActivities = [];
    final List<String> recommendedTags = [];

    for (var doc in userPreferences.docs) {
      final type = doc.get('type') as String;
      final value = doc.get('value') as String;
      final rating = doc.get('rating') as double;

      if (rating >= 4.0) {
        switch (type) {
          case 'destination':
            recommendedDestinations.add(value);
            break;
          case 'activity':
            recommendedActivities.add(value);
            break;
          case 'emotionTag':
            recommendedTags.add(value);
            break;
        }
      }
    }

    return SearchFilter(
      id: 'recommended',
      userId: userId,
      destinations: recommendedDestinations.take(3).toList(),
      activities: recommendedActivities.take(3).toList(),
      emotionTags: recommendedTags.take(3).toList(),
      includePhotosOnly: true,
      sortBy: 'rating',
      ascending: false,
      lastUsed: DateTime.now(),
    );
  }

  // 필터 통계 메서드
  Future<Map<String, dynamic>> getFilterStats(String userId) async {
    final searchHistory = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .get();

    final Map<String, int> destinationStats = {};
    final Map<String, int> activityStats = {};
    final Map<String, int> tagStats = {};

    for (var doc in searchHistory.docs) {
      final filter = SearchFilter.fromFirestore(doc);

      for (var destination in filter.destinations) {
        destinationStats[destination] =
            (destinationStats[destination] ?? 0) + 1;
      }

      for (var activity in filter.activities) {
        activityStats[activity] = (activityStats[activity] ?? 0) + 1;
      }

      for (var tag in filter.emotionTags) {
        tagStats[tag] = (tagStats[tag] ?? 0) + 1;
      }
    }

    return {
      'destinations': _sortMapByValue(destinationStats),
      'activities': _sortMapByValue(activityStats),
      'emotionTags': _sortMapByValue(tagStats),
    };
  }

  Map<String, int> _sortMapByValue(Map<String, int> map) {
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(entries);
  }

  // 필터 검증 메서드
  bool validateFilter(SearchFilter filter) {
    if (filter.destinations.isEmpty &&
        filter.activities.isEmpty &&
        filter.emotionTags.isEmpty &&
        filter.dateRange == null &&
        filter.budgetRange == null &&
        filter.minRating == null) {
      return false; // 최소한 하나의 필터 조건이 필요
    }

    if (filter.dateRange != null &&
        filter.dateRange!.start.isAfter(filter.dateRange!.end)) {
      return false; // 날짜 범위가 올바르지 않음
    }

    if (filter.budgetRange != null &&
        filter.budgetRange!.start > filter.budgetRange!.end) {
      return false; // 예산 범위가 올바르지 않음
    }

    if (filter.minRating != null &&
        (filter.minRating! < 0 || filter.minRating! > 5)) {
      return false; // 평점 범위가 올바르지 않음
    }

    return true;
  }
}

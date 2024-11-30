import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_filter_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 검색 메서드
  Future<List<DocumentSnapshot>> searchContent({
    required String query,
    required SearchFilter filter,
    int limit = 20,
  }) async {
    Query searchQuery = _firestore.collection('travelStories');

    // 기본 필터 적용
    if (filter.destinations.isNotEmpty) {
      searchQuery =
          searchQuery.where('destination', whereIn: filter.destinations);
    }

    if (filter.activities.isNotEmpty) {
      searchQuery =
          searchQuery.where('activities', arrayContainsAny: filter.activities);
    }

    if (filter.dateRange != null) {
      searchQuery = searchQuery
          .where('date', isGreaterThanOrEqualTo: filter.dateRange!.start)
          .where('date', isLessThanOrEqualTo: filter.dateRange!.end);
    }

    if (filter.emotionTags.isNotEmpty) {
      searchQuery = searchQuery.where('emotionTags',
          arrayContainsAny: filter.emotionTags);
    }

    if (filter.minRating != null) {
      searchQuery =
          searchQuery.where('rating', isGreaterThanOrEqualTo: filter.minRating);
    }

    if (filter.includePhotosOnly) {
      searchQuery = searchQuery.where('hasPhotos', isEqualTo: true);
    }

    // 정렬 적용
    searchQuery = searchQuery.orderBy(
      filter.sortBy,
      descending: !filter.ascending,
    );

    // 검색 실행
    final snapshot = await searchQuery.limit(limit).get();
    return snapshot.docs;
  }

  // 필터 저장 메서드
  Future<void> saveSearchFilter(SearchFilter filter) async {
    await _firestore
        .collection('searchFilters')
        .doc(filter.id)
        .set(filter.toFirestore());
  }

  // 최근 필터 조회
  Future<List<SearchFilter>> getRecentFilters(String userId) async {
    final snapshot = await _firestore
        .collection('searchFilters')
        .where('userId', isEqualTo: userId)
        .orderBy('lastUsed', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => SearchFilter.fromFirestore(doc)).toList();
  }

  // 인기 검색어 조회
  Future<Map<String, int>> getPopularSearchTerms() async {
    final snapshot = await _firestore
        .collection('searchAnalytics')
        .orderBy('count', descending: true)
        .limit(10)
        .get();

    final Map<String, int> terms = {};
    for (var doc in snapshot.docs) {
      terms[doc.id] = doc.get('count') as int;
    }
    return terms;
  }

  // 검색어 자동완성
  Future<List<String>> getSearchSuggestions(String prefix) async {
    if (prefix.isEmpty) return [];

    final snapshot = await _firestore
        .collection('searchSuggestions')
        .where('prefix', isEqualTo: prefix.toLowerCase())
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => doc.get('suggestion') as String).toList();
  }

  // 검색 기록 저장
  Future<void> saveSearchHistory(String userId, String query) async {
    final doc = _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .doc();

    await doc.set({
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 검색어 분석 업데이트
    final analyticsRef = _firestore.collection('searchAnalytics').doc(query);
    await analyticsRef.set({
      'count': FieldValue.increment(1),
      'lastSearched': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 검색 기록 조회
  Future<List<String>> getSearchHistory(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => doc.get('query') as String).toList();
  }

  // 검색 기록 삭제
  Future<void> clearSearchHistory(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('searchHistory')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // 연관 검색어 추천
  Future<List<String>> getRelatedSearches(String query) async {
    final snapshot = await _firestore
        .collection('searchRelations')
        .where('queries', arrayContains: query)
        .limit(5)
        .get();

    final List<String> related = [];
    for (var doc in snapshot.docs) {
      final queries = List<String>.from(doc.get('queries'));
      related.addAll(queries.where((q) => q != query));
    }

    return related.take(5).toList();
  }
}

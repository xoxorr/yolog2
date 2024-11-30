import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tag_model.dart';

class TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tags';

  // 태그 생성
  Future<TagModel> createTag(String name, String description) async {
    // 이미 존재하는 태그인지 확인
    final existing = await _firestore
        .collection(_collection)
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('이미 존재하는 태그입니다.');
    }

    final docRef = _firestore.collection(_collection).doc();
    final now = DateTime.now();
    final tag = TagModel(
      id: docRef.id,
      name: name,
      description: description,
      usageCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(tag.toJson());
    return tag;
  }

  // 태그 업데이트
  Future<TagModel> updateTag(
    String tagId, {
    String? name,
    String? description,
  }) async {
    final docRef = _firestore.collection(_collection).doc(tagId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('태그를 찾을 수 없습니다.');
    }

    final tag = TagModel.fromJson(doc.data()!);
    final updatedTag = tag.copyWith(
      name: name,
      description: description,
      updatedAt: DateTime.now(),
    );

    await docRef.update(updatedTag.toJson());
    return updatedTag;
  }

  // 태그 사용 횟수 증가
  Future<void> incrementUsageCount(String tagId) async {
    await _firestore.collection(_collection).doc(tagId).update({
      'usageCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 태그 검색
  Future<List<TagModel>> searchTags(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .orderBy('name')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => TagModel.fromJson(doc.data())).toList();
  }

  // 인기 태그 가져오기
  Future<List<TagModel>> getTrendingTags({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isTrending', isEqualTo: true)
        .orderBy('usageCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => TagModel.fromJson(doc.data())).toList();
  }

  // 최근 사용된 태그 가져오기
  Future<List<TagModel>> getRecentTags({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => TagModel.fromJson(doc.data())).toList();
  }

  // 태그 트렌딩 상태 업데이트
  Future<void> updateTrendingStatus(String tagId, bool isTrending) async {
    await _firestore.collection(_collection).doc(tagId).update({
      'isTrending': isTrending,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 연관 태그 가져오기
  Future<List<TagModel>> getRelatedTags(String tagId, {int limit = 10}) async {
    final doc = await _firestore.collection(_collection).doc(tagId).get();
    if (!doc.exists) {
      throw Exception('태그를 찾을 수 없습니다.');
    }

    // 현재 태그의 사용량을 기준으로 비슷한 사용량을 가진 태그들을 검색
    final currentTag = TagModel.fromJson(doc.data()!);
    final lowerBound = currentTag.usageCount * 0.5;
    final upperBound = currentTag.usageCount * 1.5;

    final snapshot = await _firestore
        .collection(_collection)
        .where('usageCount', isGreaterThanOrEqualTo: lowerBound)
        .where('usageCount', isLessThanOrEqualTo: upperBound)
        .orderBy('usageCount', descending: true)
        .limit(limit + 1) // 현재 태그를 제외하기 위해 1개 더 가져옴
        .get();

    return snapshot.docs
        .map((doc) => TagModel.fromJson(doc.data()))
        .where((tag) => tag.id != tagId) // 현재 태그 제외
        .take(limit)
        .toList();
  }

  // 태그 통계 가져오기
  Future<Map<String, dynamic>> getTagStats(String tagId) async {
    final doc = await _firestore.collection(_collection).doc(tagId).get();
    if (!doc.exists) {
      throw Exception('태그를 찾을 수 없습니다.');
    }

    final tag = TagModel.fromJson(doc.data()!);
    final now = DateTime.now();
    final createdAt = tag.createdAt;
    final daysActive = now.difference(createdAt).inDays;
    final averageUsagePerDay = daysActive > 0
        ? tag.usageCount / daysActive
        : tag.usageCount.toDouble();

    return {
      'totalUsage': tag.usageCount,
      'daysActive': daysActive,
      'averageUsagePerDay': averageUsagePerDay,
      'isTrending': tag.isTrending,
      'lastUsed': tag.updatedAt,
    };
  }
}

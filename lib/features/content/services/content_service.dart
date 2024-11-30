import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'contents';

  // 인기 콘텐츠 가져오기
  Future<List<ContentModel>> getPopularContents({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isPopular', isEqualTo: true)
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentModel.fromJson(doc.data()))
        .toList();
  }

  // 최신 콘텐츠 가져오기
  Future<List<ContentModel>> getRecentContents({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentModel.fromJson(doc.data()))
        .toList();
  }

  // 콘텐츠 상세 정보 가져오기
  Future<ContentModel> getContent(String contentId) async {
    final doc = await _firestore.collection(_collection).doc(contentId).get();
    if (!doc.exists) {
      throw Exception('Content not found');
    }
    return ContentModel.fromJson(doc.data()!);
  }

  // 조회수 증가
  Future<void> incrementViewCount(String contentId) async {
    await _firestore.collection(_collection).doc(contentId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // 좋아요 토글
  Future<bool> toggleLike(String contentId, String userId) async {
    final likesRef = _firestore
        .collection(_collection)
        .doc(contentId)
        .collection('likes')
        .doc(userId);

    bool isLiked = false;
    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likesRef);
      final contentRef = _firestore.collection(_collection).doc(contentId);

      if (likeDoc.exists) {
        // 좋아요 취소
        transaction.delete(likesRef);
        transaction.update(contentRef, {
          'likeCount': FieldValue.increment(-1),
        });
        isLiked = false;
      } else {
        // 좋아요 추가
        transaction.set(likesRef, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(contentRef, {
          'likeCount': FieldValue.increment(1),
        });
        isLiked = true;
      }
    });

    return isLiked;
  }

  // 태그로 콘텐츠 검색
  Future<List<ContentModel>> searchContentsByTag(String tag) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => ContentModel.fromJson(doc.data()))
        .toList();
  }

  // 텍스트로 콘텐츠 검색
  Future<List<ContentModel>> searchContents(String query) async {
    // Note: Firestore는 전문 검색을 지원하지 않습니다.
    // 실제 구현시 Algolia 같은 검색 서비스 사용을 고려하세요.
    final snapshot = await _firestore
        .collection(_collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .orderBy('title')
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => ContentModel.fromJson(doc.data()))
        .toList();
  }

  // 사용자별 콘텐츠 가져오기
  Future<List<ContentModel>> getUserContents(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ContentModel.fromJson(doc.data()))
        .toList();
  }

  // 콘텐츠 생성
  Future<ContentModel> createContent(ContentModel content) async {
    final docRef = _firestore.collection(_collection).doc();
    final newContent = content.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(newContent.toJson());
    return newContent;
  }

  // 콘텐츠 수정
  Future<ContentModel> updateContent(ContentModel content) async {
    final updatedContent = content.copyWith(
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection(_collection)
        .doc(content.id)
        .update(updatedContent.toJson());

    return updatedContent;
  }

  // 콘텐츠 삭제
  Future<void> deleteContent(String contentId) async {
    await _firestore.collection(_collection).doc(contentId).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookmark_model.dart';
import '../models/content_model.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookmarks';

  // 사용자의 북마크 목록 가져오기
  Future<List<BookmarkModel>> getUserBookmarks(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BookmarkModel.fromJson(doc.data()))
        .toList();
  }

  // 북마크 추가
  Future<BookmarkModel> addBookmark({
    required String userId,
    required ContentModel content,
    String? note,
  }) async {
    final docRef = _firestore.collection(_collection).doc();
    final bookmark = BookmarkModel(
      id: docRef.id,
      userId: userId,
      contentId: content.id,
      content: content,
      createdAt: DateTime.now(),
      note: note,
    );

    await docRef.set(bookmark.toJson());
    return bookmark;
  }

  // 북마크 삭제
  Future<void> removeBookmark(String bookmarkId) async {
    await _firestore.collection(_collection).doc(bookmarkId).delete();
  }

  // 북마크 메모 업데이트
  Future<BookmarkModel> updateBookmarkNote(
      String bookmarkId, String note) async {
    final docRef = _firestore.collection(_collection).doc(bookmarkId);
    await docRef.update({'note': note});

    final doc = await docRef.get();
    return BookmarkModel.fromJson(doc.data()!);
  }

  // 콘텐츠가 북마크되었는지 확인
  Future<bool> isBookmarked(String userId, String contentId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('contentId', isEqualTo: contentId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 콘텐츠의 북마크 수 가져오기
  Future<int> getBookmarkCount(String contentId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('contentId', isEqualTo: contentId)
        .count()
        .get();

    return snapshot.count;
  }

  // 태그로 북마크 검색
  Future<List<BookmarkModel>> searchBookmarksByTag(
    String userId,
    String tag,
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('content.tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BookmarkModel.fromJson(doc.data()))
        .toList();
  }

  // 텍스트로 북마크 검색
  Future<List<BookmarkModel>> searchBookmarks(
    String userId,
    String query,
  ) async {
    // Note: Firestore는 전문 검색을 지원하지 않습니다.
    // 실제 구현시 Algolia 같은 검색 서비스 사용을 고려하세요.
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('content.title', isGreaterThanOrEqualTo: query)
        .where('content.title', isLessThan: '${query}z')
        .orderBy('content.title')
        .get();

    return snapshot.docs
        .map((doc) => BookmarkModel.fromJson(doc.data()))
        .toList();
  }

  // 북마크 메타데이터 업데이트
  Future<BookmarkModel> updateBookmarkMetadata(
    String bookmarkId,
    Map<String, dynamic> metadata,
  ) async {
    final docRef = _firestore.collection(_collection).doc(bookmarkId);
    await docRef.update({'metadata': metadata});

    final doc = await docRef.get();
    return BookmarkModel.fromJson(doc.data()!);
  }
}

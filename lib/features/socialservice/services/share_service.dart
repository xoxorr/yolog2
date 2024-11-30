import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/share_model.dart';

class ShareService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shares';

  // 콘텐츠 공유하기
  Future<ShareModel> shareContent(
    String userId,
    String contentId,
    String platform, {
    String? message,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final share = ShareModel(
        id: docRef.id,
        userId: userId,
        contentId: contentId,
        platform: platform,
        message: message,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, share.toJson());

        // 콘텐츠의 공유 수 증가
        final contentRef = _firestore.collection('posts').doc(contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'shareCount': FieldValue.increment(1),
          });
        }
      });

      return share;
    } catch (e) {
      throw Exception('콘텐츠 공유에 실패했습니다: $e');
    }
  }

  // 공유 취소하기
  Future<void> unshareContent(String shareId, String contentId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 공유 문서 삭제
        final docRef = _firestore.collection(_collection).doc(shareId);
        transaction.delete(docRef);

        // 콘텐츠의 공유 수 감소
        final contentRef = _firestore.collection('posts').doc(contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'shareCount': FieldValue.increment(-1),
          });
        }
      });
    } catch (e) {
      throw Exception('공유 취소에 실패했습니다: $e');
    }
  }

  // 콘텐츠의 공유 목록 가져오기
  Future<List<ShareModel>> getShares(
    String contentId, {
    String? lastShareId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('contentId', isEqualTo: contentId)
          .orderBy('createdAt', descending: true)
          .withConverter<ShareModel>(
            fromFirestore: (snapshot, _) =>
                ShareModel.fromJson(snapshot.data()!),
            toFirestore: (share, _) => share.toJson(),
          );

      if (lastShareId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastShareId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('공유 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 사용자의 공유 목록 가져오기
  Future<List<ShareModel>> getUserShares(
    String userId, {
    String? lastShareId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<ShareModel>(
            fromFirestore: (snapshot, _) =>
                ShareModel.fromJson(snapshot.data()!),
            toFirestore: (share, _) => share.toJson(),
          );

      if (lastShareId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastShareId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('사용자의 공유 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 플랫폼별 공유 통계 가져오기
  Future<Map<String, int>> getShareStats(String contentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('contentId', isEqualTo: contentId)
          .get();

      final stats = <String, int>{};
      for (var doc in snapshot.docs) {
        final share = ShareModel.fromJson(doc.data());
        stats[share.platform] = (stats[share.platform] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('공유 통계를 가져오는데 실패했습니다: $e');
    }
  }
}

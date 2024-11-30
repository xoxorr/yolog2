import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/like_model.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'likes';

  // 좋아요 추가
  Future<LikeModel> addLike(
      String userId, String contentId, String contentType) async {
    try {
      // 이미 좋아요를 눌렀는지 확인
      final existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('이미 좋아요를 눌렀습니다.');
      }

      // 트랜잭션으로 좋아요 생성
      final likeDoc = await _firestore
          .runTransaction<DocumentReference>((transaction) async {
        final docRef = _firestore.collection(_collection).doc();
        final like = LikeModel(
          id: docRef.id,
          userId: userId,
          contentId: contentId,
          contentType: contentType,
          createdAt: DateTime.now(),
        );

        transaction.set(docRef, like.toJson());

        // 콘텐츠의 좋아요 수 증가
        final contentRef = _firestore.collection(contentType).doc(contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'likeCount': FieldValue.increment(1),
          });
        }

        return docRef;
      });

      // 생성된 좋아요 문서 조회
      final doc = await likeDoc.get();
      return LikeModel.fromJson(doc.data()! as Map<String, dynamic>);
    } catch (e) {
      throw Exception('좋아요 추가에 실패했습니다: $e');
    }
  }

  // 좋아요 취소
  Future<void> removeLike(
      String userId, String contentId, String contentType) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('좋아요를 찾을 수 없습니다.');
      }

      // 트랜잭션으로 좋아요 삭제
      await _firestore.runTransaction((transaction) async {
        // 좋아요 문서 삭제
        final docRef =
            _firestore.collection(_collection).doc(snapshot.docs.first.id);
        transaction.delete(docRef);

        // 콘텐츠의 좋아요 수 감소
        final contentRef = _firestore.collection(contentType).doc(contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'likeCount': FieldValue.increment(-1),
          });
        }
      });
    } catch (e) {
      throw Exception('좋아요 취소에 실패했습니다: $e');
    }
  }

  // 좋아요 여부 확인
  Future<bool> hasLiked(String userId, String contentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('좋아요 확인에 실패했습니다: $e');
    }
  }

  // 콘텐츠의 좋아요 목록 가져오기
  Future<List<LikeModel>> getLikes(String contentId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('contentId', isEqualTo: contentId)
          .orderBy('createdAt', descending: true)
          .withConverter<LikeModel>(
            fromFirestore: (snapshot, _) =>
                LikeModel.fromJson(snapshot.data()!),
            toFirestore: (like, _) => like.toJson(),
          )
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('좋아요 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 사용자가 좋아요한 콘텐츠 목록 가져오기
  Future<List<LikeModel>> getUserLikes(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<LikeModel>(
            fromFirestore: (snapshot, _) =>
                LikeModel.fromJson(snapshot.data()!),
            toFirestore: (like, _) => like.toJson(),
          )
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('사용자의 좋아요 목록을 가져오는데 실패했습니다: $e');
    }
  }
}

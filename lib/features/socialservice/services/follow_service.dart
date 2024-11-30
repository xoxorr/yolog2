import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/follow_model.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'follows';

  // 팔로우하기
  Future<FollowModel> follow(String followerId, String followingId) async {
    try {
      // 자기 자신을 팔로우하는 것 방지
      if (followerId == followingId) {
        throw Exception('자기 자신을 팔로우할 수 없습니다.');
      }

      // 이미 팔로우했는지 확인
      final existing = await _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('이미 팔로우하고 있습니다.');
      }

      final docRef = _firestore.collection(_collection).doc();
      final follow = FollowModel(
        id: docRef.id,
        followerId: followerId,
        followingId: followingId,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, follow.toJson());

        // 팔로워 수와 팔로잉 수 업데이트
        final followerRef = _firestore.collection('users').doc(followerId);
        final followingRef = _firestore.collection('users').doc(followingId);

        final followerDoc = await transaction.get(followerRef);
        final followingDoc = await transaction.get(followingRef);

        if (followerDoc.exists) {
          transaction.update(followerRef, {
            'followingCount': FieldValue.increment(1),
          });
        }

        if (followingDoc.exists) {
          transaction.update(followingRef, {
            'followerCount': FieldValue.increment(1),
          });
        }
      });

      return follow;
    } catch (e) {
      throw Exception('팔로우에 실패했습니다: $e');
    }
  }

  // 언팔로우하기
  Future<void> unfollow(String followerId, String followingId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('팔로우 관계를 찾을 수 없습니다.');
      }

      await _firestore.runTransaction((transaction) async {
        // 팔로우 문서 삭제
        final docRef =
            _firestore.collection(_collection).doc(snapshot.docs.first.id);
        transaction.delete(docRef);

        // 팔로워 수와 팔로잉 수 업데이트
        final followerRef = _firestore.collection('users').doc(followerId);
        final followingRef = _firestore.collection('users').doc(followingId);

        final followerDoc = await transaction.get(followerRef);
        final followingDoc = await transaction.get(followingRef);

        if (followerDoc.exists) {
          transaction.update(followerRef, {
            'followingCount': FieldValue.increment(-1),
          });
        }

        if (followingDoc.exists) {
          transaction.update(followingRef, {
            'followerCount': FieldValue.increment(-1),
          });
        }
      });
    } catch (e) {
      throw Exception('언팔로우에 실패했습니다: $e');
    }
  }

  // 팔로워 목록 가져오기
  Future<List<FollowModel>> getFollowers(
    String userId, {
    String? lastFollowId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('followingId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<FollowModel>(
            fromFirestore: (snapshot, _) =>
                FollowModel.fromJson(snapshot.data()!),
            toFirestore: (follow, _) => follow.toJson(),
          );

      if (lastFollowId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastFollowId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('팔로워 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 팔로잉 목록 가져오기
  Future<List<FollowModel>> getFollowing(
    String userId, {
    String? lastFollowId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<FollowModel>(
            fromFirestore: (snapshot, _) =>
                FollowModel.fromJson(snapshot.data()!),
            toFirestore: (follow, _) => follow.toJson(),
          );

      if (lastFollowId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastFollowId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('팔로잉 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 팔로우 여부 확인
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('팔로우 여부 확인에 실패했습니다: $e');
    }
  }
}

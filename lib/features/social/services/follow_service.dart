import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/follow_model.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'follows';

  // 팔로우하기
  Future<FollowModel> follow(String followerId, String followingId) async {
    try {
      // 이미 팔로우 중인지 확인
      final existing = await _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('이미 팔로우하고 있습니다.');
      }

      // 트랜잭션으로 팔로우 생성
      final followDoc = await _firestore
          .runTransaction<DocumentReference>((transaction) async {
        final docRef = _firestore.collection(_collection).doc();
        final follow = FollowModel(
          id: docRef.id,
          followerId: followerId,
          followingId: followingId,
          createdAt: DateTime.now(),
        );

        transaction.set(docRef, follow.toJson());
        return docRef;
      });

      // 생성된 팔로우 문서 조회
      final doc = await followDoc.get();
      return FollowModel.fromJson(doc.data()! as Map<String, dynamic>);
    } catch (e) {
      throw Exception('팔로우 생성에 실패했습니다: $e');
    }
  }

  // 언팔로우하기
  Future<void> unfollow(String followerId, String followingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('팔로우 관계가 존재하지 않습니다.');
    }

    await _firestore
        .collection(_collection)
        .doc(snapshot.docs.first.id)
        .delete();
  }

  // 팔로워 목록 가져오기
  Future<List<FollowModel>> getFollowers(String userId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('followingId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<FollowModel>(
            fromFirestore: (snapshot, _) =>
                FollowModel.fromJson(snapshot.data()!),
            toFirestore: (follow, _) => follow.toJson(),
          )
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('팔로워 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 팔로잉 목록 가져오기
  Future<List<FollowModel>> getFollowing(String userId,
      {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('followerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<FollowModel>(
            fromFirestore: (snapshot, _) =>
                FollowModel.fromJson(snapshot.data()!),
            toFirestore: (follow, _) => follow.toJson(),
          )
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('팔로잉 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 팔로워 수 가져오기
  Future<int> getFollowersCount(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('followingId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count;
  }

  // 팔로잉 수 가져오기
  Future<int> getFollowingCount(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('followerId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count;
  }

  // 팔로우 여부 확인
  Future<bool> isFollowing(String followerId, String followingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('followerId', isEqualTo: followerId)
        .where('followingId', isEqualTo: followingId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 상호 팔로우 여부 확인
  Future<bool> isMutualFollow(String userId1, String userId2) async {
    final follows = await Future.wait([
      isFollowing(userId1, userId2),
      isFollowing(userId2, userId1),
    ]);

    return follows[0] && follows[1];
  }

  // 팔로우 추천
  Future<List<String>> getRecommendedFollows(
    String userId, {
    int limit = 10,
  }) async {
    // 현재 팔로잉 목록 가져오기
    final following = await getFollowing(userId);
    final followingIds = following.map((f) => f.followingId).toList();

    // 팔로잉들의 팔로잉 목록 가져오기 (2차 연결)
    final recommendedIds = <String>{};
    for (final id in followingIds) {
      final secondDegree = await getFollowing(id);
      recommendedIds.addAll(secondDegree.map((f) => f.followingId));
    }

    // 자신과 이미 팔로우 중인 사용자 제외
    recommendedIds.remove(userId);
    recommendedIds.removeAll(followingIds);

    // 상위 N개 반환
    return recommendedIds.take(limit).toList();
  }
}

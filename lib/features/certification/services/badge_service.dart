import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge_model.dart';

class BadgeService {
  final FirebaseFirestore _firestore;
  final String userId;

  BadgeService({
    FirebaseFirestore? firestore,
    required this.userId,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _badgesRef => _firestore.collection('badges');
  CollectionReference get _userBadgesRef =>
      _firestore.collection('users').doc(userId).collection('badges');

  // 사용자의 모든 뱃지 가져오기
  Future<List<Badge>> getUserBadges() async {
    final snapshot = await _userBadgesRef.get();
    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }

  // 특정 카테고리의 뱃지 가져오기
  Future<List<Badge>> getBadgesByCategory(String category) async {
    final snapshot = await _badgesRef
        .where('category', isEqualTo: category)
        .where('isSecret', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }

  // 새로운 뱃지 획득 확인
  Future<List<Badge>> checkNewBadges(Map<String, dynamic> userStats) async {
    final allBadges = await _badgesRef.get();
    final userBadges = await _userBadgesRef.get();
    final userBadgeIds = userBadges.docs.map((doc) => doc.id).toSet();

    List<Badge> newBadges = [];

    for (var doc in allBadges.docs) {
      if (!userBadgeIds.contains(doc.id)) {
        final badge = Badge.fromFirestore(doc);
        if (badge.checkRequirements(userStats)) {
          newBadges.add(badge);
          await unlockBadge(badge);
        }
      }
    }

    return newBadges;
  }

  // 뱃지 잠금 해제
  Future<void> unlockBadge(Badge badge) async {
    final unlockedBadge = Badge(
      id: badge.id,
      name: badge.name,
      description: badge.description,
      iconUrl: badge.iconUrl,
      category: badge.category,
      requirements: badge.requirements,
      points: badge.points,
      rarity: badge.rarity,
      unlockedAt: DateTime.now(),
      isSecret: badge.isSecret,
    );

    await _userBadgesRef.doc(badge.id).set(unlockedBadge.toFirestore());

    // 사용자 포인트 업데이트
    await _firestore.collection('users').doc(userId).update({
      'points': FieldValue.increment(badge.points),
    });
  }

  // 뱃지 진행 상황 확인
  Future<Map<String, double>> getBadgeProgress(String badgeId) async {
    final badge = await _badgesRef.doc(badgeId).get();
    if (!badge.exists) return {};

    final badgeData = Badge.fromFirestore(badge);
    final userStats =
        (await _firestore.collection('users').doc(userId).get()).data() ?? {};

    Map<String, double> progress = {};
    badgeData.requirements.forEach((key, required) {
      final current = userStats[key] ?? 0;
      progress[key] = (current / required).clamp(0.0, 1.0);
    });

    return progress;
  }

  // 추천 뱃지 가져오기
  Future<List<Badge>> getRecommendedBadges() async {
    final userStats =
        (await _firestore.collection('users').doc(userId).get()).data() ?? {};
    final unlockedBadges = await getUserBadges();
    final unlockedIds = unlockedBadges.map((b) => b.id).toSet();

    final snapshot =
        await _badgesRef.where('isSecret', isEqualTo: false).limit(10).get();

    final allBadges =
        snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();

    return allBadges
        .where((badge) => !unlockedIds.contains(badge.id))
        .map((badge) {
      var progress = 0.0;
      badge.requirements.forEach((key, required) {
        final current = userStats[key] ?? 0;
        progress += (current / required).clamp(0.0, 1.0);
      });
      return MapEntry(badge, progress / badge.requirements.length);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value))
          .take(5)
          .map((entry) => entry.key)
          .toList();
  }

  // 뱃지 통계 가져오기
  Future<Map<String, dynamic>> getBadgeStats() async {
    final userBadges = await getUserBadges();

    return {
      'total': userBadges.length,
      'byRarity': {
        'common': userBadges.where((b) => b.rarity == 'common').length,
        'rare': userBadges.where((b) => b.rarity == 'rare').length,
        'epic': userBadges.where((b) => b.rarity == 'epic').length,
        'legendary': userBadges.where((b) => b.rarity == 'legendary').length,
      },
      'byCategory': userBadges.fold<Map<String, int>>({}, (map, badge) {
        map[badge.category] = (map[badge.category] ?? 0) + 1;
        return map;
      }),
      'totalPoints':
          userBadges.fold<int>(0, (sum, badge) => sum + badge.points),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category; // 'destination', 'activity', 'achievement' 등
  final Map<String, dynamic> requirements; // 획득 조건
  final int points; // 뱃지 획득 시 얻는 포인트
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final DateTime? unlockedAt;
  final bool isSecret; // 숨겨진 뱃지 여부

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.requirements,
    required this.points,
    required this.rarity,
    this.unlockedAt,
    required this.isSecret,
  });

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badge(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      iconUrl: data['iconUrl'],
      category: data['category'],
      requirements: data['requirements'],
      points: data['points'],
      rarity: data['rarity'],
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
      isSecret: data['isSecret'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'category': category,
      'requirements': requirements,
      'points': points,
      'rarity': rarity,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
      'isSecret': isSecret,
    };
  }

  bool isUnlocked() => unlockedAt != null;

  static Map<String, int> rarityPoints = {
    'common': 10,
    'rare': 30,
    'epic': 50,
    'legendary': 100,
  };

  static List<Badge> getDefaultBadges() {
    return [
      Badge(
        id: 'first_visit',
        name: '첫 발걸음',
        description: '첫 번째 여행지 방문',
        iconUrl: 'assets/badges/first_visit.png',
        category: 'achievement',
        requirements: {'visits': 1},
        points: 10,
        rarity: 'common',
        isSecret: false,
      ),
      Badge(
        id: 'world_traveler',
        name: '세계 여행가',
        description: '10개국 이상 방문',
        iconUrl: 'assets/badges/world_traveler.png',
        category: 'achievement',
        requirements: {'countries': 10},
        points: 100,
        rarity: 'legendary',
        isSecret: false,
      ),
      Badge(
        id: 'photo_master',
        name: '사진 달인',
        description: '100개 이상의 여행 사진 업로드',
        iconUrl: 'assets/badges/photo_master.png',
        category: 'activity',
        requirements: {'photos': 100},
        points: 50,
        rarity: 'epic',
        isSecret: false,
      ),
      // 추가 기본 뱃지들...
    ];
  }

  bool checkRequirements(Map<String, dynamic> userStats) {
    for (var requirement in requirements.entries) {
      final userValue = userStats[requirement.key] ?? 0;
      if (userValue < requirement.value) return false;
    }
    return true;
  }
}

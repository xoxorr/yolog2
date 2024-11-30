import 'package:cloud_firestore/cloud_firestore.dart';

class Level {
  final int level;
  final String title;
  final int requiredPoints;
  final String iconUrl;
  final Map<String, dynamic> rewards;
  final List<String> unlockedFeatures;

  Level({
    required this.level,
    required this.title,
    required this.requiredPoints,
    required this.iconUrl,
    required this.rewards,
    required this.unlockedFeatures,
  });

  factory Level.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Level(
      level: data['level'],
      title: data['title'],
      requiredPoints: data['requiredPoints'],
      iconUrl: data['iconUrl'],
      rewards: Map<String, dynamic>.from(data['rewards']),
      unlockedFeatures: List<String>.from(data['unlockedFeatures']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'title': title,
      'requiredPoints': requiredPoints,
      'iconUrl': iconUrl,
      'rewards': rewards,
      'unlockedFeatures': unlockedFeatures,
    };
  }

  static List<Level> getDefaultLevels() {
    return [
      Level(
        level: 1,
        title: '여행 초보자',
        requiredPoints: 0,
        iconUrl: 'assets/levels/level1.png',
        rewards: {
          'badges': ['first_steps'],
          'points': 0,
        },
        unlockedFeatures: ['basic_profile', 'basic_search'],
      ),
      Level(
        level: 2,
        title: '여행 탐험가',
        requiredPoints: 100,
        iconUrl: 'assets/levels/level2.png',
        rewards: {
          'badges': ['explorer'],
          'points': 50,
        },
        unlockedFeatures: ['photo_upload', 'comments'],
      ),
      Level(
        level: 3,
        title: '여행 전문가',
        requiredPoints: 300,
        iconUrl: 'assets/levels/level3.png',
        rewards: {
          'badges': ['expert_traveler'],
          'points': 100,
        },
        unlockedFeatures: ['create_guides', 'advanced_search'],
      ),
      Level(
        level: 4,
        title: '여행 마스터',
        requiredPoints: 1000,
        iconUrl: 'assets/levels/level4.png',
        rewards: {
          'badges': ['travel_master'],
          'points': 200,
        },
        unlockedFeatures: ['create_collections', 'premium_features'],
      ),
      Level(
        level: 5,
        title: '여행 레전드',
        requiredPoints: 3000,
        iconUrl: 'assets/levels/level5.png',
        rewards: {
          'badges': ['travel_legend'],
          'points': 500,
        },
        unlockedFeatures: ['all_features'],
      ),
    ];
  }

  bool canUnlockFeature(String feature) {
    return unlockedFeatures.contains(feature);
  }

  bool hasRequiredPoints(int userPoints) {
    return userPoints >= requiredPoints;
  }

  static Level? getLevelForPoints(int points) {
    final levels = getDefaultLevels();
    for (var i = levels.length - 1; i >= 0; i--) {
      if (points >= levels[i].requiredPoints) {
        return levels[i];
      }
    }
    return null;
  }

  static int getPointsToNextLevel(int currentPoints) {
    final levels = getDefaultLevels();
    for (var level in levels) {
      if (currentPoints < level.requiredPoints) {
        return level.requiredPoints - currentPoints;
      }
    }
    return 0; // 최고 레벨 달성
  }
}

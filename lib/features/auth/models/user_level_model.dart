import 'package:flutter/foundation.dart';

enum UserLevel { beginner, intermediate, advanced, expert, master }

@immutable
class UserLevelModel {
  final String userId;
  final UserLevel level;
  final int experience;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final Map<String, int> achievements;
  final DateTime lastLevelUpAt;

  const UserLevelModel({
    required this.userId,
    required this.level,
    required this.experience,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.achievements,
    required this.lastLevelUpAt,
  });

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      userId: json['userId'] as String,
      level: UserLevel.values.firstWhere(
        (e) => e.toString() == 'UserLevel.${json['level']}',
        orElse: () => UserLevel.beginner,
      ),
      experience: json['experience'] as int,
      postsCount: json['postsCount'] as int,
      followersCount: json['followersCount'] as int,
      followingCount: json['followingCount'] as int,
      achievements: Map<String, int>.from(json['achievements'] as Map),
      lastLevelUpAt: DateTime.parse(json['lastLevelUpAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level.toString().split('.').last,
      'experience': experience,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'achievements': achievements,
      'lastLevelUpAt': lastLevelUpAt.toIso8601String(),
    };
  }

  UserLevelModel copyWith({
    String? userId,
    UserLevel? level,
    int? experience,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    Map<String, int>? achievements,
    DateTime? lastLevelUpAt,
  }) {
    return UserLevelModel(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      achievements: achievements ?? this.achievements,
      lastLevelUpAt: lastLevelUpAt ?? this.lastLevelUpAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLevelModel &&
        other.userId == userId &&
        other.level == level &&
        other.experience == experience &&
        other.postsCount == postsCount &&
        other.followersCount == followersCount &&
        other.followingCount == followingCount &&
        mapEquals(other.achievements, achievements) &&
        other.lastLevelUpAt == lastLevelUpAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      level,
      experience,
      postsCount,
      followersCount,
      followingCount,
      Object.hashAll(achievements.entries),
      lastLevelUpAt,
    );
  }

  static int getRequiredExperience(UserLevel level) {
    switch (level) {
      case UserLevel.beginner:
        return 0;
      case UserLevel.intermediate:
        return 1000;
      case UserLevel.advanced:
        return 5000;
      case UserLevel.expert:
        return 20000;
      case UserLevel.master:
        return 50000;
    }
  }

  bool canLevelUp() {
    if (level == UserLevel.master) return false;
    final nextLevel = UserLevel.values[level.index + 1];
    return experience >= getRequiredExperience(nextLevel);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FollowModel {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] as String,
      followerId: json['followerId'] as String,
      followingId: json['followingId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FollowModel copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
  }) {
    return FollowModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
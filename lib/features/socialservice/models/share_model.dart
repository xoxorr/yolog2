import 'package:cloud_firestore/cloud_firestore.dart';

class ShareModel {
  final String id;
  final String userId;
  final String contentId;
  final String? message;
  final String platform; // 'facebook', 'twitter', 'instagram' 등
  final DateTime createdAt;

  ShareModel({
    required this.id,
    required this.userId,
    required this.contentId,
    this.message,
    required this.platform,
    required this.createdAt,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      message: json['message'] as String?,
      platform: json['platform'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'message': message,
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ShareModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? message,
    String? platform,
    DateTime? createdAt,
  }) {
    return ShareModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      message: message ?? this.message,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

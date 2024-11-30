import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String id;
  final String userId;
  final String contentId;
  final String contentType; // 'post', 'comment' 등
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.contentType,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'contentType': contentType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  LikeModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? contentType,
    DateTime? createdAt,
  }) {
    return LikeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

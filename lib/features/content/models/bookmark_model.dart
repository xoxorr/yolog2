import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_model.dart';

class BookmarkModel {
  final String id;
  final String userId;
  final String contentId;
  final ContentModel content;
  final DateTime createdAt;
  final String? note; // 북마크에 대한 메모
  final Map<String, dynamic> metadata; // 추가 메타데이터

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.content,
    required this.createdAt,
    this.note,
    this.metadata = const {},
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      content: ContentModel.fromJson(json['content'] as Map<String, dynamic>),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      note: json['note'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'content': content.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
      'metadata': metadata,
    };
  }

  BookmarkModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    ContentModel? content,
    DateTime? createdAt,
    String? note,
    Map<String, dynamic>? metadata,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
    );
  }
}

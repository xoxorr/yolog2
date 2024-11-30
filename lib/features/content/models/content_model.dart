import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String authorId;
  final String authorName;
  final String authorProfileUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String type; // 'video', 'article', 'image' 등
  final String contentUrl;
  final int duration; // 비디오인 경우 재생 시간(초)
  final bool isPopular;
  final Map<String, dynamic> metadata; // 추가 메타데이터

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.authorProfileUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.type,
    required this.contentUrl,
    this.duration = 0,
    this.isPopular = false,
    this.metadata = const {},
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorProfileUrl: json['authorProfileUrl'] as String,
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(json['tags'] as List),
      type: json['type'] as String,
      contentUrl: json['contentUrl'] as String,
      duration: json['duration'] as int? ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorProfileUrl': authorProfileUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'type': type,
      'contentUrl': contentUrl,
      'duration': duration,
      'isPopular': isPopular,
      'metadata': metadata,
    };
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? authorId,
    String? authorName,
    String? authorProfileUrl,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? type,
    String? contentUrl,
    int? duration,
    bool? isPopular,
    Map<String, dynamic>? metadata,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorProfileUrl: authorProfileUrl ?? this.authorProfileUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      duration: duration ?? this.duration,
      isPopular: isPopular ?? this.isPopular,
      metadata: metadata ?? this.metadata,
    );
  }
}

import 'media_model.dart';
import 'location_model.dart';
import 'visibility_type.dart';
import 'tag_model.dart';

class DraftModel {
  final String id;
  final String title;
  final String content;
  final List<MediaModel> media;
  final LocationModel? location;
  final List<TagModel> tags;
  final VisibilityType visibility;
  final String authorId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  DraftModel({
    required this.id,
    required this.title,
    required this.content,
    required this.media,
    this.location,
    required this.tags,
    required this.visibility,
    required this.authorId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      visibility: VisibilityType.parse(json['visibility'] as String),
      authorId: json['authorId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'media': media.map((m) => m.toJson()).toList(),
      'location': location?.toJson(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'visibility': visibility.toJson(),
      'authorId': authorId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  DraftModel copyWith({
    String? id,
    String? title,
    String? content,
    List<MediaModel>? media,
    LocationModel? location,
    List<TagModel>? tags,
    VisibilityType? visibility,
    String? authorId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return DraftModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      media: media ?? this.media,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      authorId: authorId ?? this.authorId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'media_model.dart';

/// LocationModel 클래스를 구현합니다. 위치 정보를 담는 모델입니다.
class LocationModel {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  LocationModel({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// PostModel 클래스를 구현합니다. 게시글의 기본 정보를 담는 모델입니다.
class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<MediaModel> media;
  final List<String> tags;
  final LocationModel? location;
  final int likeCount;
  final int commentCount;
  final double rating;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.media = const [],
    this.tags = const [],
    this.location,
    this.likeCount = 0,
    this.commentCount = 0,
    this.rating = 0.0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] != null ? LocationModel.fromJson(json['location'] as Map<String, dynamic>) : null,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'media': media.map((e) => e.toJson()).toList(),
      'tags': tags,
      'location': location?.toJson(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'rating': rating,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<MediaModel>? media,
    List<String>? tags,
    LocationModel? location,
    int? likeCount,
    int? commentCount,
    double? rating,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      media: media ?? this.media,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      rating: rating ?? this.rating,
    );
  }
}

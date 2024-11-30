import 'package:cloud_firestore/cloud_firestore.dart';

class CertificationModel {
  final String userId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final GeoPoint location;
  final String? category;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int comments;

  CertificationModel({
    required this.userId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.location,
    this.category,
    required this.createdAt,
    this.updatedAt,
    required this.likes,
    required this.comments,
  });

  // Map to Model
  factory CertificationModel.fromMap(Map<String, dynamic> map) {
    return CertificationModel(
      userId: map['userId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrls: List<String>.from(map['imageUrls']),
      location: map['location'] as GeoPoint,
      category: map['category'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      likes: map['likes'] as int,
      comments: map['comments'] as int,
    );
  }

  // Model to Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'location': location,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'comments': comments,
    };
  }

  // Copy with
  CertificationModel copyWith({
    String? userId,
    String? title,
    String? content,
    List<String>? imageUrls,
    GeoPoint? location,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? comments,
  }) {
    return CertificationModel(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}

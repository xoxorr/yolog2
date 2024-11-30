import 'package:cloud_firestore/cloud_firestore.dart';

class TagModel {
  final String id;
  final String name;
  final String description;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTrending;
  final Map<String, dynamic> metadata; // 추가 메타데이터

  TagModel({
    required this.id,
    required this.name,
    required this.description,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
    this.isTrending = false,
    this.metadata = const {},
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      usageCount: json['usageCount'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isTrending: json['isTrending'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'usageCount': usageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isTrending': isTrending,
      'metadata': metadata,
    };
  }

  TagModel copyWith({
    String? id,
    String? name,
    String? description,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTrending,
    Map<String, dynamic>? metadata,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isTrending: isTrending ?? this.isTrending,
      metadata: metadata ?? this.metadata,
    );
  }
}

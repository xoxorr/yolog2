enum MediaType { image, video }

class MediaModel {
  final String id;
  final String url;
  final String type;
  final DateTime createdAt;

  MediaModel({
    required this.id,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MediaModel copyWith({
    String? id,
    String? url,
    String? type,
    DateTime? createdAt,
  }) {
    return MediaModel(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionTag {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int usageCount;
  final DateTime lastUsed;

  EmotionTag({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.usageCount,
    required this.lastUsed,
  });

  factory EmotionTag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmotionTag(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      icon: data['icon'],
      color: data['color'],
      usageCount: data['usageCount'],
      lastUsed: (data['lastUsed'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'usageCount': usageCount,
      'lastUsed': Timestamp.fromDate(lastUsed),
    };
  }

  EmotionTag copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? usageCount,
    DateTime? lastUsed,
  }) {
    return EmotionTag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  EmotionTag incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }

  static List<EmotionTag> getDefaultTags() {
    return [
      EmotionTag(
        id: 'excited',
        name: '신나는',
        description: '활기차고 즐거운 순간',
        icon: '😊',
        color: '#FFD700',
        usageCount: 0,
        lastUsed: DateTime.now(),
      ),
      EmotionTag(
        id: 'peaceful',
        name: '평화로운',
        description: '차분하고 편안한 순간',
        icon: '😌',
        color: '#98FB98',
        usageCount: 0,
        lastUsed: DateTime.now(),
      ),
      EmotionTag(
        id: 'adventurous',
        name: '모험적인',
        description: '새롭고 도전적인 경험',
        icon: '🤠',
        color: '#FF6B6B',
        usageCount: 0,
        lastUsed: DateTime.now(),
      ),
      EmotionTag(
        id: 'romantic',
        name: '로맨틱한',
        description: '사랑스럽고 낭만적인 순간',
        icon: '🥰',
        color: '#FFB6C1',
        usageCount: 0,
        lastUsed: DateTime.now(),
      ),
      EmotionTag(
        id: 'nostalgic',
        name: '향수를 불러일으키는',
        description: '추억이 깃든 특별한 순간',
        icon: '🌅',
        color: '#DDA0DD',
        usageCount: 0,
        lastUsed: DateTime.now(),
      ),
    ];
  }
}

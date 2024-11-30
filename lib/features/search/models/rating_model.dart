import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'place', 'activity', 'accommodation' 등
  final double score;
  final String? comment;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, int> reactions; // {'helpful': 10, 'notHelpful': 2} 등

  Rating({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.score,
    this.comment,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    required this.reactions,
  });

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      userId: data['userId'],
      itemId: data['itemId'],
      itemType: data['itemType'],
      score: data['score'].toDouble(),
      comment: data['comment'],
      tags: List<String>.from(data['tags']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      reactions: Map<String, int>.from(data['reactions']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType,
      'score': score,
      'comment': comment,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'reactions': reactions,
    };
  }

  Rating copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? itemType,
    double? score,
    String? comment,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? reactions,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      score: score ?? this.score,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reactions: reactions ?? Map<String, int>.from(this.reactions),
    );
  }

  Rating addReaction(String reactionType) {
    final newReactions = Map<String, int>.from(reactions);
    newReactions[reactionType] = (newReactions[reactionType] ?? 0) + 1;
    return copyWith(reactions: newReactions);
  }

  Rating removeReaction(String reactionType) {
    final newReactions = Map<String, int>.from(reactions);
    if ((newReactions[reactionType] ?? 0) > 0) {
      newReactions[reactionType] = newReactions[reactionType]! - 1;
    }
    return copyWith(reactions: newReactions);
  }

  double get helpfulnessScore {
    final helpful = reactions['helpful'] ?? 0;
    final notHelpful = reactions['notHelpful'] ?? 0;
    final total = helpful + notHelpful;

    if (total == 0) return 0;
    return helpful / total * 100;
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 30;
  }
}

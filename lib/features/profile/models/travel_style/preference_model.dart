import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPreference {
  final String id;
  final String userId;
  final String category; // 예: 음식, 숙박, 활동 등
  final String item;
  final int rating; // 1-5 척도
  final String? note;
  final DateTime createdAt;

  TravelPreference({
    required this.id,
    required this.userId,
    required this.category,
    required this.item,
    required this.rating,
    this.note,
    required this.createdAt,
  });

  factory TravelPreference.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelPreference(
      id: doc.id,
      userId: data['userId'],
      category: data['category'],
      item: data['item'],
      rating: data['rating'],
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'item': item,
      'rating': rating,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TravelPreference copyWith({
    String? id,
    String? userId,
    String? category,
    String? item,
    int? rating,
    String? note,
    DateTime? createdAt,
  }) {
    return TravelPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      item: item ?? this.item,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

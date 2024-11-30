import 'package:cloud_firestore/cloud_firestore.dart';

class TravelStory {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime date;
  final String location;
  final List<String> photos;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final bool isPublic;
  final GeoPoint? coordinates;

  TravelStory({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    required this.location,
    required this.photos,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isPublic,
    this.coordinates,
  });

  factory TravelStory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TravelStory(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      photos: List<String>.from(data['photos']),
      tags: List<String>.from(data['tags']),
      likes: data['likes'],
      comments: data['comments'],
      shares: data['shares'],
      isPublic: data['isPublic'],
      coordinates: data['coordinates'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'location': location,
      'photos': photos,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isPublic': isPublic,
      'coordinates': coordinates,
    };
  }

  TravelStory copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? date,
    String? location,
    List<String>? photos,
    List<String>? tags,
    int? likes,
    int? comments,
    int? shares,
    bool? isPublic,
    GeoPoint? coordinates,
  }) {
    return TravelStory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isPublic: isPublic ?? this.isPublic,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}

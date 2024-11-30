import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchFilter {
  final String? id;
  final String? userId;
  final List<String> destinations;
  final List<String> activities;
  final DateTimeRange? dateRange;
  final RangeValues? budgetRange;
  final List<String> emotionTags;
  final double? minRating;
  final bool includePhotosOnly;
  final String sortBy;
  final bool ascending;
  final DateTime? lastUsed;

  SearchFilter({
    this.id,
    this.userId,
    this.destinations = const [],
    this.activities = const [],
    this.dateRange,
    this.budgetRange,
    this.emotionTags = const [],
    this.minRating,
    this.includePhotosOnly = false,
    this.sortBy = 'createdAt',
    this.ascending = false,
    this.lastUsed,
  });

  factory SearchFilter.empty() {
    return SearchFilter();
  }

  factory SearchFilter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchFilter(
      id: doc.id,
      userId: data['userId'],
      destinations: List<String>.from(data['destinations'] ?? []),
      activities: List<String>.from(data['activities'] ?? []),
      dateRange: data['dateRange'] != null
          ? DateTimeRange(
              start: (data['dateRange']['start'] as Timestamp).toDate(),
              end: (data['dateRange']['end'] as Timestamp).toDate(),
            )
          : null,
      budgetRange: data['budgetRange'] != null
          ? RangeValues(
              data['budgetRange']['start'].toDouble(),
              data['budgetRange']['end'].toDouble(),
            )
          : null,
      emotionTags: List<String>.from(data['emotionTags'] ?? []),
      minRating: data['minRating']?.toDouble(),
      includePhotosOnly: data['includePhotosOnly'] ?? false,
      sortBy: data['sortBy'] ?? 'createdAt',
      ascending: data['ascending'] ?? false,
      lastUsed: data['lastUsed'] != null
          ? (data['lastUsed'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      'destinations': destinations,
      'activities': activities,
      if (dateRange != null)
        'dateRange': {
          'start': Timestamp.fromDate(dateRange!.start),
          'end': Timestamp.fromDate(dateRange!.end),
        },
      if (budgetRange != null)
        'budgetRange': {
          'start': budgetRange!.start,
          'end': budgetRange!.end,
        },
      'emotionTags': emotionTags,
      if (minRating != null) 'minRating': minRating,
      'includePhotosOnly': includePhotosOnly,
      'sortBy': sortBy,
      'ascending': ascending,
      if (lastUsed != null) 'lastUsed': Timestamp.fromDate(lastUsed!),
    };
  }

  SearchFilter copyWith({
    String? id,
    String? userId,
    List<String>? destinations,
    List<String>? activities,
    DateTimeRange? dateRange,
    RangeValues? budgetRange,
    List<String>? emotionTags,
    double? minRating,
    bool? includePhotosOnly,
    String? sortBy,
    bool? ascending,
    DateTime? lastUsed,
  }) {
    return SearchFilter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinations: destinations ?? this.destinations,
      activities: activities ?? this.activities,
      dateRange: dateRange ?? this.dateRange,
      budgetRange: budgetRange ?? this.budgetRange,
      emotionTags: emotionTags ?? this.emotionTags,
      minRating: minRating ?? this.minRating,
      includePhotosOnly: includePhotosOnly ?? this.includePhotosOnly,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

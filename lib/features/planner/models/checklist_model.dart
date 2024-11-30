import 'package:cloud_firestore/cloud_firestore.dart';

class Checklist {
  final String id;
  final String tripId;
  final String userId;
  final String title;
  final String description;
  final List<ChecklistItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String category; // e.g., 'packing', 'documents', 'tasks'
  final bool isTemplate;
  final Map<String, dynamic>? metadata;

  Checklist({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    required this.description,
    required this.items,
    required this.createdAt,
    required this.category,
    this.updatedAt,
    this.isTemplate = false,
    this.metadata,
  });

  factory Checklist.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Checklist(
      id: doc.id,
      tripId: data['tripId'],
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      items: (data['items'] as List)
          .map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      category: data['category'],
      isTemplate: data['isTemplate'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'description': description,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'category': category,
      'isTemplate': isTemplate,
      'metadata': metadata,
    };
  }

  int get totalItems => items.length;
  int get completedItems => items.where((item) => item.isCompleted).length;
  double get completionPercentage =>
      totalItems > 0 ? (completedItems / totalItems) * 100 : 0;

  List<ChecklistItem> getItemsByPriority(String priority) {
    return items.where((item) => item.priority == priority).toList();
  }

  List<ChecklistItem> getItemsByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  Checklist copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? title,
    String? description,
    List<ChecklistItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    bool? isTemplate,
    Map<String, dynamic>? metadata,
  }) {
    return Checklist(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? List<ChecklistItem>.from(this.items),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isTemplate: isTemplate ?? this.isTemplate,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String priority; // 'high', 'medium', 'low'
  final String category;
  final DateTime? dueDate;
  final String? assignedTo;
  final Map<String, dynamic>? metadata;

  ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    required this.category,
    this.dueDate,
    this.assignedTo,
    this.metadata,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      priority: map['priority'],
      category: map['category'],
      dueDate:
          map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      assignedTo: map['assignedTo'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'assignedTo': assignedTo,
      'metadata': metadata,
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    String? category,
    DateTime? dueDate,
    String? assignedTo,
    Map<String, dynamic>? metadata,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      metadata: metadata ?? this.metadata,
    );
  }
}

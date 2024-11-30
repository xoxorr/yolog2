import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final List<String> participants;
  final Map<String, dynamic> schedule;
  final String status; // 'planned', 'ongoing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  Trip({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.destination,
    required this.participants,
    required this.schedule,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      destination: data['destination'],
      participants: List<String>.from(data['participants']),
      schedule: Map<String, dynamic>.from(data['schedule']),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'destination': destination,
      'participants': participants,
      'schedule': schedule,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    List<String>? participants,
    Map<String, dynamic>? schedule,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      participants: participants ?? List<String>.from(this.participants),
      schedule: schedule ?? Map<String, dynamic>.from(this.schedule),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  int getDuration() {
    return endDate.difference(startDate).inDays + 1;
  }

  bool isUpcoming() {
    final now = DateTime.now();
    return startDate.isAfter(now);
  }

  bool isOngoing() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool isCompleted() {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  List<DateTime> getDates() {
    final dates = <DateTime>[];
    var currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dates;
  }

  Map<DateTime, List<dynamic>> getScheduleByDate() {
    final scheduleByDate = <DateTime, List<dynamic>>{};
    getDates().forEach((date) {
      final key = date.toString().split(' ')[0];
      scheduleByDate[date] = schedule[key] ?? [];
    });
    return scheduleByDate;
  }
}

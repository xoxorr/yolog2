import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum NotificationType {
  all,
  mentions,
  follows,
  likes,
  comments,
  none,
}

enum PrivacyLevel {
  public,
  followersOnly,
  private,
}

class UserSettingsModel {
  final String uid;
  final bool isDarkMode;
  final String language;
  final NotificationType notificationType;
  final PrivacyLevel privacyLevel;
  final bool emailNotifications;
  final bool pushNotifications;
  final Map<String, bool> contentPreferences;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.uid,
    this.isDarkMode = false,
    this.language = 'ko',
    this.notificationType = NotificationType.all,
    this.privacyLevel = PrivacyLevel.public,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.contentPreferences = const {},
    required this.updatedAt,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory UserSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSettingsModel(
      uid: doc.id,
      isDarkMode: data['isDarkMode'] ?? false,
      language: data['language'] ?? 'ko',
      notificationType: NotificationType.values.firstWhere(
        (e) =>
            e.toString() ==
            'NotificationType.${data['notificationType'] ?? 'all'}',
        orElse: () => NotificationType.all,
      ),
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) =>
            e.toString() == 'PrivacyLevel.${data['privacyLevel'] ?? 'public'}',
        orElse: () => PrivacyLevel.public,
      ),
      emailNotifications: data['emailNotifications'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
      contentPreferences:
          Map<String, bool>.from(data['contentPreferences'] ?? {}),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'isDarkMode': isDarkMode,
      'language': language,
      'notificationType': notificationType.toString().split('.').last,
      'privacyLevel': privacyLevel.toString().split('.').last,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'contentPreferences': contentPreferences,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserSettingsModel copyWith({
    String? uid,
    bool? isDarkMode,
    String? language,
    NotificationType? notificationType,
    PrivacyLevel? privacyLevel,
    bool? emailNotifications,
    bool? pushNotifications,
    Map<String, bool>? contentPreferences,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      uid: uid ?? this.uid,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationType: notificationType ?? this.notificationType,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      contentPreferences: contentPreferences ?? this.contentPreferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettingsModel &&
        other.uid == uid &&
        other.isDarkMode == isDarkMode &&
        other.language == language &&
        other.notificationType == notificationType &&
        other.privacyLevel == privacyLevel &&
        other.emailNotifications == emailNotifications &&
        other.pushNotifications == pushNotifications &&
        mapEquals(other.contentPreferences, contentPreferences) &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      isDarkMode,
      language,
      notificationType,
      privacyLevel,
      emailNotifications,
      pushNotifications,
      Object.hashAll(contentPreferences.entries),
      updatedAt,
    );
  }
}

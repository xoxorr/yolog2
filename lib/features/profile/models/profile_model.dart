import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String uid;
  final String? displayName;
  final String? photoURL;
  final String? bio;
  final String email;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool emailVerified;

  ProfileModel({
    required this.uid,
    this.displayName,
    this.photoURL,
    this.bio,
    required this.email,
    this.preferences,
    required this.createdAt,
    this.lastLogin,
    required this.emailVerified,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      bio: map['bio'],
      email: map['email'] ?? '',
      preferences: map['preferences'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'email': email,
      'preferences': preferences,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'emailVerified': emailVerified,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool isVerified;
  /// Role: 'user' | 'komiko' | 'premium'
  final String role;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    this.email,
    this.username,
    this.bio,
    this.avatarUrl,
    this.createdAt,
    this.isVerified = false,
    this.role = 'user',
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      username: data['username'] as String?,
      bio: data['bio'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isVerified: data['isVerified'] as bool? ?? false,
      role: data['role'] as String? ?? 'user',
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isVerified': isVerified,
      'role': role,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isVerified,
    String? role,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

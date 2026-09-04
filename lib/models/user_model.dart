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

  // ── v1.1.0 fields ─────────────────────────────────────────────────────────
  /// Whether the user has an active Pro subscription.
  final bool isPro;

  /// When the Pro subscription expires (null = no subscription ever).
  final DateTime? proExpiry;

  /// Restricted users cannot post or comment (soft ban by admin).
  final bool isRestricted;

  /// Fully banned users cannot log in or interact.
  final bool isBanned;

  /// Reason provided by admin when banning.
  final String? banReason;

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
    this.isPro = false,
    this.proExpiry,
    this.isRestricted = false,
    this.isBanned = false,
    this.banReason,
  });

  /// True if user is the official Komiko contact email.
  bool get isOfficialContact =>
      email?.trim().toLowerCase() == 'contact@komiko.app';

  /// True if user has verified status (including active Pro subscribers, contact@komiko.app and admin).
  bool get effectiveIsVerified =>
      isVerified || hasActivePro || isOfficialContact || role == 'komiko';

  /// True if user has an active (non-expired) Pro subscription or is verified.
  bool get hasActivePro {
    if (isOfficialContact || role == 'komiko') return true;
    if (isVerified) return true;
    if (!isPro) return false;
    if (proExpiry == null) return true; // Manually granted without expiry
    return proExpiry!.isAfter(DateTime.now());
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final rawEmail = data['email'] as String?;
    final isContact = rawEmail?.trim().toLowerCase() == 'contact@komiko.app';

    final rawIsPro = isContact || (data['isPro'] as bool? ?? false);
    final rawExpiry = (data['proExpiry'] as Timestamp?)?.toDate();
    final hasActivePro = rawIsPro && (rawExpiry == null || rawExpiry.isAfter(DateTime.now()));
    final isVerified = isContact || (data['isVerified'] as bool? ?? false) || hasActivePro;

    return UserModel(
      uid: doc.id,
      email: rawEmail,
      username: isContact
          ? (data['username'] as String? ?? 'Komiko Officiel')
          : data['username'] as String?,
      bio: data['bio'] as String?,
      avatarUrl: isContact
          ? (data['avatarUrl'] as String? ?? 'asset:assets/images/Komiko.webp')
          : data['avatarUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isVerified: isVerified,
      role: isContact ? 'komiko' : (data['role'] as String? ?? 'user'),
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      isPro: rawIsPro,
      proExpiry: rawExpiry,
      isRestricted: data['isRestricted'] as bool? ?? false,
      isBanned: data['isBanned'] as bool? ?? false,
      banReason: data['banReason'] as String?,
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
      'isPro': isPro,
      'proExpiry': proExpiry != null ? Timestamp.fromDate(proExpiry!) : null,
      'isRestricted': isRestricted,
      'isBanned': isBanned,
      'banReason': banReason,
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
    bool? isPro,
    DateTime? proExpiry,
    bool? isRestricted,
    bool? isBanned,
    String? banReason,
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
      isPro: isPro ?? this.isPro,
      proExpiry: proExpiry ?? this.proExpiry,
      isRestricted: isRestricted ?? this.isRestricted,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
    );
  }
}

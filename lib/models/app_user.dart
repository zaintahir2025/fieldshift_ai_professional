import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Represents an authenticated user in the FieldShift AI agricultural platform.
class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String farmName;
  final bool isAnonymous;
  final String role;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.farmName = 'My Resilient Farm',
    this.isAnonymous = false,
    this.role = 'Farmer & Land Steward',
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// Factory constructor to map from a Firebase [fb.User]
  factory AppUser.fromFirebaseUser(
    fb.User user, {
    String? farmName,
    String? role,
  }) {
    final now = DateTime.now();
    return AppUser(
      uid: user.uid,
      email: user.email ?? (user.isAnonymous ? 'guest@fieldshift.earth' : ''),
      displayName: user.displayName ?? (user.isAnonymous ? 'Field Guest Explorer' : 'Farmer Steward'),
      farmName: farmName ?? 'My Resilient Farm',
      isAnonymous: user.isAnonymous,
      role: role ?? (user.isAnonymous ? 'Guest Explorer' : 'Farmer & Land Steward'),
      createdAt: user.metadata.creationTime ?? now,
      lastLoginAt: user.metadata.lastSignInTime ?? now,
    );
  }

  /// Create a guest user for immediate offline or demo access
  factory AppUser.guest() {
    final now = DateTime.now();
    return AppUser(
      uid: 'guest_${now.millisecondsSinceEpoch}',
      email: 'guest@fieldshift.earth',
      displayName: 'Field Guest Explorer',
      farmName: 'Demo Agricultural Basin',
      isAnonymous: true,
      role: 'Guest Explorer',
      createdAt: now,
      lastLoginAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'farmName': farmName,
      'isAnonymous': isAnonymous,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Farmer Steward',
      farmName: map['farmName'] as String? ?? 'My Resilient Farm',
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      role: map['role'] as String? ?? 'Farmer & Land Steward',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt'] as String) : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? displayName,
    String? farmName,
    String? role,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      farmName: farmName ?? this.farmName,
      isAnonymous: isAnonymous,
      role: role ?? this.role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? department;
  final bool isActive;
  final bool mfaEnabled;
  final String? authProvider;
  final DateTime? lastLogin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.department,
    required this.isActive,
    required this.mfaEnabled,
    this.authProvider,
    this.lastLogin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      fullName: json['fullName'],
      department: json['department'],
      isActive: json['isActive'] ?? true,
      mfaEnabled: json['mfaEnabled'] ?? false,
      authProvider: json['authProvider'],
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'fullName': fullName,
      'department': department,
      'isActive': isActive,
      'mfaEnabled': mfaEnabled,
      'authProvider': authProvider,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? username,
    String? email,
    String? fullName,
    String? department,
    bool? isActive,
    bool? mfaEnabled,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      authProvider: authProvider,
      lastLogin: lastLogin,
      createdAt: createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager' || isAdmin;
}
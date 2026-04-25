class UserProfile {
  final String id;
  final String email;
  final List<String> roles;

  const UserProfile({
    required this.id,
    required this.email,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }
}

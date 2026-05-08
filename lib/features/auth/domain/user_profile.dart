class UserProfile {
  final String id;
  final String email;
  final List<String> roles;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.roles,
    this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
      photoUrl: json['photo_url'] as String?,
    );
  }
}

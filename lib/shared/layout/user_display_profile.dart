class UserDisplayProfile {
  const UserDisplayProfile({required this.email, this.avatarUrl});

  final String email;
  final String? avatarUrl;
  

  String get initial => email.isNotEmpty ? email[0].toUpperCase() : '?';
}

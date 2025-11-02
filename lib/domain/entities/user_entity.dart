class UserEntity {
  final String uid;
  String? username;
  final String? email;
  final String? photoUrl;

  UserEntity({
    required this.uid,
    this.username,
    this.email,
    this.photoUrl,
  });
}

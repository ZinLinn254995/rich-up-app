class UserEntity {
  final String uid;
  String? username;
  final String? email;
  final String? photoURL;

  UserEntity({
    required this.uid,
    this.username,
    this.email,
    this.photoURL,
  });
}

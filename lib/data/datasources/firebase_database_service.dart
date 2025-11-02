import 'package:firebase_database/firebase_database.dart';
import 'package:rich_up/domain/entities/user_entity.dart';

class FirebaseDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> saveUserData(UserEntity user) async {
    await _db.child('users/${user.uid}').set({
      'username': user.username,
      'email': user.email,
      'photoUrl': user.photoUrl,
    });
  }

  Future<UserEntity?> getUserData(String uid) async {
    final snapshot = await _db.child('users/$uid').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return UserEntity(
        uid: uid,
        username: data['username'],
        email: data['email'],
        photoUrl: data['photoUrl'],
      );
    }
    return null;
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:rich_up/domain/entities/user_entity.dart';

class FirebaseDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> saveUserData(UserEntity user) async {
    try {
      await _db.child('users/${user.uid}').set({
        'uid': user.uid,
        'username': user.username,
        'email': user.email,
        'photoURL': user.photoURL,
      });
      print("✅ User data saved to Firebase: ${user.uid}");
    } catch (e) {
      print("❌ Error saving user data: $e");
      rethrow;
    }
  }

  Future<UserEntity?> getUserData(String uid) async {
    try {
      final snapshot = await _db.child('users/$uid').get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        print("✅ User data retrieved: $data");
        
        return UserEntity(
          uid: data['uid'] ?? uid,
          username: data['username'],
          email: data['email'],
          photoURL: data['photoURL'],
        );
      }
      print("ℹ️ No user data found for: $uid");
      return null;
    } catch (e) {
      print("❌ Error getting user data: $e");
      return null;
    }
  }
}
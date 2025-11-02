import 'package:rich_up/data/repositories/firebase_auth_repository.dart';
import 'package:rich_up/domain/entities/user_entity.dart';

class SignInWithGoogleUseCase {
  final FirebaseAuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> execute() async {
    try {
      final user = await repository.signInWithGoogle();
      if (user == null) return null;

      print("✅ Google Sign-In Success - Creating UserEntity");
      
      // 🆕 Simple user creation without complex logic
      return UserEntity(
        uid: user.uid,
        username: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
      );
    } catch (e) {
      print("❌ SignInWithGoogleUseCase Error: $e");
      return null; // 🆕 Return null instead of rethrowing
    }
  }
}
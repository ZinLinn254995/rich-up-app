import 'package:rich_up/data/repositories/firebase_auth_repository.dart';
import 'package:rich_up/domain/entities/user_entity.dart';

class SignInWithGoogleUseCase {
  final FirebaseAuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<UserEntity?> execute() async {
    final user = await repository.signInWithGoogle();
    if (user == null) return null;

    return UserEntity(
      uid: user.uid,
      username: null,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}

import 'package:rich_up/data/repositories/firebase_auth_repository.dart';

class SignOutUseCase {
  final FirebaseAuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> execute() async {
    await repository.signOut();
  }
}

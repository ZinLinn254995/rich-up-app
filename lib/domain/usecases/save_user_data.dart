import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/domain/repositories/user_repository.dart';

class SaveUserDataUseCase {
  final UserRepository repository;

  SaveUserDataUseCase(this.repository);

  Future<void> execute(UserEntity user) async {
    await repository.saveUser(user);
  }
}

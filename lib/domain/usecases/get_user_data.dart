import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/domain/repositories/user_repository.dart';

class GetUserDataUseCase {
  final UserRepository repository;

  GetUserDataUseCase(this.repository);

  Future<UserEntity?> execute(String uid) async {
    return await repository.getUser(uid);
  }
}

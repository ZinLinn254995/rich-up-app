import 'package:rich_up/data/datasources/firebase_database_service.dart';
import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseDatabaseService databaseService;

  UserRepositoryImpl(this.databaseService);

  @override
  Future<void> saveUser(UserEntity user) async {
    await databaseService.saveUserData(user);
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    return await databaseService.getUserData(uid);
  }
}

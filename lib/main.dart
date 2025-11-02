import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/firebase_options.dart';
import 'package:rich_up/core/wrappers/authentication_wrapper.dart';
import 'package:rich_up/core/wrappers/internet_check_wrapper.dart';
import 'package:rich_up/data/repositories/firebase_auth_repository.dart';
import 'package:rich_up/data/datasources/firebase_database_service.dart';
import 'package:rich_up/data/repositories/user_repository_impl.dart';
import 'package:rich_up/domain/usecases/sign_in_with_google.dart'; // ✅ Import again
import 'package:rich_up/domain/usecases/sign_out.dart';
import 'package:rich_up/domain/usecases/save_user_data.dart';
import 'package:rich_up/domain/usecases/get_user_data.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepo = FirebaseAuthRepository();
  final dbService = FirebaseDatabaseService();
  final userRepo = UserRepositoryImpl(dbService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            signInUseCase: SignInWithGoogleUseCase(authRepo), // ✅ Add back
            signOutUseCase: SignOutUseCase(authRepo),
            saveUserDataUseCase: SaveUserDataUseCase(userRepo),
            getUserDataUseCase: GetUserDataUseCase(userRepo),
          ),
        ),
      ],
      child: const MyAppRoot(),
    ),
  );
}

class MyAppRoot extends StatelessWidget {
  const MyAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rich Up App',
      home: InternetCheckWrapper(
        initialCheckDelay: const Duration(milliseconds: 800), 
        retryDelay: const Duration(seconds: 1),
        child: const AuthenticationWrapper(),
      ),
    );
  }
}
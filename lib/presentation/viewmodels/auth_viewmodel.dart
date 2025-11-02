import 'package:flutter/material.dart';
import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/domain/usecases/sign_in_with_google.dart';
import 'package:rich_up/domain/usecases/sign_out.dart';
import 'package:rich_up/domain/usecases/save_user_data.dart';
import 'package:rich_up/domain/usecases/get_user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithGoogleUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final SaveUserDataUseCase saveUserDataUseCase;
  final GetUserDataUseCase getUserDataUseCase;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool isLoading = false;
  bool _isSigningOut = false; // 🆕 Sign Out Loading အတွက်
  bool get isSigningOut => _isSigningOut;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthViewModel({
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.saveUserDataUseCase,
    required this.getUserDataUseCase,
  });

  Future<void> initializeUser(String? uid) async {
    isLoading = true;

    if (uid == null) {
      _currentUser = null;
    } else {
      final existingUser = await getUserDataUseCase.execute(uid);

      if (existingUser != null) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final updatedAuthUser = UserEntity(
            uid: firebaseUser.uid,
            username: existingUser.username,
            email: firebaseUser.email,
            photoUrl: firebaseUser.photoURL,
          );
          _currentUser = updatedAuthUser;
        } else {
          _currentUser = existingUser;
        }
      } else {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          _currentUser = UserEntity(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            photoUrl: firebaseUser.photoURL,
          );
        } else {
          _currentUser = null;
        }
      }
    }

    _isInitialized = true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isSigningOut = true; // 🆕 Loading စပြမယ်
    notifyListeners();
    
    try {
      await signOutUseCase.execute();
      _currentUser = null;
      _isInitialized = false;
    } catch (e) {
      print("Sign-out failed: $e");
    } finally {
      _isSigningOut = false; // 🆕 Loading ရပ်မယ်
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    isLoading = true;
    notifyListeners();

    try {
      final firebaseUserFromAuth = await signInUseCase.execute();

      if (firebaseUserFromAuth != null) {
        UserEntity newUser = UserEntity(
          uid: firebaseUserFromAuth.uid,
          email: firebaseUserFromAuth.email,
          photoUrl: firebaseUserFromAuth.photoUrl,
        );

        final existingUser = await getUserDataUseCase.execute(newUser.uid);

        if (existingUser != null) {
          newUser = UserEntity(
            uid: newUser.uid,
            username: existingUser.username,
            email: newUser.email,
            photoUrl: newUser.photoUrl,
          );
          await saveUserDataUseCase.execute(newUser);
        } else {
          await saveUserDataUseCase.execute(newUser);
        }

        _currentUser = newUser;
      }
    } catch (e) {
      print("Sign-in failed: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserData(UserEntity updatedUser) async {
    await saveUserDataUseCase.execute(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/domain/usecases/sign_in_with_google.dart';
import 'package:rich_up/domain/usecases/sign_out.dart';
import 'package:rich_up/domain/usecases/save_user_data.dart';
import 'package:rich_up/domain/usecases/get_user_data.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInWithGoogleUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final SaveUserDataUseCase saveUserDataUseCase;
  final GetUserDataUseCase getUserDataUseCase;

  UserEntity? _currentUser;
  
  // 🆕 Emergency fallback getter
  UserEntity? get currentUser {
    if (_currentUser == null && _isInitialized) {
      // If ViewModel has no user but Firebase has, create one
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        print("🆘 Emergency: Creating user from Firebase in getter");
        _currentUser = UserEntity(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName,
          email: firebaseUser.email,
          photoURL: firebaseUser.photoURL,
        );
      }
    }
    return _currentUser;
  }

  bool isLoading = false;
  bool _isSigningOut = false;
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
    if (_isInitialized) {
      print("🟡 Already initialized, skipping...");
      return;
    }
    
    print("🔥 Initializing user with UID: $uid");

    // 🆕 Always check Firebase auth state first
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    print("🔥 Current Firebase User: ${currentFirebaseUser?.uid}");

    if (uid == null || currentFirebaseUser == null) {
      _currentUser = null;
      _isInitialized = true;
      notifyListeners();
      print("✅ No user - Initialization completed");
      return;
    }

    try {
      // 🆕 Try to get existing user data
      final existingUser = await getUserDataUseCase.execute(uid);
      
      if (existingUser != null) {
        _currentUser = UserEntity(
          uid: currentFirebaseUser.uid,
          username: existingUser.username,
          email: currentFirebaseUser.email,
          photoURL: currentFirebaseUser.photoURL,
        );
        print("✅ User initialized from database");
      } else {
        // 🆕 Create new user from Firebase
        _currentUser = UserEntity(
          uid: currentFirebaseUser.uid,
          username: currentFirebaseUser.displayName,
          email: currentFirebaseUser.email,
          photoURL: currentFirebaseUser.photoURL,
        );
        print("✅ User initialized from Firebase (new user)");
        
        // 🆕 Save this new user to database
        try {
          await saveUserDataUseCase.execute(_currentUser!);
          print("✅ New user saved to database");
        } catch (e) {
          print("⚠️ Failed to save new user: $e");
        }
      }
    } catch (e) {
      print("⚠️ Error initializing user: $e");
      // 🆕 Fallback: create from Firebase
      _currentUser = UserEntity(
        uid: currentFirebaseUser.uid,
        username: currentFirebaseUser.displayName,
        email: currentFirebaseUser.email,
        photoURL: currentFirebaseUser.photoURL,
      );
      print("✅ User initialized from Firebase (fallback)");
    }

    _isInitialized = true;
    notifyListeners();
    print("✅ User initialization completed: ${_currentUser != null}");
  }

  Future<void> signOut() async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await signOutUseCase.execute();
      _currentUser = null;
      _isInitialized = false;
      print("✅ Sign-out successful");
    } catch (e) {
      print("❌ Sign-out failed: $e");
    } finally {
      _isSigningOut = false;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    isLoading = true;
    notifyListeners();

    try {
      print("🟡 Starting sign-in process...");
      
      // 🆕 Bypass potential PigeonUserDetails error with direct approach
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      
      // Force sign out first to clear any state
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      print("🟡 Starting Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("🔴 Google Sign-In cancelled");
        isLoading = false;
        notifyListeners();
        return;
      }

      print("🟡 Google user obtained: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🟡 Signing in with Firebase...");
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        print("✅ Firebase Sign-In successful: ${firebaseUser.email}");
        
        // 🆕 Create user entity directly from Firebase user
        UserEntity newUser = UserEntity(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName,
          email: firebaseUser.email,
          photoURL: firebaseUser.photoURL,
        );

        // 🆕 Try to get existing user data (but don't block on errors)
        try {
          final existingUser = await getUserDataUseCase.execute(newUser.uid);
          if (existingUser != null && existingUser.username != null) {
            newUser = UserEntity(
              uid: newUser.uid,
              username: existingUser.username,
              email: newUser.email,
              photoURL: newUser.photoURL,
            );
            print("✅ Merged with existing user data");
          }
        } catch (e) {
          print("⚠️ Error checking existing user: $e");
        }

        // 🆕 Save to database (but don't block on errors)
        try {
          await saveUserDataUseCase.execute(newUser);
          print("✅ User data saved to database");
        } catch (e) {
          print("⚠️ User data save error (but continuing): $e");
        }

        // 🆕 CRITICAL: Set user directly and mark as initialized
        _currentUser = newUser;
        _isInitialized = true;
        
        print("✅ User set in ViewModel: ${_currentUser?.uid}");
        print("✅ AuthViewModel isInitialized: $_isInitialized");
        print("✅ User details - Email: ${_currentUser?.email}, Username: ${_currentUser?.username}");
      }
    } catch (e) {
      print("❌ Sign-in failed: $e");
      
      // 🆕 Even if there's an error, check if we're actually logged in
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser != null) {
        print("🟡 Firebase says we're logged in, creating user from Firebase...");
        _currentUser = UserEntity(
          uid: currentFirebaseUser.uid,
          username: currentFirebaseUser.displayName,
          email: currentFirebaseUser.email,
          photoURL: currentFirebaseUser.photoURL,
        );
        _isInitialized = true;
        print("✅ Recovered from error - User set: ${_currentUser?.uid}");
        
        // 🆕 Try to save this recovered user
        try {
          await saveUserDataUseCase.execute(_currentUser!);
          print("✅ Recovered user saved to database");
        } catch (e) {
          print("⚠️ Failed to save recovered user: $e");
        }
      }
    }

    isLoading = false;
    notifyListeners();
    print("🟡 Sign-in process completed");
  }

  Future<void> saveUserData(UserEntity updatedUser) async {
    try {
      await saveUserDataUseCase.execute(updatedUser);
      _currentUser = updatedUser;
      print("✅ User data updated in ViewModel");
      notifyListeners();
    } catch (e) {
      print("❌ Error saving user data: $e");
      rethrow;
    }
  }

  // 🆕 Utility method to check authentication status
  bool get isLoggedIn {
    final hasViewModelUser = _currentUser != null;
    final hasFirebaseUser = FirebaseAuth.instance.currentUser != null;
    
    print("🔍 Auth Status - ViewModel: $hasViewModelUser, Firebase: $hasFirebaseUser");
    
    return hasViewModelUser && hasFirebaseUser;
  }

  // 🆕 Force refresh user data from Firebase
  Future<void> refreshUser() async {
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser != null && _currentUser != null) {
      _currentUser = UserEntity(
        uid: currentFirebaseUser.uid,
        username: _currentUser!.username ?? currentFirebaseUser.displayName,
        email: currentFirebaseUser.email,
        photoURL: currentFirebaseUser.photoURL,
      );
      notifyListeners();
      print("✅ User data refreshed from Firebase");
    }
  }
}
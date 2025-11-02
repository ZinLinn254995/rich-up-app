import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/presentation/main_app_content.dart';
import 'package:rich_up/presentation/screens/auth/login_screen.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  int _buildCount = 0; // 🆕 Track build count
  
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final authViewModel = context.watch<AuthViewModel>();

    // 🆕 Limit debug output to prevent spam
    if (_buildCount <= 10) {
      print("=== AUTH WRAPPER BUILD #$_buildCount ===");
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🆕 Only print important state changes
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_buildCount <= 5) {
            print("🟡 Auth stream waiting...");
          }
          return const CustomCircularProgressIndicator(
            message: "Checking authentication...",
          );
        }

        final User? firebaseUser = snapshot.data;

        if (!authViewModel.isInitialized) {
          if (_buildCount <= 5) {
            print("🟡 Initializing user data...");
          }
          
          // 🆕 Use delayed to prevent rapid microtask rebuilds
          Future.delayed(Duration.zero, () {
            if (!authViewModel.isInitialized && mounted) {
              authViewModel.initializeUser(firebaseUser?.uid);
            }
          });

          return const CustomCircularProgressIndicator(
            message: "Initializing user data...",
          );
        }

        final bool isUserLoggedIn = authViewModel.currentUser != null;

        // 🆕 Only print final decision
        if (_buildCount <= 5) {
          print("✅ Final Decision - Logged in: $isUserLoggedIn");
        }

        if (!isUserLoggedIn) {
          return const LoginScreen();
        } else {
          return const MainAppContent();
        }
      },
    );
  }
} 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/presentation/main_app_content.dart';
import 'package:rich_up/presentation/screens/auth/login_screen.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomCircularProgressIndicator();
        }

        final User? firebaseUser = snapshot.data;

        if (!authViewModel.isInitialized) {
          Future.microtask(() {
            if (!authViewModel.isInitialized) {
              authViewModel.initializeUser(firebaseUser?.uid);
            }
          });

          return const CustomCircularProgressIndicator(
            message: "Initializing user data...",
          );
        }

        if (authViewModel.currentUser == null) {
          return const LoginScreen();
        } else {
          return const MainAppContent();
        }
      },
    );
  }
}

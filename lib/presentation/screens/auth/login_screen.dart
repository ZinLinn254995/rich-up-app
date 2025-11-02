import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _buildCount = 0;
  
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    final viewModel = context.watch<AuthViewModel>();

    // 🆕 Limit debug output
    if (_buildCount <= 3) {
      print("🟡 LoginScreen build #$_buildCount - isLoading: ${viewModel.isLoading}");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: viewModel.isLoading
            ? const CustomCircularProgressIndicator(
                message: "Signing in...",
              )
            : ElevatedButton.icon(
                icon: Image.asset('assets/google_logo.png', height: 24),
                label: const Text("Sign in with Google"),
                onPressed: () {
                  print("🟡 Google Sign-In button pressed");
                  viewModel.signIn();
                },
              ),
      ),
    );
  }
}
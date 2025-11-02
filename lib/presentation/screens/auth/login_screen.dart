import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: viewModel.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomCircularProgressIndicator(
                    size: 20,
                    strokeWidth: 2,
                    center: false,
                  ),
                )
              : Image.asset('assets/google_logo.png', height: 24),
          label: viewModel.isLoading
              ? const Text("Signing in...")
              : const Text("Sign in with Google"),
          onPressed: viewModel.isLoading ? null : () => viewModel.signIn(),
        ),
      ),
    );
  }
}
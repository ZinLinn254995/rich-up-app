import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rich_up/domain/entities/user_entity.dart';
import 'package:rich_up/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';

// Global key for ScaffoldMessenger (main.dart တွင် MaterialApp အောက်တွင် သုံးရပါမည်)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // 🖼️ ပရိုဖိုင်ပုံကို ClipOval နှင့် BoxFit.cover ဖြင့် ပိုမို fit ဖြစ်အောင် ပြင်ဆင်ထားသည့် Function
  Widget _buildProfileAvatar(UserEntity user) {
    final hasPhotoUrl = user.photoURL != null && user.photoURL!.isNotEmpty;
    const double radius = 40; // ဓာတ်ပုံရဲ့ radius

    if (hasPhotoUrl) {
      // 💡 ပုံ URL ရှိရင် ClipOval ကို သုံးပြီး Image.network ကို BoxFit.cover ဖြင့် သုံးသည်
      return ClipOval(
        child: Image.network(
          user.photoURL!,
          width: radius * 2, // 80.0
          height: radius * 2, // 80.0
          fit: BoxFit.cover, // 🛑 ပုံကို circle ထဲမှာ လုံးဝဖုံးအုပ်ပြီး crop လုပ်ပေးသည်
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // ပုံ load နေစဉ် Loading Indicator ပြ
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey[200],
              child: const CustomCircularProgressIndicator(
                size: 20,
                strokeWidth: 2,
                center: false,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // ပုံ Loading error တက်ရင် default Icon ပြရန်
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off,
                size: 40,
                color: Colors.white,
              ),
            );
          },
        ),
      );
    } else {
      // ပုံမရှိသည့်အခါ CircleAvatar ကို Default Icon ဖြင့် ပြသည်
      return const CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthViewModel ကို စောင့်ကြည့်သည်
    final viewModel = context.watch<AuthViewModel>();
    final user = viewModel.currentUser;

    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    // Set controller text only when not editing to prevent cursor jumping
    // ViewModel state ပြောင်းလဲတိုင်း Controller text ကို update လုပ်သည်
    if (!_isEditing) {
      _usernameController.text = user.username ?? "";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🛑 ပြင်ဆင်ချက်: Column ၏ stretch ဖြစ်မှုကို ရှောင်ရှားရန် Center ဖြင့် ထုပ်ပိုးခြင်း
            Center(child: _buildProfileAvatar(user)),

            const SizedBox(height: 12),
            _isEditing
                ? TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Enter username",
                    ),
                  )
                : Center(
                    child: Text(
                      user.username ?? "No username set",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
            Center(
              child: Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 30),

            // 📝 Username Set/Edit Button
            if (!(_isEditing) &&
                (user.username == null || user.username!.isEmpty))
              ElevatedButton(
                onPressed: () {
                  setState(() => _isEditing = true);
                },
                child: const Text("Set Username"),
              ),

            if (_isEditing)
              _isSaving
                  ? const CustomCircularProgressIndicator(
                      message: "Saving username...",
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (_usernameController.text.trim().isEmpty) {
                          // GlobalKey ကို သုံး၍ SnackBar ပြသည်
                          scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text("Username cannot be empty."),
                            ),
                          );
                          return;
                        }

                        setState(() => _isSaving = true);

                        // 1. UserEntity အသစ်တစ်ခုကို Username အသစ်ဖြင့် ဖန်တီးသည်
                        final updatedUser = UserEntity(
                          uid: user.uid,
                          username: _usernameController.text.trim(),
                          email: user.email,
                          photoURL: user.photoURL,
                        );

                        // 2. AuthViewModel မှတစ်ဆင့် save လုပ်ပြီး state ကို update လုပ်ပါ
                        await viewModel.saveUserData(updatedUser);

                        if (!mounted) return;

                        setState(() {
                          _isEditing = false;
                          _isSaving = false;
                        });

                        // GlobalKey ကို သုံး၍ SnackBar ပြသည်
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(content: Text("Username saved!")),
                        );
                      },
                      child: const Text("Save Username"),
                    ),

            const SizedBox(height: 20),

            // 🚪 Sign Out Button (ပြင်ဆင်ပြီး)
            ElevatedButton.icon(
              onPressed: viewModel.isSigningOut ? null : viewModel.signOut, // ✅ isSigningOut သုံးထားတယ်
              icon: viewModel.isSigningOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CustomCircularProgressIndicator(
                        size: 16,
                        strokeWidth: 2,
                        center: false,
                      ),
                    )
                  : const Icon(Icons.logout),
              label: viewModel.isSigningOut
                  ? const Text("Signing Out...")
                  : const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
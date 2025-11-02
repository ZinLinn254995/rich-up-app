import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rich_up/presentation/widgets/custom_alert_dialog.dart';
import 'package:rich_up/presentation/widgets/custom_circular_progress_indicator.dart';
import 'package:rich_up/core/services/internet_check_service.dart';
import 'package:flutter/services.dart';

class InternetCheckWrapper extends StatefulWidget {
  final Widget child;
  final Duration initialCheckDelay;
  final Duration retryDelay;

  const InternetCheckWrapper({
    super.key,
    required this.child,
    this.initialCheckDelay = const Duration(milliseconds: 500),
    this.retryDelay = const Duration(milliseconds: 1000),
  });

  @override
  State<InternetCheckWrapper> createState() => _InternetCheckWrapperState();
}

class _InternetCheckWrapperState extends State<InternetCheckWrapper> {
  final InternetCheckService _internetService = InternetCheckService();
  bool _isCheckingInternet = false;
  StreamSubscription<bool>? _internetSubscription;

  @override
  void initState() {
    super.initState();
    _delayedInitialCheck();
    _setupInternetListener();
  }

  @override
  void dispose() {
    _internetSubscription?.cancel();
    super.dispose();
  }

  // App စတိုင်းမှာ delay နဲ့ internet ရှိမရှိစစ်မယ်
  void _delayedInitialCheck() {
    Future.delayed(widget.initialCheckDelay, () {
      if (mounted) {
        _checkInitialInternet();
      }
    });
  }

  // Initial internet check
  Future<void> _checkInitialInternet() async {
    if (_isCheckingInternet) return;

    setState(() => _isCheckingInternet = true);

    // Add a small delay to show loading indicator
    await Future.delayed(const Duration(milliseconds: 300));

    final hasInternet = await _internetService.hasInternetConnection();

    if (!hasInternet && mounted) {
      await _showNoInternetDialog();
    }

    if (mounted) {
      setState(() => _isCheckingInternet = false);
    }
  }

  // Internet status change ကိုနားထောင်မယ်
  void _setupInternetListener() {
    _internetSubscription = _internetService.onInternetStatusChanged.listen((
      hasInternet,
    ) {
      if (mounted && !hasInternet) {
        // Delay before showing dialog when connection is lost
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showNoInternetDialog();
          }
        });
      }
    });
  }

  // No internet dialog ပြမယ်
  Future<void> _showNoInternetDialog() async {
    // Prevent multiple dialogs
    if (ModalRoute.of(context)?.isCurrent != true) return;

    await CustomAlertDialog.show(
      context: context,
      title: "No Internet Connection",
      description: "Please check your internet connection and try again.",
      buttons: [
        CustomAlertButton(
          text: "Exit App",
          buttonColor: Colors.red,
          onPressed: () {
            Navigator.pop(context); // Dialog ပိတ်မယ်
            _exitApp();
          },
        ),
        CustomAlertButton(
          text: "Try Again",
          isPrimary: true,
          onPressed: () {
            Navigator.pop(context); // Dialog ပိတ်မယ်
            _retryInternetCheck();
          },
        ),
      ],
      dismissible: false, // User က button နှိပ်မှပိတ်ရမယ်
    );
  }

  // App ထွက်မယ်
  void _exitApp() {
    Future.delayed(const Duration(milliseconds: 300), () {
      SystemNavigator.pop(); // ဒါပဲသုံးပါ (Better user experience)
    });
  }

  // Internet check ပြန်လုပ်မယ် (delay နဲ့)
  Future<void> _retryInternetCheck() async {
    if (_isCheckingInternet) return;

    setState(() => _isCheckingInternet = true);

    // Retry delay
    await Future.delayed(widget.retryDelay);

    final hasInternet = await _internetService.hasInternetConnection();

    if (mounted) {
      setState(() => _isCheckingInternet = false);

      if (!hasInternet) {
        // Small delay before showing dialog again
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await _showNoInternetDialog();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Internet check လုပ်နေချိန် loading ပြမယ်
    if (_isCheckingInternet) {
      return const Scaffold(
        body: CustomCircularProgressIndicator(
          message: "Checking internet connection...",
        ),
      );
    }

    return widget.child;
  }
}

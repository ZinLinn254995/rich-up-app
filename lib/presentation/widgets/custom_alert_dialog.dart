import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final List<CustomAlertButton>? buttons;
  final bool dismissible;

  const CustomAlertDialog({
    super.key,
    this.title,
    this.description,
    this.buttons,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            )
          : null,
      content: description != null
          ? Text(
              description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            )
          : null,
      actions: buttons != null && buttons!.isNotEmpty
          ? _buildButtons(context)
          : null,
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    return buttons!.map((button) {
      return TextButton(
        onPressed: button.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: button.buttonColor ?? Theme.of(context).primaryColor,
          textStyle: TextStyle(
            fontWeight: button.isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        child: Text(button.text),
      );
    }).toList();
  }

  // Show dialog method
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? description,
    List<CustomAlertButton>? buttons,
    bool dismissible = true,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => CustomAlertDialog(
        title: title,
        description: description,
        buttons: buttons,
        dismissible: dismissible,
      ),
    );
  }
}

class CustomAlertButton {
  final String text;
  final VoidCallback? onPressed;
  final Color? buttonColor;
  final bool isPrimary;

  const CustomAlertButton({
    required this.text,
    this.onPressed,
    this.buttonColor,
    this.isPrimary = false,
  });
}
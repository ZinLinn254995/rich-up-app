import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool center;
  final Color backgroundColor;

  const CustomCircularProgressIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
    this.center = true,
    this.backgroundColor = Colors.white, // ✅ Default white background
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Always use Scaffold to ensure proper background
    return Scaffold(
      backgroundColor: backgroundColor, // ✅ This prevents black screen
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final progressIndicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );

    // ✅ Build the content
    final Widget content = message == null
        ? Center(child: progressIndicator)
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              progressIndicator,
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87, // ✅ Ensure text is visible
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );

    // ✅ If center is false, just return content (but it will still be in Scaffold)
    return center ? Center(child: content) : content;
  }
}
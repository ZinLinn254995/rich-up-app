import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool center;

  const CustomCircularProgressIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
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

    // Message မပါရင် progress indicator ပဲ return ပြန်မယ်
    if (message == null) {
      return center ? Center(child: progressIndicator) : progressIndicator;
    }

    // Message ပါရင် column နဲ့အတူပြမယ်
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        progressIndicator,
        const SizedBox(height: 16),
        Text(
          message!,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );

    return center ? Center(child: content) : content;
  }
}
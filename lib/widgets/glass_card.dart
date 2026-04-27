import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (isCorrect) {
      backgroundColor = Colors.green.withValues(alpha: 0.3);
    } else if (isSelected) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.white.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withValues(alpha: 0.5)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }
}
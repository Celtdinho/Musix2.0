import 'package:flutter/material.dart';

class HealthBar extends StatelessWidget {
  final int health;
  final bool isEventActive;

  const HealthBar({
    super.key,
    required this.health,
    this.isEventActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: health / 100,
          backgroundColor: Colors.red.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            isEventActive ? Colors.orange : Colors.green,
          ),
          minHeight: 16,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;
  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1126E1), Color(0xFF47C5FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: Icon(Icons.cloud, size: 100, color: Colors.white.withOpacity(0.2)),
          ),
          Positioned(
            bottom: 40,
            left: 10,
            child: Icon(Icons.cloud, size: 80, color: Colors.white.withOpacity(0.15)),
          ),
          Positioned(
            top: 200,
            left: 30,
            child: Icon(Icons.music_note, size: 40, color: Colors.white.withOpacity(0.3)),
          ),
          Positioned(
            bottom: 150,
            right: 30,
            child: Icon(Icons.music_note, size: 50, color: Colors.white.withOpacity(0.25)),
          ),
          child,
        ],
      ),
    );
  }
}
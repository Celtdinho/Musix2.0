import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_background.dart';
import 'home_screen.dart';
import 'mode_selector_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String mode;
  final List<Map<String, dynamic>> answers;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.mode,
    required this.answers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    // Sembunyikan confetti setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.total > 0 ? (widget.score / (widget.total * 10)) * 100 : 0;
    final correctCount = widget.answers.where((a) => a['isCorrect'] == true).length;
    final wrongCount = widget.answers.length - correctCount;

    String message;
    if (percentage >= 80) {
      message = 'Excellent! You\'re a music master! 🎵';
    } else if (percentage >= 60) {
      message = 'Good job! Keep it up! 👍';
    } else if (percentage >= 40) {
      message = 'Not bad! Keep learning! 🎧';
    } else {
      message = 'Keep practicing! Music is infinite! 🌟';
    }

    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Konten utama
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kartu putih hasil (sama seperti sebelumnya)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFFA32EC1), size: 20),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${percentage.round()}%',
                                          style: const TextStyle(
                                            color: Color(0xFFA32EC1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text('Completion', style: TextStyle(color: Color(0xFF2B252C), fontSize: 16)),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${widget.score}',
                                      style: const TextStyle(
                                        color: Color(0xFFA32EC1),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Points', style: TextStyle(color: Color(0xFF2B252C), fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${widget.total}', style: const TextStyle(color: Color(0xFFA32EC1), fontSize: 20, fontWeight: FontWeight.bold)),
                                    const Text('Total Question', style: TextStyle(color: Color(0xFF2B252C), fontSize: 16)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                        const SizedBox(width: 4),
                                        Text('$correctCount', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Text('Correct', style: TextStyle(color: Color(0xFF2B252C), fontSize: 16)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.cancel, color: Colors.red, size: 16),
                                        const SizedBox(width: 4),
                                        Text('$wrongCount', style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const Text('Wrong', style: TextStyle(color: Color(0xFF2B252C), fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBEBFF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFF2B252C), fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.refresh,
                            label: 'Play Again',
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const ModeSelectorScreen()),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.analytics,
                            label: 'Review Answer',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur detail jawaban akan segera hadir')),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share Score',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur share akan segera hadir')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.picture_as_pdf,
                            label: 'Generate PDF',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur PDF akan segera hadir')),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.home,
                            label: 'Home',
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                    (route) => false,
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.emoji_events,
                            label: 'Leaderboard',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur leaderboard akan segera hadir')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Overlay Confetti
              if (_showConfetti)
                IgnorePointer(
                  child: Center(
                    child: Image.asset(
                      'assets/animations/Confetti.gif',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFA32EC1), size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF2B252C), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
// lib/screens/quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/custom_background.dart';
import '../widgets/health_bar.dart';
import '../widgets/timer_widget.dart';
import '../widgets/animated_button.dart';
import '../database/game_database.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class QuizScreen extends StatefulWidget {
  final String mode;
  final int stageId;
  const QuizScreen({super.key, required this.mode, required this.stageId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GameDatabase _db = GameDatabase();
  final QuizService _quizService = QuizService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _health = 100;
  int _hintsRemaining = 3;
  bool _isEventActive = false;
  String? _selectedAnswer;
  bool _isLoading = true;
  int _timeRemaining = 180; // mode time attack

  Timer? _questionTimer;
  int _timeLeftPerQuestion = 10;
  static const int _maxTimePerQuestion = 10;

  List<Map<String, dynamic>> _answersHistory = [];
  List<String> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final songs = await _db.getAllSongs();
    if (songs.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    // Jumlah soal tidak boleh lebih dari 2x jumlah lagu
    int numQuestions = 10;
    if (widget.mode == 'time_attack') {
      numQuestions = 10; // endless akan shuffle otomatis
    } else if (widget.mode == 'stage') {
      numQuestions = 10; // bisa disesuaikan
    }
    final maxAllowed = songs.length * 2;
    final targetCount = numQuestions > maxAllowed ? maxAllowed : numQuestions;

    final questions = await _quizService.generateQuizQuestions(songs, numberOfQuestions: targetCount);
    if (!mounted) return;

    setState(() {
      _questions = questions;
      _isLoading = false;
      if (widget.mode == 'time_attack') _timeRemaining = 180;
      _resetCurrentOptions();
      _startQuestionTimer();
      _playCurrentSong();
    });
  }

  void _resetCurrentOptions() {
    if (_questions.isNotEmpty && _currentIndex < _questions.length) {
      _currentOptions = List.from(_questions[_currentIndex].options);
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _timeLeftPerQuestion = _maxTimePerQuestion;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftPerQuestion <= 1) {
        timer.cancel();
        if (_selectedAnswer == null && mounted) {
          _handleTimeOut();
        }
      } else {
        setState(() {
          _timeLeftPerQuestion--;
        });
      }
    });
  }

  void _handleTimeOut() {
    if (_selectedAnswer != null) return;
    _submitAnswer(null, isTimeOut: true);
  }

  void _playCurrentSong() async {
    if (_questions.isEmpty) return;
    final songId = _questions[_currentIndex].songId;
    if (songId == null) return;
    final song = await _db.getSongById(songId);
    if (song != null && song.audioPath != null) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(song.audioPath!));
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool _isRandomEvent() => DateTime.now().millisecondsSinceEpoch % 5 == 0;

  int _getRandomMultiplier() {
    int rand = DateTime.now().millisecondsSinceEpoch % 10;
    if (rand < 1) return 10;
    if (rand < 3) return 5;
    return 2;
  }

  void _showEventNotification(int multiplier, bool isBonus) {
    String message = isBonus
        ? '✨ EVENT x$multiplier! Bonus poin! ✨'
        : '💥 EVENT x$multiplier! Damage meningkat! 💥';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _useHint() {
    if (_hintsRemaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hints left!')),
      );
      return;
    }

    final currentQ = _questions[_currentIndex];
    if (_currentOptions.length < currentQ.options.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hint already used for this question!')),
      );
      return;
    }

    List<String> wrongOptions = _currentOptions.where((opt) => opt != currentQ.correctAnswer).toList();
    if (wrongOptions.isEmpty) return;

    final random = DateTime.now().millisecondsSinceEpoch % wrongOptions.length;
    final toRemove = wrongOptions[random];

    setState(() {
      _currentOptions.remove(toRemove);
      _hintsRemaining--;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hint used! "$toRemove" removed.')),
    );
  }

  void _submitAnswer(String? answer, {bool isTimeOut = false}) async {
    if (_selectedAnswer != null) return;
    _questionTimer?.cancel();

    setState(() {
      _selectedAnswer = answer ?? '';
    });

    final currentQ = _questions[_currentIndex];
    final isCorrect = (answer != null && answer == currentQ.correctAnswer);
    final selectedText = answer ?? 'Waktu habis, tidak menjawab';

    _answersHistory.add({
      'questionText': currentQ.questionText,
      'selectedAnswer': selectedText,
      'correctAnswer': currentQ.correctAnswer,
      'isCorrect': isCorrect,
    });

    bool isEvent = _isRandomEvent();
    int multiplier = 1;
    if (isEvent) {
      multiplier = _getRandomMultiplier();
      _showEventNotification(multiplier, isCorrect);
    }

    if (isCorrect) {
      int points = 10 * multiplier;
      _score += points;
      if (multiplier > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 +$points points (x$multiplier) 🎉'), duration: const Duration(milliseconds: 800)),
        );
      }
    } else {
      if (widget.mode == 'casual') {
        int damage = 5 * multiplier;
        _health = (_health - damage).clamp(0, 100);
        if (multiplier > 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('💔 -$damage health (x$multiplier) 💔'), duration: const Duration(milliseconds: 800)),
          );
        }
      }
    }

    if (isEvent) {
      setState(() => _isEventActive = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isEventActive = false);
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _resetCurrentOptions();
      });
      _startQuestionTimer();
      _playCurrentSong();
    } else {
      if (widget.mode == 'time_attack') {
        setState(() {
          _questions.shuffle();
          _currentIndex = 0;
          _selectedAnswer = null;
          _resetCurrentOptions();
        });
        _startQuestionTimer();
        _playCurrentSong();
      } else {
        await _db.saveHighScore(widget.mode, _score);
        if (widget.mode == 'stage') {
          int maxScore = _questions.length * 10;
          if (_score >= maxScore) {
            await _db.unlockStage(widget.stageId + 1);
          }
        }
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                score: _score,
                total: _questions.length,
                mode: widget.mode,
                answers: _answersHistory,
              ),
            ),
          );
        }
      }
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('settings'.tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('exit_to_home'.tr()),
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        body: CustomBackground(
          child: Center(child: Text('No questions available', style: const TextStyle(color: Colors.white))),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final total = _questions.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40;

    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lightbulb, color: Colors.white),
                      onPressed: _useHint,
                      tooltip: 'Hint ($_hintsRemaining left)',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_timeLeftPerQuestion',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: _showMenu,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (widget.mode == 'casual')
                  HealthBar(health: _health, isEventActive: _isEventActive),
                if (widget.mode == 'time_attack')
                  TimerWidget(
                    initialTime: _timeRemaining,
                    onTimeOut: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            score: _score,
                            total: total,
                            mode: widget.mode,
                            answers: _answersHistory,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.album, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${(_currentIndex + 1).toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (_currentIndex + 1) / total,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            total.toString().padLeft(2, '0'),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'question'.tr()} ${_currentIndex + 1}/$total',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        currentQ.questionText,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _currentOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final opt = _currentOptions[idx];
                      final isSelected = _selectedAnswer == opt;
                      return AnimatedButton(
                        text: opt,
                        onPressed: _selectedAnswer == null ? () => _submitAnswer(opt) : () {},
                        icon: isSelected ? Icons.check_circle : null,
                        color: isSelected ? Colors.green : Colors.white,
                        textColor: isSelected ? Colors.white : Colors.black87,
                        iconColor: isSelected ? Colors.white : Colors.grey,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 12,
                        shadowDegree: ShadowDegree.light,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../widgets/custom_background.dart';
import '../database/game_database.dart';
import 'quiz_screen.dart';

class StageSelectorScreen extends StatefulWidget {
  const StageSelectorScreen({super.key});

  @override
  State<StageSelectorScreen> createState() => _StageSelectorScreenState();
}

class _StageSelectorScreenState extends State<StageSelectorScreen> {
  final GameDatabase _db = GameDatabase();
  List<int> _unlockedStages = [];
  final int _totalStages = 100;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final unlocked = await _db.getUnlockedStages();
    setState(() {
      _unlockedStages = unlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Stage Mode', style: TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _totalStages,
            itemBuilder: (context, index) {
              int stageNumber = index + 1;
              bool isUnlocked = _unlockedStages.contains(stageNumber);
              return GestureDetector(
                onTap: isUnlocked
                    ? () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(mode: 'stage', stageId: stageNumber),
                    ),
                  );
                  await _loadProgress();
                }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.white24 : Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isUnlocked ? Colors.white : Colors.white24, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isUnlocked ? Icons.music_note : Icons.lock,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stageNumber.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
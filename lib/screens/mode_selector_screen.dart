import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_background.dart';
import '../widgets/animated_button.dart';
import 'quiz_screen.dart';
import 'stage_selector_screen.dart';

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({super.key});

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
          title: Text('select_mode'.tr(), style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedButton(
                  text: 'stage_mode'.tr(),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StageSelectorScreen())),
                  icon: Icons.emoji_events,
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  text: 'casual_mode'.tr(),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(mode: 'casual', stageId: 0))),
                  icon: Icons.favorite,
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  text: 'time_attack'.tr(),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(mode: 'time_attack', stageId: 0))),
                  icon: Icons.timer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/custom_background.dart';
import '../widgets/animated_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    setState(() {
      _volume = 1.0;
    });
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          title: Text('settings'.tr(), style: const TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('language'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _changeLanguage(const Locale('en')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: context.locale.languageCode == 'en' ? Colors.white24 : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.language, color: Colors.white, size: 20),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'English',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (context.locale.languageCode == 'en') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check, color: Colors.green, size: 16),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _changeLanguage(const Locale('id')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: context.locale.languageCode == 'id' ? Colors.white24 : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.language, color: Colors.white, size: 20),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Bahasa Indonesia',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (context.locale.languageCode == 'id') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check, color: Colors.green, size: 16),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Volume', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.volume_down, color: Colors.white),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: _changeVolume,
                    ),
                  ),
                  const Icon(Icons.volume_up, color: Colors.white),
                ],
              ),
              const SizedBox(height: 32),
              AnimatedButton(
                text: 'reset_progress'.tr(),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset progress feature coming soon')),
                  );
                },
                icon: Icons.restore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
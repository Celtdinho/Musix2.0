import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_nominatim/flutter_nominatim.dart';
import '../widgets/custom_background.dart';
import '../widgets/animated_button.dart';
import 'mode_selector_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownLocation = false;

  @override
  void initState() {
    super.initState();
    _showLocationIfAvailable();
  }

  Future<void> _showLocationIfAvailable() async {
    if (_hasShownLocation) return;
    _hasShownLocation = true;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final nominatim = Nominatim.instance;
      Place place = await nominatim.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      if (place.displayName.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 ${place.displayName}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _quitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quit'.tr()),
        content: Text('Are you sure you want to quit?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: Text('Exit'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'app_name'.tr(),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 48),
                // Tombol Play (lebar 180, center)
                Center(
                  child: SizedBox(
                    width: 180,
                    child: AnimatedButton(
                      text: 'play'.tr(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ModeSelectorScreen()),
                        );
                      },
                      icon: Icons.play_arrow,
                      width: double.infinity, // akan mengikuti lebar SizedBox
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 180,
                    child: AnimatedButton(
                      text: 'settings'.tr(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      icon: Icons.settings,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 180,
                    child: AnimatedButton(
                      text: 'quit'.tr(),
                      onPressed: () => _quitApp(context),
                      icon: Icons.exit_to_app,
                      width: double.infinity,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
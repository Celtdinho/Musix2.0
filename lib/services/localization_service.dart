import 'package:flutter/material.dart';
import 'package:world_info_plus/world_info_plus.dart';

class LocalizationService {
  static Future<Locale> detectUserLocale() async {
    try {
      // WorldInfoPlus.deviceCountry mengembalikan Future<Country?>
      final Country? deviceCountry = await WorldInfoPlus.deviceCountry;
      if (deviceCountry != null) {
        final String countryCode = deviceCountry.alpha2.toLowerCase();
        switch (countryCode) {
          case 'id':
            return const Locale('id');
          default:
            return const Locale('en');
        }
      }
    } catch (e) {
      debugPrint('Error detecting location: $e');
    }
    return const Locale('en');
  }
}
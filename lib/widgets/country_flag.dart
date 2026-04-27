import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  final String countryCode; // ISO 3166-1 alpha-2 code, e.g., 'US', 'ID'
  final double size;

  const CountryFlag({
    super.key,
    required this.countryCode,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    // Konversi kode negara ke emoji flag
    final flagEmoji = _countryCodeToEmoji(countryCode);
    return Text(
      flagEmoji,
      style: TextStyle(fontSize: size),
    );
  }

  String _countryCodeToEmoji(String code) {
    // Mengubah kode negara (misal 'US') menjadi emoji flag
    final offset = 0x1F1E6;
    final firstChar = code.codeUnitAt(0) - 0x41 + offset;
    final secondChar = code.codeUnitAt(1) - 0x41 + offset;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}
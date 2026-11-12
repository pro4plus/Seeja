import 'package:flutter/material.dart';

class SudaneseTheme {
  static const Color tabaqRed = Color(0xFFB3261E);
  static const Color palmGreen = Color(0xFF1F6B3A);
  static const Color dateOrange = Color(0xFFE58A1F);
  static const Color hibiscusMagenta = Color(0xFFA3205F);
  static const Color indigoNight = Color(0xFF1D2A5B);
  static const Color nubianTurquoise = Color(0xFF1AA3A8);
  static const Color straw = Color(0xFFD9B36A);
  static const Color cream = Color(0xFFF5E6C4);
  static const Color mudBrickDark = Color(0xFF6E3C1E);
  static const Color mudBrickLight = Color(0xFF8A5129);
  static const Color earthBlack = Color(0xFF1A1210);
  static const Color sunGold = Color(0xFFF2C14E);

  static const List<Color> pebbleColors = [
    Color(0xFF1D2A5B),
    Color(0xFFB86B35),
    Color(0xFF1F6B3A),
    Color(0xFFB3261E),
    Color(0xFF1AA3A8),
    Color(0xFFD99B26),
    Color(0xFF3A3532),
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: mudBrickDark,
        fontFamily: 'Tajawal',
        colorScheme: ColorScheme.fromSeed(
          seedColor: tabaqRed,
          primary: tabaqRed,
          secondary: palmGreen,
          surface: cream,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class AppTheme {
  static final Color _baseBgColor = const Color(0xFF080A18);
  static final Color _glassBgColor = const Color.fromRGBO(17, 19, 37, 0.5);
  static final Color _borderColor = const Color.fromRGBO(255, 255, 255, 0.1);
  static final Color _textColor = const Color(0xFFe0e0e0);
  static final Color _textMutedColor = const Color(0xFF94a1b2);

  static ThemeData buildTheme() {
    // Get the system's accent color, with a fallback
    final accentColor = SystemTheme.accentColor.accent;

    // Generate a light, tinted-white icon color from the accent color
    final hslAccent = HSLColor.fromColor(accentColor);
    final iconColor = hslAccent.withLightness(0.95).toColor();

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _baseBgColor,
      primaryColor: accentColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
        surface: _baseBgColor, // Corrected: was 'background'
        primary: accentColor,
      ),
      fontFamily: 'system-ui',
      textTheme: const TextTheme().apply(
        bodyColor: _textColor,
        displayColor: _textColor,
      ),
      // Custom theme extensions for easy access to our specific colors
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          glassBg: _glassBgColor,
          borderColor: _borderColor,
          textMuted: _textMutedColor,
          iconColor: iconColor,
          red: const Color(0xFFF44336),
          green: const Color(0xFF4CAF50),
          yellow: const Color(0xFFFFC107),
          orange: const Color(0xFFFF9800),
        ),
      ],
    );
  }
}

// A custom theme extension to hold our specific app colors.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.glassBg,
    required this.borderColor,
    required this.textMuted,
    required this.iconColor,
    required this.red,
    required this.green,
    required this.yellow,
    required this.orange,
  });

  final Color glassBg;
  final Color borderColor;
  final Color textMuted;
  final Color iconColor;
  final Color red;
  final Color green;
  final Color yellow;
  final Color orange;

  @override
  AppColors copyWith({
    Color? glassBg,
    Color? borderColor,
    Color? textMuted,
    Color? iconColor,
    Color? red,
    Color? green,
    Color? yellow,
    Color? orange,
  }) {
    return AppColors(
      glassBg: glassBg ?? this.glassBg,
      borderColor: borderColor ?? this.borderColor,
      textMuted: textMuted ?? this.textMuted,
      iconColor: iconColor ?? this.iconColor,
      red: red ?? this.red,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      orange: orange ?? this.orange,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      red: Color.lerp(red, other.red, t)!,
      green: Color.lerp(green, other.green, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
    );
  }
}
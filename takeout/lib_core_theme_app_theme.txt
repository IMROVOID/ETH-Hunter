import 'package:flutter/material.dart';

// Custom Colors Extension
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.glassBg,
    required this.borderColor,
    required this.textMuted,
    required this.iconColor,
    required this.red,
    required this.green,
    required this.yellow,
    required this.orange,
    required this.gradient1,
    required this.gradient2,
    required this.gradient3,
    required this.blurSigma,
  });

  final Color glassBg;
  final Color borderColor;
  final Color textMuted;
  final Color iconColor;
  final Color red;
  final Color green;
  final Color yellow;
  final Color orange;
  final Color gradient1;
  final Color gradient2;
  final Color gradient3;
  final double blurSigma;

  @override
  CustomColors copyWith({
    Color? glassBg,
    Color? borderColor,
    Color? textMuted,
    Color? iconColor,
    Color? red,
    Color? green,
    Color? yellow,
    Color? orange,
    Color? gradient1,
    Color? gradient2,
    Color? gradient3,
    double? blurSigma,
  }) {
    return CustomColors(
      glassBg: glassBg ?? this.glassBg,
      borderColor: borderColor ?? this.borderColor,
      textMuted: textMuted ?? this.textMuted,
      iconColor: iconColor ?? this.iconColor,
      red: red ?? this.red,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      orange: orange ?? this.orange,
      gradient1: gradient1 ?? this.gradient1,
      gradient2: gradient2 ?? this.gradient2,
      gradient3: gradient3 ?? this.gradient3,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      glassBg: Color.lerp(glassBg, other.glassBg, t) ?? glassBg,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      red: Color.lerp(red, other.red, t) ?? red,
      green: Color.lerp(green, other.green, t) ?? green,
      yellow: Color.lerp(yellow, other.yellow, t) ?? yellow,
      orange: Color.lerp(orange, other.orange, t) ?? orange,
      gradient1: Color.lerp(gradient1, other.gradient1, t) ?? gradient1,
      gradient2: Color.lerp(gradient2, other.gradient2, t) ?? gradient2,
      gradient3: Color.lerp(gradient3, other.gradient3, t) ?? gradient3,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
    );
  }
}

class AppTheme {
  // --- Light Theme ---
  static ThemeData light(Color accentColor) {
    // Determine if text on top of the accent color should be black or white
    final onPrimaryColor = accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
        primary: accentColor,
        onPrimary: onPrimaryColor,
      ),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(
          glassBg: Colors.white.withAlpha(128),
          borderColor: Colors.black.withAlpha(26),
          // **MODIFICATION**: Darkened the muted text color for better readability on light backgrounds.
          textMuted: Colors.grey.shade800,
          iconColor: Colors.black87,
          red: const Color(0xFFD32F2F),
          green: const Color(0xFF388E3C),
          yellow: const Color(0xFFFBC02D),
          orange: const Color(0xFFF57C00),
          gradient1: accentColor.withAlpha(51),
          gradient2: HSLColor.fromColor(accentColor).withHue((HSLColor.fromColor(accentColor).hue + 45) % 360).toColor().withAlpha(51),
          gradient3: HSLColor.fromColor(accentColor).withHue((HSLColor.fromColor(accentColor).hue - 45) % 360).toColor().withAlpha(51),
          blurSigma: 100.0,
        ),
      ],
    );
  }

  // --- Dark Theme ---
  static ThemeData dark(Color accentColor) {
    const darkBgColor = Color(0xFF121212);
    // Determine if text on top of the accent color should be black or white
    final onPrimaryColor = accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: darkBgColor,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: accentColor,
          onPrimary: onPrimaryColor,
          secondary: accentColor,
          onSecondary: onPrimaryColor,
          tertiary: accentColor,
          onTertiary: onPrimaryColor,
          background: darkBgColor,
          onBackground: Colors.white,
          surface: darkBgColor,
          onSurface: Colors.white,
          error: const Color(0xFFCF6679),
          onError: Colors.black,
      ),
      extensions: <ThemeExtension<dynamic>>[
        CustomColors(
          glassBg: const Color.fromRGBO(20, 22, 28, 0.5),
          borderColor: Colors.white.withAlpha(26),
          textMuted: const Color(0xFF94a1b2),
          iconColor: Colors.white70,
          red: const Color(0xFFF44336),
          green: const Color(0xFF4CAF50),
          yellow: const Color(0xFFFFC107),
          orange: const Color(0xFFFF9800),
          gradient1: accentColor.withAlpha(10),
          gradient2: HSLColor.fromColor(accentColor).withHue((HSLColor.fromColor(accentColor).hue + 60) % 360).toColor().withAlpha(10),
          gradient3: HSLColor.fromColor(accentColor).withHue((HSLColor.fromColor(accentColor).hue - 60) % 360).toColor().withAlpha(10),
          blurSigma: 110.0,
        ),
      ],
    );
  }
}

// Helper function to lerp (linearly interpolate) doubles
double? lerpDouble(double? a, double? b, double t) {
  if (a == null || b == null) return null;
  return a + (b - a) * t;
}
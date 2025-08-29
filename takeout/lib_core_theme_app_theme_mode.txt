import 'package:flutter/material.dart';

// Defines the available theme modes for the application.
enum AppThemeMode {
  system,
  light,
  dark;

  // A helper to get the corresponding Flutter ThemeMode.
  ThemeMode get flutterThemeMode => switch (this) {
        system => ThemeMode.system,
        light => ThemeMode.light,
        dark => ThemeMode.dark,
      };
      
  // A helper to get a user-friendly name for each mode.
  String get presentableName => switch (this) {
        system => "System",
        light => "Light",
        dark => "Dark",
      };
}
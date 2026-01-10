import 'package:flutter/material.dart';
import 'storage.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier(_loadInitial());

  static ThemeMode _loadInitial() {
    final isDark =
        Storage.prefsBox.get('dark_mode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void setDarkMode(bool enabled) {
    Storage.prefsBox.put('dark_mode', enabled);
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}

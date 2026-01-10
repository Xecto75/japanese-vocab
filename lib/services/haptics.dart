import 'package:flutter/services.dart';
import 'storage.dart';

class Haptics {
  static bool get _enabled =>
      Storage.prefsBox.get('vibration', defaultValue: true);

  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  // Example custom pattern
  static Future<void> success() async {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.selectionClick();
  }

  static Future<void> fail() async {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }
}

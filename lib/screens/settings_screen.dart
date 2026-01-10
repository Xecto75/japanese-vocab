import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../services/haptics.dart';
import '../services/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool darkMode;
  late bool showFurigana;
  late bool notifications;
  late bool vibration;

  @override
  void initState() {
    super.initState();
    

    // ✅ Load values from Hive (with defaults)
    final prefs = Storage.prefsBox;
    darkMode = prefs.get('dark_mode', defaultValue: false);
    showFurigana = prefs.get('show_furigana', defaultValue: true);
    notifications = prefs.get('notifications', defaultValue: true);
    vibration = prefs.get('vibration', defaultValue: true);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Storage.prefsBox;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        toolbarHeight: 100, 
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: darkMode,
            onChanged: (v) {
              setState(() => darkMode = v);
              ThemeController.setDarkMode(v);
            },
          ),
          SwitchListTile(
            title: const Text('Kanji helper (furigana)'),
            subtitle:
                const Text('Show hiragana under kanji'),
            value: showFurigana,
            onChanged: (v) {
              setState(() => showFurigana = v);
              prefs.put('show_furigana', v); // ✅ THIS WAS MISSING
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (v) {
              setState(() => notifications = v);
              prefs.put('notifications', v);
            },
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: vibration,
            onChanged: (v) {
              setState(() => vibration = v);
              prefs.put('vibration', v);
              if (v) {
                Haptics.light();
              }
            },
          ),
        ],
      ),
    );
  }
}

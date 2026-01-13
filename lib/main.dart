import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:japanese_vocab/services/storage.dart';
import 'package:japanese_vocab/services/seed.dart';
import 'package:japanese_vocab/services/theme_controller.dart';
import 'package:japanese_vocab/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Storage.init();
  await Seed.ensureSeeded();

  runApp(const MemoriApp());
}

class MemoriApp extends StatelessWidget {
  const MemoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Memori',

          // Which theme (light/dark) is active
          themeMode: themeMode,

          // Root screen
          home: const HomeScreen(),

          // =====================
          // 🌞 LIGHT THEME
          // =====================
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: 'NotoSansJP',

            // MAIN COLOR PALETTE
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,   // 👈 App brand color (buttons, highlights)
              brightness: Brightness.light,
            ).copyWith(
              surface: Colors.white,      // 👈 Page backgrounds (Scaffold, cards)
            ),

            // SWITCH (settings toggles)
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.indigo; // 👈 ON knob
                }
                return Colors.grey.shade300;     // 👈 OFF knob
              }),
              trackColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.indigo.withOpacity(0.5); // 👈 ON track
                }
                return Colors.grey.shade400;            // 👈 OFF track
              }),
            ),

            // BUTTON COLOR (Start, Submit, etc)
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, // 👈 Button fill
                foregroundColor: Colors.white,  // 👈 Button text
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // =====================
          // 🌙 DARK THEME
          // =====================
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'NotoSansJP',

            // MAIN COLOR PALETTE
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ).copyWith(
              primary: Colors.amber,            // 👈 Highlight color (toggles, accents)
              secondary: Colors.amber,
              surface: Colors.grey.shade900,  // 👈 Page background (behind cards)
            ),

            // SWITCH (settings toggles)
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.amber; // 👈 ON knob
                }
                return Colors.grey;     // 👈 OFF knob
              }),
              trackColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.amber.withOpacity(0.5); // 👈 ON track
                }
                return Colors.grey.shade700;            // 👈 OFF track
              }),
            ),

            // BUTTONS (Start, Next, Submit)
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,  // 👈 Button fill
                foregroundColor: Colors.black,  // 👈 Button text
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

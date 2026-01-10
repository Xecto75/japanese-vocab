import 'package:flutter/material.dart';
import 'session_setup_screen.dart';
import 'dictionary_screen.dart';
import 'settings_screen.dart'; // MUST exist in lib/screens/
import '../services/repo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JP Vocab', style: TextStyle(fontSize: 30)),
        toolbarHeight: 100, 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(), // ❌ no const
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ vertical centering
              spacing: 30,
              children: [
                _navBtn(
                  context,
                  label: 'Learn (Flashcards)',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionSetupScreen(mode: SessionMode.learn),
                    ),
                  ),
                ),
                _navBtn(
                  context,
                  label: 'Practice (Active Recall)',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionSetupScreen(mode: SessionMode.practice),
                    ),
                  ),
                ),
                _navBtn(
                  context,
                  label: 'Dictionary',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DictionaryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBtn(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44, // smaller button, consistent with other screens
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

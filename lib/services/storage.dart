import 'package:hive/hive.dart';

class Storage {
  static const wordsBoxName = 'wordsBox';     // Map<String, Map>
  static const listsBoxName = 'listsBox';     // Map<String, Map>
  static const masteryBoxName = 'masteryBox'; // Map<String, Map>
  static const prefsBoxName = 'prefs';        // simple key-value prefs

  static late Box wordsBox;
  static late Box listsBox;
  static late Box masteryBox;
  static late Box prefsBox;

  static Future<void> init() async {
    wordsBox = await Hive.openBox(wordsBoxName);
    listsBox = await Hive.openBox(listsBoxName);
    masteryBox = await Hive.openBox(masteryBoxName);

    // ✅ ADD THIS
    prefsBox = await Hive.openBox(prefsBoxName);
  }
}

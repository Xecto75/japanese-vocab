import 'dart:convert';
import 'package:flutter/services.dart';

import 'storage.dart';

class Seed {
  static const seededKey = '_seeded_v7';

  static Future<void> ensureSeeded() async {
    final already = Storage.listsBox.get(seededKey) == true;
    if (already) return;

    final raw = await rootBundle.loadString('assets/seed_words.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;

    final lists = (data['lists'] as List<dynamic>).whereType<Map<String, dynamic>>();

    for (final l in lists) {
      final listId = l['id'] as String;
      final listName = l['name'] as String;
      final words = (l['words'] as List<dynamic>).whereType<Map<String, dynamic>>();

      // store list
      Storage.listsBox.put(listId, {
        'id': listId,
        'name': listName,
      });

      for (final w in words) {
        final wordId = w['id'] as String;
        Storage.wordsBox.put(wordId, {
          'id': wordId,
          'listId': listId,
          'listName': listName,
          'kanji': w['kanji'],
          'reading': w['reading'],
          'english': w['english'],
          'examples': (w['examples'] as List<dynamic>?) ?? [],
        });

        // init mastery if missing
        if (!Storage.masteryBox.containsKey(wordId)) {
          Storage.masteryBox.put(wordId, {
            'wordId': wordId,
            'value': 0,
            'seen': false,
          });
        }
      }
    }

    Storage.listsBox.put(seededKey, true);
  }
}

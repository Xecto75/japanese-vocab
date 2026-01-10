import '../models/mastery.dart';
import '../models/vocab_word.dart';
import 'storage.dart';

enum Direction { jpToEn, enToJp }
enum SessionMode { learn, practice }

class Repo {
  static List<Map<String, dynamic>> getAllLists() {
    final keys = Storage.listsBox.keys.whereType<String>().where((k) => !k.startsWith('_'));
    return keys.map((id) => Map<String, dynamic>.from(Storage.listsBox.get(id))).toList();
  }

  static List<VocabWord> getWordsForLists(Set<String> listIds) {
    final words = <VocabWord>[];
    for (final key in Storage.wordsBox.keys.whereType<String>()) {
      final m = Map<String, dynamic>.from(Storage.wordsBox.get(key));
      if (listIds.contains(m['listId'] as String)) {
        final examples = (m['examples'] as List<dynamic>?)
                ?.whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            const [];
        words.add(VocabWord(
          id: m['id'] as String,
          listId: m['listId'] as String,
          listName: m['listName'] as String,
          kanji: m['kanji'] as String,
          reading: m['reading'] as String,
          english: m['english'] as String,
          examples: examples.map((e) => ExampleSentence.fromJson(e)).toList(),
        ));
      }
    }
    return words;
  }

  static List<VocabWord> getAllWords() {
    final words = <VocabWord>[];
    for (final key in Storage.wordsBox.keys.whereType<String>()) {
      final m = Map<String, dynamic>.from(Storage.wordsBox.get(key));
      final examples = (m['examples'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [];
      words.add(VocabWord(
        id: m['id'] as String,
        listId: m['listId'] as String,
        listName: m['listName'] as String,
        kanji: m['kanji'] as String,
        reading: m['reading'] as String,
        english: m['english'] as String,
        examples: examples.map((e) => ExampleSentence.fromJson(e)).toList(),
      ));
    }
    return words;
  }

  static Mastery getMastery(String wordId) {
    final raw = Map<String, dynamic>.from(Storage.masteryBox.get(wordId));
    return Mastery.fromJson(raw);
  }

  static void saveMastery(Mastery m) {
    Storage.masteryBox.put(m.wordId, m.toJson());
  }

  static void applyFlashcardResult({required String wordId, required bool correct}) {
    final m = getMastery(wordId);
    m.seen = true;
    if (correct) {
      m.value = (m.value + 3).clamp(0, 100);
    } else {
      m.value = (m.value - 5).clamp(0, 100);
    }
    saveMastery(m);
  }

  static void applyPracticeResult({required String wordId, required bool correct}) {
    final m = getMastery(wordId);
    m.seen = true;
    if (correct) {
      m.value = (m.value + 8).clamp(0, 100);
    } else {
      m.value = (m.value - 10).clamp(0, 100);
    }
    saveMastery(m);
  }
}

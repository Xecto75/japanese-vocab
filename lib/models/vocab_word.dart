class ExampleSentence {
  final String jp;
  final String en;

  const ExampleSentence({required this.jp, required this.en});

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      jp: (json['jp'] as String?) ?? '',
      en: (json['en'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'jp': jp, 'en': en};
}

class VocabWord {
  final String id;
  final String listId;
  final String listName;

  final String kanji;
  final String reading;
  final String english;
  final List<ExampleSentence> examples;

  const VocabWord({
    required this.id,
    required this.listId,
    required this.listName,
    required this.kanji,
    required this.reading,
    required this.english,
    required this.examples,
  });

  factory VocabWord.fromJson({
    required String listId,
    required String listName,
    required Map<String, dynamic> json,
  }) {
    final ex = (json['examples'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(ExampleSentence.fromJson)
            .toList() ??
        const <ExampleSentence>[];

    return VocabWord(
      id: (json['id'] as String?) ?? '',
      listId: listId,
      listName: listName,
      kanji: (json['kanji'] as String?) ?? '',
      reading: (json['reading'] as String?) ?? '',
      english: (json['english'] as String?) ?? '',
      examples: ex,
    );
  }
}

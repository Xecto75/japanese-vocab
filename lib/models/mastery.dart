class Mastery {
  final String wordId;
  int value; // 0..100
  bool seen;

  Mastery({
    required this.wordId,
    this.value = 0,
    this.seen = false,
  });

  factory Mastery.fromJson(Map<String, dynamic> json) {
    return Mastery(
      wordId: json['wordId'] as String,
      value: (json['value'] as num?)?.toInt() ?? 0,
      seen: (json['seen'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'value': value,
        'seen': seen,
      };
}

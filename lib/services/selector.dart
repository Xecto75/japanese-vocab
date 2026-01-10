import 'dart:math';
import '../models/vocab_word.dart';
import 'repo.dart';

class Selector {
  final Random _rng = Random();
  final List<String> _recent = [];
  final int cooldownSize;
  final double alpha;

  Selector({this.cooldownSize = 5, this.alpha = 2.0});

  VocabWord pickNext(List<VocabWord> pool) {
    if (pool.isEmpty) throw StateError('Empty pool');

    // Filter out recent words if possible
    final filtered = pool.where((w) => !_recent.contains(w.id)).toList();
    final candidates = filtered.isNotEmpty ? filtered : pool;

    // Build weights
    final weights = <double>[];
    double total = 0;

    for (final w in candidates) {
      final m = Repo.getMastery(w.id);
      final mastery01 = (m.value.clamp(0, 100)) / 100.0;
      final need = pow(1.0 - mastery01, alpha).toDouble(); // 0..1 (curved)
      final weight = (0.2 + 0.8 * need); // clamp-ish: 0.2..1.0
      weights.add(weight);
      total += weight;
    }

    // Weighted roulette selection
    double r = _rng.nextDouble() * total;
    for (int i = 0; i < candidates.length; i++) {
      r -= weights[i];
      if (r <= 0) {
        final picked = candidates[i];
        _pushRecent(picked.id);
        return picked;
      }
    }

    final fallback = candidates.last;
    _pushRecent(fallback.id);
    return fallback;
  }

  void _pushRecent(String id) {
    _recent.add(id);
    if (_recent.length > cooldownSize) {
      _recent.removeAt(0);
    }
  }
}

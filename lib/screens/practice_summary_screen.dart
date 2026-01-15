import 'package:flutter/material.dart';
import '../models/vocab_word.dart';

class PracticeSummaryScreen extends StatelessWidget {
  final int total;
  final int correct;
  final List<VocabWord> missed;

  const PracticeSummaryScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.missed,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0 : (correct / total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Accuracy: ${accuracy.toStringAsFixed(0)}% ($correct/$total)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (missed.isEmpty)
              const Text('Perfect! No missed words. 🎉')
            else ...[
              const Text(
                'Missed words',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...missed.map(
                (w) => ListTile(
                  title: Text(w.kanji),
                  subtitle: Text('${w.reading} — ${w.english}'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

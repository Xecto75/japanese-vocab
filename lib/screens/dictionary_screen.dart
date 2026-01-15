import 'package:flutter/material.dart';
import '../services/repo.dart';
import '../models/vocab_word.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allWords = Repo.getAllWords();

    // Group by category/list
    final Map<String, List<VocabWord>> grouped = {};
    for (final w in allWords) {
      grouped.putIfAbsent(w.listName, () => []).add(w);
    }

    final width = MediaQuery.of(context).size.width;

    final int columns = width >= 1000
        ? 5
        : width >= 750
        ? 4
        : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: grouped.entries.expand((entry) {
          return [
            _SectionHeader(title: entry.key),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, i) {
                  return _WordBlock(word: entry.value[i]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 2,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
          ];
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WordBlock extends StatelessWidget {
  final VocabWord word;
  const _WordBlock({required this.word});

  @override
  Widget build(BuildContext context) {
    final mastery = Repo.getMastery(word.id);
    final masteryValue = mastery.value.clamp(0, 100) / 100.0;
    final seen = mastery.seen;

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark
        ? (seen ? const Color(0xFF2F2F2F) : const Color(0xFF272727))
        : (seen ? const Color(0xFFE1E1E1) : const Color(0xFFECECEC));

    final double contentOpacity = seen ? 1.0 : 0.45;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Opacity(
          opacity: contentOpacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.kanji,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                word.english,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: masteryValue,
                    minHeight: 6,
                    backgroundColor: scheme.onSurface.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Word details',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondary, child) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              title: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(text: word.kanji),
                    if (word.reading.isNotEmpty)
                      TextSpan(
                        text: ' (${word.reading})',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.english),
                  const SizedBox(height: 12),
                  const Text(
                    'Examples',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  ...word.examples.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.jp),
                          Text(
                            e.en,
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

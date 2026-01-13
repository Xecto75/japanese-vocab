import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/repo.dart';
import '../services/selector.dart';
import '../widgets/flashcard_view.dart';

class StudyScreen extends StatefulWidget {
  final List<VocabWord> words;
  final Direction direction;

  const StudyScreen({
    super.key,
    required this.words,
    required this.direction,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final Selector selector = Selector(cooldownSize: 5, alpha: 2.0);

  late VocabWord current;
  bool revealed = false;

  @override
  void initState() {
    super.initState();
    current = selector.pickNext(widget.words);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn (Flashcards)'),
        toolbarHeight: 100, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 150),
            SizedBox(
              height: 300,
              child: FlashcardView(
                key: ValueKey(current.id), // ✅ HARD GUARANTEE: no state reuse
                word: current,
                direction: widget.direction,
                revealed: revealed,
                onTapCard: () => setState(() => revealed = true),
              ),
            ),
            const SizedBox(height: 30),

            if (!revealed)
              SizedBox(
                width: 200,
                height: 44, // ✅ smaller button
                child: ElevatedButton(
                  onPressed: () => setState(() => revealed = true),
                  child: const Text('Reveal'),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _answer(false),
                        child: const Text("I guessed wrong"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _answer(true),
                        child: const Text("I guessed right"),
                      ),
                    ),
                  ),
                ],
              ),

            Spacer(),
            Text(
              'Mastery: ${Repo.getMastery(current.id).value}%',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _answer(bool correct) {
    // 1️⃣ apply result
    Repo.applyFlashcardResult(wordId: current.id, correct: correct);

    // 2️⃣ reset reveal FIRST
    setState(() {
      revealed = false;
    });

    // 3️⃣ pick next card AFTER reveal reset
    setState(() {
      current = selector.pickNext(widget.words);
    });
  }
}

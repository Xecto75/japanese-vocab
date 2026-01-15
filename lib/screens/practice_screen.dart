import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/repo.dart';
import '../services/selector.dart';
import '../services/storage.dart';
import '../services/haptics.dart';
import 'practice_summary_screen.dart';

class PracticeScreen extends StatefulWidget {
  final List<VocabWord> words;
  final Direction direction;
  final int questions;

  const PracticeScreen({
    super.key,
    required this.words,
    required this.direction,
    required this.questions,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final Selector selector = Selector(cooldownSize: 3, alpha: 2.0);
  final TextEditingController controller = TextEditingController();
  final FocusNode inputFocus = FocusNode();

  late VocabWord current;
  int index = 1;

  int correctCount = 0;
  final List<VocabWord> missed = [];

  String? feedback;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    current = selector.pickNext(widget.words);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt =
        widget.direction == Direction.jpToEn ? current.kanji : current.english;

    final bool showFurigana =
        Storage.prefsBox.get('show_furigana', defaultValue: true);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Practice ($index/${widget.questions})'),
          toolbarHeight: 100,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 30,
                        child: (widget.direction == Direction.jpToEn &&
                                showFurigana &&
                                current.reading.isNotEmpty)
                            ? Text(
                                current.reading,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),

                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller,
                        focusNode: inputFocus,
                        enabled: !answered,
                        decoration: InputDecoration(
                          labelText: widget.direction == Direction.jpToEn
                              ? 'Type English'
                              : 'Type Japanese',
                          border: const OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
                        onSubmitted: (_) => !answered ? _submit() : null,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 48,
                        child: Center(
                          child: answered
                              ? Text(feedback!, textAlign: TextAlign.center)
                              : const SizedBox(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: answered ? _next : _submit,
                          child: Text(answered ? 'Next' : 'Submit'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Mastery: ${Repo.getMastery(current.id).value}%',
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================
  // BACK CONFIRMATION (POP ANIMATION)
  // =====================
  Future<bool> _confirmExit() async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Quit",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondary, _) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              title: const Text('Quit practice?'),
              content: const Text(
                'Are you sure you want to quit?\nYour progress for this session will be lost.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Resume'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Quit'),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // =====================
  // ANSWER CHECK
  // =====================
  bool _isCorrectAnswer(String userInput, VocabWord w) {
    final input = userInput.trim().toLowerCase();
    if (input.isEmpty) return false;

    if (widget.direction == Direction.jpToEn) {
      final accepted = w.english
          .split(RegExp(r'[;,]'))
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
      return accepted.any((a) => input == a);
    }

    final bool showFurigana =
        Storage.prefsBox.get('show_furigana', defaultValue: true);

    final hasKanji = w.kanji.isNotEmpty && w.kanji != w.reading;

    final kanji = w.kanji.toLowerCase();
    final reading = w.reading.toLowerCase();

    if (showFurigana) {
      return hasKanji ? input == kanji || input == reading : input == reading;
    } else {
      return hasKanji ? input == kanji : input == reading;
    }
  }

  void _submit() {
    final ok = _isCorrectAnswer(controller.text, current);
    Repo.applyPracticeResult(wordId: current.id, correct: ok);

    setState(() {
      answered = true;
      final expected = widget.direction == Direction.jpToEn
          ? current.english
          : current.kanji +
              (current.reading.isNotEmpty ? ' / ${current.reading}' : '');
      feedback = ok ? '✅ Correct' : '❌ Incorrect\nExpected: $expected';
      if (ok) {
        correctCount++;
        Haptics.success();
      } else {
        missed.add(current);
        Haptics.fail();
      }
    });
  }

  void _next() {
    if (index >= widget.questions) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeSummaryScreen(
            total: widget.questions,
            correct: correctCount,
            missed: missed,
          ),
        ),
      );
      return;
    }

    setState(() {
      index++;
      controller.clear();
      feedback = null;
      answered = false;
      current = selector.pickNext(widget.words);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputFocus.requestFocus();
    });
  }
}

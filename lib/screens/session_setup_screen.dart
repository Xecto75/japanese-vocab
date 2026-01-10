import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/repo.dart';
import 'study_screen.dart';
import 'practice_screen.dart';

class SessionSetupScreen extends StatefulWidget {
  final SessionMode mode;
  const SessionSetupScreen({super.key, required this.mode});

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  static const String _listsKey = 'last_selected_lists';

  final Set<String> selectedListIds = {};
  Direction direction = Direction.jpToEn;
  int practiceQuestions = 10;

  late Box _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = Hive.box('prefs');

    final stored = _prefs.get(_listsKey);
    if (stored is List) {
      selectedListIds.addAll(stored.cast<String>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lists = Repo.getAllLists();
    final title =
        widget.mode == SessionMode.learn ? 'Learn Setup' : 'Practice Setup';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        toolbarHeight: 100, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // =====================
            // LIST SELECTION
            // =====================
            const Text(
              'Lists',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _openListSelector(context, lists),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedListIds.isEmpty
                      ? 'Select lists'
                      : '${selectedListIds.length} list(s) selected',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =====================
            // DIRECTION
            // =====================
            const Text(
              'Direction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<Direction>(
              segments: const [
                ButtonSegment(
                  value: Direction.jpToEn,
                  label: Text(
                    'Japanese → English',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ButtonSegment(
                  value: Direction.enToJp,
                  label: Text(
                    'English → Japanese',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
              selected: {direction},
              onSelectionChanged: (v) {
                setState(() => direction = v.first);
              },
            ),

            // =====================
            // PRACTICE ONLY
            // =====================
            if (widget.mode == SessionMode.practice) ...[
              const SizedBox(height: 24),
              const Text(
                'Number of questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text('$practiceQuestions questions'),
              Slider(
                value: practiceQuestions.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: practiceQuestions.toString(),
                onChanged: (v) {
                  setState(() => practiceQuestions = v.round());
                },
              ),
            ],

            // =====================
            // PUSH BUTTON TO BOTTOM
            // =====================
            const Spacer(),

            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                height: 44,
                child: ElevatedButton(
                  onPressed:
                      selectedListIds.isEmpty ? null : () => _start(context),
                  child: const Text('Start'),
                ),
              ),
            ),
            const SizedBox(height: 28)
          ],
        ),
      ),
    );
  }

  // =====================
  // MULTI-SELECT BOTTOM SHEET (SCROLLABLE ON PURPOSE)
  // =====================
  void _openListSelector(
    BuildContext context,
    List<Map<String, dynamic>> lists,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                children: [
                  const Text(
                    'Select lists',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView(
                      children: lists.map((l) {
                        final id = l['id'] as String;
                        final name = l['name'] as String;
                        final checked = selectedListIds.contains(id);

                        return CheckboxListTile(
                          value: checked,
                          title: Text(name),
                          onChanged: (v) {
                            modalSetState(() {
                              if (v == true) {
                                selectedListIds.add(id);
                              } else {
                                selectedListIds.remove(id);
                              }
                            });

                            _prefs.put(
                              _listsKey,
                              selectedListIds.toList(),
                            );

                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: 200,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }



  // =====================
  // START SESSION
  // =====================
  void _start(BuildContext context) {
    final words = Repo.getWordsForLists(selectedListIds);

    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words in selected lists')),
      );
      return;
    }

    if (widget.mode == SessionMode.learn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              StudyScreen(words: words, direction: direction),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeScreen(
            words: words,
            direction: direction,
            questions: practiceQuestions,
          ),
        ),
      );
    }
  }
}

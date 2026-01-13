import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/repo.dart';
import '../services/storage.dart';

class FlashcardView extends StatefulWidget {
  final VocabWord word;
  final Direction direction;
  final bool revealed;
  final VoidCallback onTapCard;

  const FlashcardView({
    super.key,
    required this.word,
    required this.direction,
    required this.revealed,
    required this.onTapCard,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.revealed != oldWidget.revealed) {
      if (widget.revealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(angle),
            child: _buildCard(isFront),
          );
        },
      ),
    );
  }

  Widget _buildCard(bool isFront) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF2F2F2F) : const Color(0xFF2F2F2F);
    final front =
        widget.direction == Direction.jpToEn ? _jpSide() : _enSide();
    final back =
        widget.direction == Direction.jpToEn ? _enSide() : _jpSide();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardColor,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: isFront
            ? front
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(pi),
                child: back,
              ),
      ),
    );
  }

  Widget _jpSide() {
    // ✅ Read kanji helper preference from Hive
    final bool showFurigana =
        Storage.prefsBox.get('show_furigana', defaultValue: true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.word.kanji,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showFurigana) ...[
          const SizedBox(height: 10),
          Text(
            widget.word.reading,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _enSide() {
    return Text(
      widget.word.english,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}

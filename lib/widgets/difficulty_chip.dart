import 'package:flutter/material.dart';

class DifficultyChip extends StatelessWidget {
  final String difficulty;

  const DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    if (difficulty.toLowerCase() == 'easy') {
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
      label = 'Easy';
    } else if (difficulty.toLowerCase() == 'medium') {
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
      label = 'Medium';
    } else if (difficulty.toLowerCase() == 'hard') {
      bg = Colors.red.shade100;
      text = Colors.red.shade800;
      label = 'Hard';
    } else {
      bg = Colors.grey.shade100;
      text = Colors.grey.shade800;
      label = difficulty;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
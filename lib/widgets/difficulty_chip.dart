import 'package:flutter/material.dart';

class DifficultyChip extends StatelessWidget {
  final String difficulty;

  const DifficultyChip({Key? key, required this.difficulty}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (difficulty.toLowerCase()) {
      case 'easy':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Easy';
        break;
      case 'medium':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Medium';
        break;
      case 'hard':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Hard';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = difficulty;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
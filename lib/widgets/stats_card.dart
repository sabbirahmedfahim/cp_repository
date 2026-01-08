import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StatsCard extends StatelessWidget {
  final int count;
  final String label;
  final Color? color;

  const StatsCard({
    Key? key,
    required this.count,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14, color: AppColors.secondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
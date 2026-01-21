import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final bool isError;
  final IconData icon;
  final Color color;

  const MessageWidget({
    required this.message,
    this.isError = true,
    this.icon = Icons.error,
    this.color = Colors.red,
  });

  Color get _backgroundColor {
    if (isError) return Colors.red.withOpacity(0.1);
    return color.withOpacity(0.1);
  }

  Color get _borderColor {
    if (isError) return Colors.red.withOpacity(0.3);
    return color.withOpacity(0.3);
  }

  Color get _iconColor {
    if (isError) return Colors.red;
    return color;
  }

  Color get _textColor {
    if (isError) return Colors.red.shade800;
    if (color == Colors.green) return Colors.green.shade800;
    if (color == Colors.orange) return Colors.orange.shade800;
    if (color == Colors.blue) return Colors.blue.shade800;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: _iconColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: _textColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
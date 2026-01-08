import 'dart:math';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final int pendingCount;
  final int attemptCount;
  final int solvedCount;

  const PieChartWidget({
    Key? key,
    required this.pendingCount,
    required this.attemptCount,
    required this.solvedCount,
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  String? hoverText;
  Offset? mousePos;

  int get total => widget.pendingCount + widget.attemptCount + widget.solvedCount;

  void handleHover(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    final distance = sqrt(dx * dx + dy * dy);
    final radius = size.width / 2;

    if (distance > radius) {
      setState(() => hoverText = null);
      return;
    }

    double angle = atan2(dy, dx);
    angle = angle < -pi / 2 ? angle + 2 * pi : angle;
    angle += pi / 2;

    double currentAngle = 0;

    final pendingSweep = widget.pendingCount / total * 2 * pi;
    final attemptSweep = widget.attemptCount / total * 2 * pi;
    final solvedSweep = widget.solvedCount / total * 2 * pi;

    if (angle >= currentAngle && angle < currentAngle + pendingSweep) {
      hoverText = 'Pending ${widget.pendingCount}';
    }
    currentAngle += pendingSweep;

    if (angle >= currentAngle && angle < currentAngle + attemptSweep) {
      hoverText = 'Attempt ${widget.attemptCount}';
    }
    currentAngle += attemptSweep;

    if (angle >= currentAngle && angle < currentAngle + solvedSweep) {
      hoverText = 'Solved ${widget.solvedCount}';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) {
            mousePos = event.localPosition;
            if (total > 0) handleHover(event.localPosition, size);
          },
          onExit: (_) => setState(() => hoverText = null),
          child: Stack(
            children: [
              CustomPaint(size: size, painter: _PiePainter(pending: widget.pendingCount, attempt: widget.attemptCount, solved: widget.solvedCount)),
              if (hoverText != null && mousePos != null)
                Positioned(
                  left: mousePos!.dx + 10,
                  top: mousePos!.dy + 10,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
                      child: Text(hoverText!, style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PiePainter extends CustomPainter {
  final int pending;
  final int attempt;
  final int solved;

  _PiePainter({required this.pending, required this.attempt, required this.solved});

  @override
  void paint(Canvas canvas, Size size) {
    final total = pending + attempt + solved;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (total == 0) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.grey.shade300);
      return;
    }

    double startAngle = -pi / 2;

    void draw(int value, Color color) {
      if (value == 0) return;
      final sweep = value / total * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()..color = color,
      );
      startAngle += sweep;
    }

    draw(pending, Colors.grey.shade400);
    draw(attempt, Colors.blue);
    draw(solved, Colors.green);
  }

  @override
  bool shouldRepaint(_) => true;
}
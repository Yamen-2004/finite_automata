import 'package:finite_automata/models/state_node.dart';
import 'package:finite_automata/models/transtion.dart';
import 'package:flutter/material.dart';

class AutomatonPainter extends CustomPainter {
  final List<StateNode> states;
  final List<transitionModel> transitions;
  final String? selectedStateId;
  final double gridSize;

  AutomatonPainter({
    required this.states,
    required this.transitions,
    this.selectedStateId,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw transitions
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Track bidirectional transitions
    final transitionPairs = <String, List<transitionModel>>{};
    for (var t in transitions) {
      final key = [t.fromState, t.toState]..sort();
      final pairKey = key.join('-');
      transitionPairs[pairKey] ??= [];
      transitionPairs[pairKey]!.add(t);
    }

    for (var pairKey in transitionPairs.keys) {
      final pairTransitions = transitionPairs[pairKey]!;
      for (var i = 0; i < pairTransitions.length; i++) {
        final t = pairTransitions[i];
        final fromState = states.firstWhere((s) => s.id == t.fromState);
        final toState = states.firstWhere((s) => s.id == t.toState);
        final start = fromState.position;
        final end = toState.position;

        if (fromState.id == toState.id) {
          // Self-loop
          final center = start + const Offset(0, -40);
          canvas.drawCircle(center, 20, arrowPaint);
          final arrowPoint = center + const Offset(20, -10);
          const arrowSize = 10.0;
          final p1 = arrowPoint + const Offset(-arrowSize, -arrowSize / 2);
          final p2 = arrowPoint + const Offset(-arrowSize, arrowSize / 2);
          canvas.drawLine(arrowPoint, p1, arrowPaint);
          canvas.drawLine(arrowPoint, p2, arrowPaint);

          textPainter.text = TextSpan(
            text: t.symbol,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          );
          textPainter.layout();
          textPainter.paint(canvas, center - Offset(textPainter.width / 2, -60));
        } else {
          // Check if bidirectional
          final isBidirectional = pairTransitions.length > 1;
          final isReverse = t.fromState.compareTo(t.toState) > 0;

          if (isBidirectional) {
            // Draw curved arc
            final midPoint = (start + end) / 2;
            final controlOffset = isReverse
                ? Offset(0, -50 - i * 20)
                : Offset(0, 50 + i * 20);
            final controlPoint = midPoint + controlOffset;

            final path = Path()
              ..moveTo(start.dx, start.dy)
              ..quadraticBezierTo(
                controlPoint.dx,
                controlPoint.dy,
                end.dx,
                end.dy,
              );
            canvas.drawPath(path, arrowPaint);

            // Draw arrowhead
            const arrowSize = 10.0;
            final direction = (end - controlPoint).direction;
            final arrowPoint = end - Offset.fromDirection(direction, 30);
            final p1 = arrowPoint + Offset.fromDirection(direction + 0.4, arrowSize);
            final p2 = arrowPoint + Offset.fromDirection(direction - 0.4, arrowSize);
            canvas.drawLine(arrowPoint, p1, arrowPaint);
            canvas.drawLine(arrowPoint, p2, arrowPaint);

            // Draw symbol
            textPainter.text = TextSpan(
              text: t.symbol,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
            textPainter.layout();
            final labelOffset = isReverse
                ? Offset(-textPainter.width / 2, -20 - i * 10)
                : Offset(-textPainter.width / 2, 10 + i * 10);
            textPainter.paint(canvas, controlPoint + labelOffset);
          } else {
            // Straight line
            canvas.drawLine(start, end, arrowPaint);

            const arrowSize = 10.0;
            final direction = (end - start).direction;
            final arrowPoint = end - Offset.fromDirection(direction, 30);
            final p1 = arrowPoint + Offset.fromDirection(direction + 0.4, arrowSize);
            final p2 = arrowPoint + Offset.fromDirection(direction - 0.4, arrowSize);
            canvas.drawLine(arrowPoint, p1, arrowPaint);
            canvas.drawLine(arrowPoint, p2, arrowPaint);

            final midPoint = (start + end) / 2;
            textPainter.text = TextSpan(
              text: t.symbol,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
            textPainter.layout();
            textPainter.paint(canvas, midPoint - Offset(textPainter.width / 2, -20));
          }
        }
      }
    }

    // Draw states
    final statePaint = Paint();
    final selectedPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var state in states) {
      statePaint.color = Colors.white;
      statePaint.style = PaintingStyle.fill;
      canvas.drawCircle(state.position, 30, statePaint);
      statePaint.color = Colors.black;
      statePaint.style = PaintingStyle.stroke;
      statePaint.strokeWidth = 2.0;
      canvas.drawCircle(state.position, 30, statePaint);

      if (state.id == selectedStateId) {
        canvas.drawCircle(state.position, 34, selectedPaint);
      }

      if (state.isStart) {
        final path = Path()
          ..moveTo(state.position.dx - 50, state.position.dy - 20)
          ..lineTo(state.position.dx - 50, state.position.dy + 20)
          ..lineTo(state.position.dx - 30, state.position.dy)
          ..close();
        canvas.drawPath(path, Paint()..color = Colors.green);
      }

      if (state.isAccept) {
        canvas.drawCircle(state.position, 25, statePaint);
      }

      textPainter.text = TextSpan(
        text: state.id,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        state.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant AutomatonPainter oldDelegate) {
    return oldDelegate.states != states ||
        oldDelegate.transitions != transitions ||
        oldDelegate.selectedStateId != selectedStateId ||
        oldDelegate.gridSize != gridSize;
  }
}
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({Key? key, this.size = 96}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppLogoPainter(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  final Color color;
  _AppLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    // Diamond
    final diamondSize = size.width * 0.28;
    final diamondCenter = Offset(size.width * 0.28, size.height * 0.5);
    final diamondPath = Path()
      ..moveTo(diamondCenter.dx, diamondCenter.dy - diamondSize)
      ..lineTo(diamondCenter.dx + diamondSize, diamondCenter.dy)
      ..lineTo(diamondCenter.dx, diamondCenter.dy + diamondSize)
      ..lineTo(diamondCenter.dx - diamondSize, diamondCenter.dy)
      ..close();
    canvas.drawPath(diamondPath, paint);

    // Square
    final squareSize = size.width * 0.22;
    final squareTopLeft = Offset(size.width * 0.62, size.height * 0.5 - squareSize);
    final squareRect = Rect.fromLTWH(squareTopLeft.dx, squareTopLeft.dy, squareSize * 2, squareSize * 2);
    canvas.drawRect(squareRect, paint);

    // Arrow (curved)
    final arrowPath = Path();
    arrowPath.moveTo(diamondCenter.dx + diamondSize * 0.7, diamondCenter.dy - diamondSize * 0.7);
    arrowPath.cubicTo(
      size.width * 0.55, size.height * 0.1,
      size.width * 0.85, size.height * 0.25,
      squareTopLeft.dx + squareSize * 2, squareTopLeft.dy + squareSize * 0.5,
    );
    // Arrowhead
    final arrowHeadLen = size.width * 0.13;
    final arrowAngle = -0.3;
    final arrowEnd = Offset(squareTopLeft.dx + squareSize * 2, squareTopLeft.dy + squareSize * 0.5);
    final arrowHead1 = Offset(
      arrowEnd.dx - arrowHeadLen * 0.8,
      arrowEnd.dy - arrowHeadLen * 0.5,
    );
    final arrowHead2 = Offset(
      arrowEnd.dx - arrowHeadLen * 0.8,
      arrowEnd.dy + arrowHeadLen * 0.5,
    );
    canvas.drawPath(arrowPath, paint);
    canvas.drawLine(arrowEnd, arrowHead1, paint);
    canvas.drawLine(arrowEnd, arrowHead2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
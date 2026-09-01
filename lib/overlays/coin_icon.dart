import 'package:flutter/material.dart';

/// A small gold coin drawn to match the in-game coin, since the 🪙 emoji
/// always renders in its own fixed colours.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _CoinPainter());
  }
}

class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF9A825));
    canvas.drawCircle(c, r * 0.72, Paint()..color = const Color(0xFFFDD835));
    canvas.drawCircle(
      c.translate(-r * 0.28, -r * 0.32),
      r * 0.22,
      Paint()..color = const Color(0xFFFFF9C4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

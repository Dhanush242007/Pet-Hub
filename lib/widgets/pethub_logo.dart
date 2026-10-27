import 'package:flutter/material.dart';

/// A cute puppy face drawn in code. Use PetHubLogo(size: 100) anywhere.
class PetHubLogo extends StatelessWidget {
  final double size;
  const PetHubLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    Offset p(double x, double y) => Offset(x * w, y * w);
    final fill = Paint()..style = PaintingStyle.fill;

    // Background: rounded square with a warm gradient
    final rect = Rect.fromLTWH(0, 0, w, w);
    fill.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFC46B), Color(0xFFFF6B6B)],
    ).createShader(rect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(w * 0.28)), fill);
    fill.shader = null;

    // Floppy ears
    fill.color = const Color(0xFF8D5A3B);
    void ear(Offset c, double angle) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: w * 0.22, height: w * 0.38),
          fill);
      canvas.restore();
    }

    ear(p(0.25, 0.38), 0.35);
    ear(p(0.75, 0.38), -0.35);

    // Head and muzzle
    fill.color = const Color(0xFFFFF3E0);
    canvas.drawCircle(p(0.5, 0.54), w * 0.30, fill);
    fill.color = Colors.white;
    canvas.drawOval(
        Rect.fromCenter(center: p(0.5, 0.64), width: w * 0.30, height: w * 0.22),
        fill);

    // Cheeks
    fill.color = const Color(0x66FF6B8B);
    canvas.drawCircle(p(0.31, 0.60), w * 0.045, fill);
    canvas.drawCircle(p(0.69, 0.60), w * 0.045, fill);

    // Eyes with shine
    const dark = Color(0xFF3B2A20);
    fill.color = dark;
    canvas.drawCircle(p(0.40, 0.49), w * 0.042, fill);
    canvas.drawCircle(p(0.60, 0.49), w * 0.042, fill);
    fill.color = Colors.white;
    canvas.drawCircle(p(0.412, 0.478), w * 0.014, fill);
    canvas.drawCircle(p(0.612, 0.478), w * 0.014, fill);

    // Tongue
    fill.color = const Color(0xFFFF8FA3);
    canvas.drawOval(
        Rect.fromCenter(center: p(0.5, 0.705), width: w * 0.075, height: w * 0.065),
        fill);

    // Nose
    fill.color = dark;
    canvas.drawOval(
        Rect.fromCenter(center: p(0.5, 0.595), width: w * 0.105, height: w * 0.07),
        fill);

    // Smile
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..color = dark
      ..strokeWidth = w * 0.016
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(p(0.5, 0.63).dx, p(0.5, 0.63).dy)
      ..lineTo(p(0.5, 0.668).dx, p(0.5, 0.668).dy)
      ..moveTo(p(0.5, 0.668).dx, p(0.5, 0.668).dy)
      ..quadraticBezierTo(p(0.47, 0.705).dx, p(0.47, 0.705).dy,
          p(0.43, 0.67).dx, p(0.43, 0.67).dy)
      ..moveTo(p(0.5, 0.668).dx, p(0.5, 0.668).dy)
      ..quadraticBezierTo(p(0.53, 0.705).dx, p(0.53, 0.705).dy,
          p(0.57, 0.67).dx, p(0.57, 0.67).dy);
    canvas.drawPath(mouth, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
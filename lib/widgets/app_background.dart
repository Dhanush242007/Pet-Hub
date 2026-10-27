import 'package:flutter/material.dart';

/// Soft gradient + faint paw prints. On wide screens the page is shown
/// inside a centered rounded card so the sides are not empty.
class AppBackground extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;

  const AppBackground({
    super.key,
    required this.child,
    this.maxContentWidth = 1000,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > maxContentWidth + 80;

      Widget content = child;
      if (wide) {
        content = Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 8))
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE6D5),
                  Color(0xFFFFF8F2),
                  Color(0xFFFFEAD9),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _PawPatternPainter(color: primary.withValues(alpha: 0.08)),
            ),
          ),
          content,
        ],
      );
    });
  }
}

class _PawPatternPainter extends CustomPainter {
  final Color color;
  const _PawPatternPainter({required this.color});

  void _paw(Canvas c, Paint p, Offset center, double s, double angle) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    c.drawOval(
        Rect.fromCenter(center: Offset(0, s * 0.25), width: s * 0.9, height: s * 0.75),
        p);
    c.drawCircle(Offset(-s * 0.5, -s * 0.25), s * 0.2, p);
    c.drawCircle(Offset(-s * 0.18, -s * 0.55), s * 0.2, p);
    c.drawCircle(Offset(s * 0.18, -s * 0.55), s * 0.2, p);
    c.drawCircle(Offset(s * 0.5, -s * 0.25), s * 0.2, p);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const gap = 130.0;
    int row = 0;
    for (double y = 40; y < size.height + gap; y += gap) {
      final offset = row.isOdd ? gap / 2 : 0.0;
      int col = 0;
      for (double x = 40 + offset; x < size.width + gap; x += gap) {
        final angle = (row + col) % 2 == 0 ? -0.4 : 0.4;
        _paw(canvas, paint, Offset(x, y), 26, angle);
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _PawPatternPainter old) => old.color != color;
}

/// Wraps every page in AppBackground (used in main.dart).
class BackgroundPageTransitions extends PageTransitionsBuilder {
  const BackgroundPageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
      child: AppBackground(child: child),
    );
  }
}
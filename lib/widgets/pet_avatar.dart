import 'package:flutter/material.dart';

/// Shows the pet photo if there is one, otherwise the pet-type emoji.
class PetAvatar extends StatelessWidget {
  final String? photoUrl;
  final String emoji;
  final double radius;

  const PetAvatar({
    super.key,
    required this.photoUrl,
    required this.emoji,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = Text(emoji, style: TextStyle(fontSize: radius * 0.95));
    final url = photoUrl;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [scheme.primary, const Color(0xFFFFC46B)],
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        child: (url == null || url.isEmpty)
            ? fallback
            : ClipOval(
                child: Image.network(
                  url,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
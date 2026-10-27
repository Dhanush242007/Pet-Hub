import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? emoji;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.emoji,
  });

  String? _autoEmoji() {
    if (emoji != null) return emoji;
    if (icon == Icons.pets) return '🐾';
    if (icon == Icons.vaccines) return '💉';
    if (icon == Icons.search_off) return '🔍';
    if (icon == Icons.medical_services_outlined) return '🩺';
    if (icon == Icons.people) return '👥';
    if (icon == Icons.check_circle_outline) return '🎉';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = _autoEmoji();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.primaryContainer, const Color(0xFFFFE3B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Center(
                child: e != null
                    ? Text(e, style: const TextStyle(fontSize: 54))
                    : Icon(icon, size: 54, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: scheme.errorContainer,
              child: Icon(Icons.error_outline,
                  size: 44, color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
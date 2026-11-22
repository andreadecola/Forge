import 'package:flutter/material.dart';

/// Stato vuoto o recuperabile: testo comprensibile e azione visibile.
class ForgeMessageState extends StatelessWidget {
  const ForgeMessageState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.action,
    this.secondaryAction,
  });
  final String title, message;
  final IconData icon;
  final Widget? action, secondaryAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 112),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
          if (secondaryAction != null) ...[
            const SizedBox(height: 8),
            secondaryAction!,
          ],
        ],
      ),
    ),
  );
}

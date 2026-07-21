import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// docs/05_UX_UI_DESIGN.md seccion 6.2. Nunca se ejecuta una accion
/// derivada de una entrada del usuario sin pasar por este componente
/// (UC-04, UC-08, UC-10).
class ConfirmationCard extends StatelessWidget {
  const ConfirmationCard({
    required this.title,
    required this.summary,
    required this.onConfirm,
    required this.onCorrect,
    this.confirmLabel = 'Sí, confirmar',
    this.correctLabel = 'Corregir',
    super.key,
  });

  final String title;
  final String summary;
  final VoidCallback onConfirm;
  final VoidCallback onCorrect;
  final String confirmLabel;
  final String correctLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(summary, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onConfirm, child: Text(confirmLabel)),
        const SizedBox(height: AppDimens.spacingBetweenTargets),
        OutlinedButton(
          onPressed: onCorrect,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          ),
          child: Text(correctLabel),
        ),
      ],
    );
  }
}

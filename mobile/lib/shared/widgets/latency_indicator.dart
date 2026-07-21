import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/avatar/avatar_state.dart';
import '../../core/avatar/avatar_state_provider.dart';

/// docs/05_UX_UI_DESIGN.md seccion 6.4 (rediseñado tras ADR-008): la espera
/// real del LLM es de varios segundos, asi que solo se muestra un mensaje
/// tranquilizador si "pensando" dura mas de 5s - nunca antes, para no
/// generar ruido visual en respuestas rapidas.
class LatencyIndicator extends ConsumerStatefulWidget {
  const LatencyIndicator({super.key});

  static const reassuranceDelay = Duration(seconds: 5);

  @override
  ConsumerState<LatencyIndicator> createState() => _LatencyIndicatorState();
}

class _LatencyIndicatorState extends ConsumerState<LatencyIndicator> {
  Timer? _timer;
  bool _showMessage = false;

  void _onAvatarStateChanged(AvatarState? previous, AvatarState next) {
    _timer?.cancel();
    if (next == AvatarState.thinking) {
      setState(() => _showMessage = false);
      _timer = Timer(LatencyIndicator.reassuranceDelay, () {
        if (mounted) setState(() => _showMessage = true);
      });
    } else if (_showMessage) {
      setState(() => _showMessage = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AvatarState>(avatarStateProvider, _onAvatarStateChanged);

    if (!_showMessage) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Estoy pensando tu respuesta...',
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

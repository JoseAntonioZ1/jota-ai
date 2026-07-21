import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/avatar/avatar_state.dart';
import '../../core/avatar/avatar_state_provider.dart';

/// docs/05_UX_UI_DESIGN.md seccion 6.1. Placeholder visual (sin Rive
/// todavia, ver docs/10_DEVELOPMENT_ROADMAP.md Fase 8): un circulo animado
/// que cambia de color/icono/texto segun el estado, para no bloquear el
/// resto de la Fase 3 esperando los assets finales del avatar.
class AvatarWidget extends ConsumerStatefulWidget {
  const AvatarWidget({super.key});

  @override
  ConsumerState<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends ConsumerState<AvatarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(avatarStateProvider);
    final config = _configFor(state);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = state == AvatarState.idle
                ? 1.0
                : 1.0 + (_pulseController.value * 0.06);
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 140,
            height: 140,
            decoration: BoxDecoration(color: config.color, shape: BoxShape.circle),
            child: Icon(config.icon, size: 64, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          config.label,
          style: Theme.of(context).textTheme.bodyLarge,
          semanticsLabel: config.label,
        ),
      ],
    );
  }

  _AvatarVisualConfig _configFor(AvatarState state) {
    switch (state) {
      case AvatarState.idle:
        return const _AvatarVisualConfig(
          color: Color(0xFF9E9E9E),
          icon: Icons.favorite_outline,
          label: 'Esperando tu mensaje',
        );
      case AvatarState.listening:
        return const _AvatarVisualConfig(
          color: Color(0xFF2E5AAC),
          icon: Icons.mic,
          label: 'Escuchando...',
        );
      case AvatarState.thinking:
        return const _AvatarVisualConfig(
          color: Color(0xFFB8860B),
          icon: Icons.hourglass_top,
          label: 'Pensando...',
        );
      case AvatarState.speaking:
        return const _AvatarVisualConfig(
          color: Color(0xFF2E7D32),
          icon: Icons.chat_bubble_outline,
          label: 'Hablando...',
        );
    }
  }
}

class _AvatarVisualConfig {
  const _AvatarVisualConfig({required this.color, required this.icon, required this.label});

  final Color color;
  final IconData icon;
  final String label;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'avatar_state.dart';

/// Estado compartido del avatar (docs/06_SYSTEM_ARCHITECTURE.md seccion 6):
/// varias features (conversacion, y en el futuro recordatorios/emergencia)
/// lo consumen para reflejar feedback visual consistente.
final avatarStateProvider = StateProvider<AvatarState>((ref) => AvatarState.idle);

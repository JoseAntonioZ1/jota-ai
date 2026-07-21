import 'package:go_router/go_router.dart';

import '../../shared/widgets/placeholder_screen.dart';

/// Rutas definidas en docs/05_UX_UI_DESIGN.md, seccion 4.
/// Todas apuntan a PlaceholderScreen hasta que su fase del roadmap
/// (docs/10_DEVELOPMENT_ROADMAP.md) implemente la pantalla real.
final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const PlaceholderScreen(title: 'Configuracion inicial'),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const PlaceholderScreen(title: 'JOTA'),
    ),
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const PlaceholderScreen(title: 'Recordatorios'),
    ),
    GoRoute(
      path: '/reminders/new',
      builder: (context, state) => const PlaceholderScreen(title: 'Nuevo recordatorio'),
    ),
    GoRoute(
      path: '/reminders/:id/edit',
      builder: (context, state) => const PlaceholderScreen(title: 'Editar recordatorio'),
    ),
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const PlaceholderScreen(title: 'Contactos frecuentes'),
    ),
    GoRoute(
      path: '/contacts/new',
      builder: (context, state) => const PlaceholderScreen(title: 'Nuevo contacto'),
    ),
    GoRoute(
      path: '/contacts/:id/edit',
      builder: (context, state) => const PlaceholderScreen(title: 'Editar contacto'),
    ),
    GoRoute(
      path: '/settings/emergency-contact',
      builder: (context, state) => const PlaceholderScreen(title: 'Contacto de emergencia'),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const PlaceholderScreen(title: 'Historial'),
    ),
  ],
);

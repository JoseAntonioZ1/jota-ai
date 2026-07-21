import 'package:go_router/go_router.dart';

import '../../features/conversation/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reminders/domain/reminder.dart';
import '../../features/reminders/presentation/reminder_form_screen.dart';
import '../../features/reminders/presentation/reminders_list_screen.dart';
import '../../shared/widgets/placeholder_screen.dart';

/// Rutas definidas en docs/05_UX_UI_DESIGN.md, seccion 4.
/// Las pantallas implementadas en la Fase 3 (onboarding, home) tienen su
/// widget real; el resto sigue en PlaceholderScreen hasta su fase del
/// roadmap (docs/10_DEVELOPMENT_ROADMAP.md).
final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const RemindersListScreen(),
    ),
    GoRoute(
      path: '/reminders/new',
      builder: (context, state) => const ReminderFormScreen(),
    ),
    GoRoute(
      path: '/reminders/:id/edit',
      builder: (context, state) =>
          ReminderFormScreen(existingReminder: state.extra as Reminder?),
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

import 'package:go_router/go_router.dart';

import '../../features/contacts/domain/contact.dart';
import '../../features/contacts/presentation/contact_form_screen.dart';
import '../../features/contacts/presentation/contacts_list_screen.dart';
import '../../features/conversation/presentation/home_screen.dart';
import '../../features/emergency/presentation/emergency_contact_settings_screen.dart';
import '../../features/history/presentation/conversation_detail_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reminders/domain/reminder.dart';
import '../../features/reminders/presentation/reminder_form_screen.dart';
import '../../features/reminders/presentation/reminders_list_screen.dart';

/// Rutas definidas en docs/05_UX_UI_DESIGN.md, seccion 4, mas
/// `/history/:id` (detalle de conversacion, UC-11) agregada en la Fase 7
/// como extension consistente del patron ya usado por recordatorios y
/// contactos.
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
      builder: (context, state) => const ContactsListScreen(),
    ),
    GoRoute(
      path: '/contacts/new',
      builder: (context, state) => const ContactFormScreen(),
    ),
    GoRoute(
      path: '/contacts/:id/edit',
      builder: (context, state) =>
          ContactFormScreen(existingContact: state.extra as Contact?),
    ),
    GoRoute(
      path: '/settings/emergency-contact',
      builder: (context, state) => const EmergencyContactSettingsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) =>
          ConversationDetailScreen(conversationId: state.pathParameters['id']!),
    ),
  ],
);

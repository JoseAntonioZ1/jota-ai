import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/calling/dialer.dart';
import '../../core/theme/app_theme.dart';
import '../../features/contacts/domain/contact.dart';
import '../../features/contacts/presentation/contacts_controller.dart';
import '../../features/emergency/presentation/emergency_providers.dart';
import 'confirmation_card.dart';

/// docs/05_UX_UI_DESIGN.md seccion 6.3: componente global, color exclusivo,
/// visible desde las pantallas principales (UC-10). El color rojo se usa
/// unicamente aqui en toda la interfaz.
class EmergencyButton extends ConsumerWidget {
  const EmergencyButton({this.dialer = defaultDialer, super.key});

  final Dialer dialer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => _onPressed(context, ref),
      icon: const Icon(Icons.emergency, color: AppColors.emergency),
      tooltip: 'Emergencia',
    );
  }

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    final contact = await ref.read(emergencyRepositoryProvider).getEmergencyContact();
    if (!context.mounted) return;

    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero configura un contacto de emergencia.')),
      );
      context.push('/settings/emergency-contact');
      return;
    }

    final confirmed = await _confirm(context, contact);
    if (confirmed != true || !context.mounted) return;

    try {
      await dialer(phoneUri(contact.phoneNumber));
    } catch (_) {
      // Sin capacidad de llamada nativa en esta plataforma (p. ej. Windows
      // en desarrollo): no bloquea el registro del intento.
    }
    await ref.read(contactRepositoryProvider).logCall(contact.id, callType: 'emergency');
  }

  Future<bool?> _confirm(BuildContext context, Contact contact) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: ConfirmationCard(
            title: '¿Llamar ahora a ${contact.name}?',
            summary: contact.phoneNumber,
            confirmLabel: 'Sí, llamar',
            correctLabel: 'Cancelar',
            onConfirm: () => Navigator.of(dialogContext).pop(true),
            onCorrect: () => Navigator.of(dialogContext).pop(false),
          ),
        ),
      ),
    );
  }
}

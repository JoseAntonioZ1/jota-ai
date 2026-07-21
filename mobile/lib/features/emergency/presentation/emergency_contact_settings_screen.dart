import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../contacts/domain/contact.dart';
import '../../contacts/presentation/contacts_controller.dart';
import 'emergency_providers.dart';

/// docs/04_USE_CASES.md UC-09.
class EmergencyContactSettingsScreen extends ConsumerWidget {
  const EmergencyContactSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsControllerProvider);
    final currentAsync = ref.watch(emergencyContactProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacto de emergencia')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: contactsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'No pude cargar tus contactos. Intenta de nuevo.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          data: (contacts) {
            if (contacts.isEmpty) {
              return Center(
                child: Text(
                  'Primero agrega un contacto frecuente para poder elegirlo '
                  'como tu contacto de emergencia.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Elige a quién debe llamar JOTA si tocas el botón de emergencia.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: currentAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => const SizedBox.shrink(),
                    data: (current) => ListView.separated(
                      itemCount: contacts.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimens.spacingBetweenTargets),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return _EmergencyContactOption(
                          contact: contact,
                          selected: current?.id == contact.id,
                          onTap: () => _select(context, ref, contact),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref, Contact contact) async {
    await ref.read(emergencyRepositoryProvider).setEmergencyContact(contact.id);
    ref.invalidate(emergencyContactProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.name} es ahora tu contacto de emergencia.')),
      );
    }
  }
}

class _EmergencyContactOption extends StatelessWidget {
  const _EmergencyContactOption({
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final Contact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFE3E3) : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(contact.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppColors.emergency),
            ],
          ),
        ),
      ),
    );
  }
}

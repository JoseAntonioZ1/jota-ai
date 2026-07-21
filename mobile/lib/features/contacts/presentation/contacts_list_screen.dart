import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/contact.dart';
import 'contacts_controller.dart';

/// docs/04_USE_CASES.md UC-07.
class ContactsListScreen extends ConsumerWidget {
  const ContactsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contactos frecuentes')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                        'Aún no tienes contactos frecuentes. Toca "Nuevo contacto" '
                        'para agregar uno.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.spacingBetweenTargets),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _ContactTile(
                        contact: contact,
                        onTap: () =>
                            context.push('/contacts/${contact.id}/edit', extra: contact),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/contacts/new'),
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo contacto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact, required this.onTap});

  final Contact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0),
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
              const Icon(Icons.edit, semanticLabel: 'Editar'),
            ],
          ),
        ),
      ),
    );
  }
}

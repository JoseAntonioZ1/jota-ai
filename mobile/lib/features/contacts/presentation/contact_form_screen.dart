import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/contact.dart';
import 'contacts_controller.dart';

/// docs/04_USE_CASES.md UC-07. A diferencia de recordatorios, no requiere
/// ConfirmationCard: es una entrada directa del usuario, no una intencion
/// extraida de lenguaje natural (esa distincion es la que documenta
/// docs/05_UX_UI_DESIGN.md seccion 6.2).
class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({this.existingContact, super.key});

  final Contact? existingContact;

  bool get isEditing => existingContact != null;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  late final _nameController = TextEditingController(text: widget.existingContact?.name ?? '');
  late final _phoneController = TextEditingController(
    text: widget.existingContact?.phoneNumber ?? '',
  );
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _phoneController.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final controller = ref.read(contactsControllerProvider.notifier);
    try {
      if (widget.isEditing) {
        await controller.update(
          id: widget.existingContact!.id,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
      } else {
        await controller.create(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
      }
      if (mounted) context.pop();
    } on ApiException catch (exception) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message)));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar este contacto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final emergencyCleared = await ref
        .read(contactsControllerProvider.notifier)
        .delete(widget.existingContact!.id);
    if (!mounted) return;

    context.pop();
    if (emergencyCleared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ese era tu contacto de emergencia. Elige uno nuevo cuando puedas.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar contacto' : 'Nuevo contacto'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nombre', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text('Número de teléfono', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: TextInputType.phone,
                  ),
                  const Spacer(),
                  ElevatedButton(onPressed: _canSave ? _save : null, child: const Text('Guardar')),
                ],
              ),
      ),
    );
  }
}

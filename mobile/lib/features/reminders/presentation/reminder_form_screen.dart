import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/confirmation_card.dart';
import '../domain/reminder.dart';
import 'reminders_controller.dart';
import 'reminders_list_screen.dart' show formatReminderDateTime;

/// docs/04_USE_CASES.md UC-04 (crear) y UC-05 (editar/eliminar).
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({this.existingReminder, super.key});

  final Reminder? existingReminder;

  bool get isEditing => existingReminder != null;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  late final _descriptionController = TextEditingController(
    text: widget.existingReminder?.description ?? '',
  );
  late ReminderType _reminderType = widget.existingReminder?.reminderType ?? ReminderType.medication;
  late DateTime _scheduledAt =
      widget.existingReminder?.scheduledAt ?? DateTime.now().add(const Duration(hours: 1));

  bool _showConfirmation = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final controller = ref.read(remindersControllerProvider.notifier);
    try {
      if (widget.isEditing) {
        await controller.update(
          id: widget.existingReminder!.id,
          description: _descriptionController.text.trim(),
          reminderType: _reminderType,
          scheduledAt: _scheduledAt,
        );
      } else {
        await controller.create(
          description: _descriptionController.text.trim(),
          reminderType: _reminderType,
          scheduledAt: _scheduledAt,
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
        title: const Text('¿Eliminar este recordatorio?'),
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

    await ref.read(remindersControllerProvider.notifier).delete(widget.existingReminder!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar recordatorio' : 'Nuevo recordatorio'),
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
        child: _showConfirmation ? _buildConfirmation(context) : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final canContinue = _descriptionController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('¿Qué quieres recordar?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        TextField(controller: _descriptionController, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text('¿Qué tipo de recordatorio es?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        SegmentedButton<ReminderType>(
          segments: ReminderType.values
              .map((type) => ButtonSegment(value: type, label: Text(type.label)))
              .toList(),
          selected: {_reminderType},
          onSelectionChanged: (selection) => setState(() => _reminderType = selection.first),
        ),
        const SizedBox(height: 24),
        Text('¿Cuándo?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _pickDateTime,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppDimens.minTouchTarget),
          ),
          child: Text(formatReminderDateTime(_scheduledAt)),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: canContinue ? () => setState(() => _showConfirmation = true) : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    return Center(
      child: _isSaving
          ? const CircularProgressIndicator()
          : ConfirmationCard(
              title: '¿Es correcto?',
              summary:
                  '"${_descriptionController.text.trim()}"\n'
                  '${_reminderType.label} · ${formatReminderDateTime(_scheduledAt)}',
              onConfirm: _save,
              onCorrect: () => setState(() => _showConfirmation = false),
            ),
    );
  }
}

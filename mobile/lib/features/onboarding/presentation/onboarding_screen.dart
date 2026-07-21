import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_providers.dart';

/// docs/04_USE_CASES.md UC-01: presentacion, permisos, nombre, y nota de
/// contacto de emergencia (pospuesto: la gestion de contactos aun no existe
/// en el backend - Fase 5/6 del roadmap - por eso aqui solo se informa,
/// sin bloquear el onboarding, consistente con el flujo alternativo 5a).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalSteps = 4;

  int _step = 0;
  bool _loading = true;
  String? _errorMessage;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reconstruye para habilitar/deshabilitar "Continuar" segun el nombre.
    _nameController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final existing = await repository.getExistingProfile();

      if (existing != null && existing.onboardingCompleted) {
        if (mounted) context.go('/home');
        return;
      }
      if (existing == null) {
        await repository.registerDevice();
      }
      setState(() => _loading = false);
    } on ApiException catch (exception) {
      setState(() {
        _loading = false;
        _errorMessage = exception.message;
      });
    }
  }

  Future<void> _requestMicrophonePermission() async {
    // NFR-24: el objetivo real es Android; en desktop no aplica el modelo
    // de permisos en tiempo de ejecucion de permission_handler.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Permission.microphone.request();
    }
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(onboardingRepositoryProvider).completeOnboarding(name: name);
      if (mounted) context.go('/home');
    } on ApiException catch (exception) {
      setState(() {
        _loading = false;
        _errorMessage = exception.message;
      });
    }
  }

  void _next() => setState(() => _step = (_step + 1).clamp(0, _totalSteps - 1));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración inicial')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
            ],
            Expanded(child: _buildStep(context)),
            const SizedBox(height: 24),
            _buildPrimaryAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return const _StepContent(
          title: 'Hola, soy JOTA',
          body:
              'Estoy aquí para ayudarte con tu teléfono: puedes hablarme o '
              'escribirme, y te ayudo con recordatorios, contactos y más.',
        );
      case 1:
        return const _StepContent(
          title: 'Necesito tu permiso',
          body:
              'Para poder escucharte cuando me hables, necesito acceso al '
              'micrófono de tu teléfono.',
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cómo te llamas?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(hintText: 'Tu nombre'),
            ),
          ],
        );
      default:
        return const _StepContent(
          title: 'Contacto de emergencia',
          body:
              'Más adelante podrás configurar un contacto de emergencia '
              'para llamarlo rápidamente. Por ahora, ¡ya podemos empezar!',
        );
    }
  }

  Widget _buildPrimaryAction() {
    if (_step == 1) {
      return ElevatedButton(
        onPressed: () async {
          await _requestMicrophonePermission();
          _next();
        },
        child: const Text('Permitir y continuar'),
      );
    }
    if (_step == _totalSteps - 1) {
      return ElevatedButton(onPressed: _finish, child: const Text('Empezar'));
    }
    final canContinue = _step != 2 || _nameController.text.trim().isNotEmpty;
    return ElevatedButton(
      onPressed: canContinue ? _next : null,
      child: const Text('Continuar'),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

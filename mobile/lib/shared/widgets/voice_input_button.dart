import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/theme/app_theme.dart';

/// docs/05_UX_UI_DESIGN.md seccion 6.5 y docs/07_AI_ARCHITECTURE.md
/// seccion 6.1: "mantener presionado para hablar, soltar para enviar" en
/// vez de deteccion automatica de fin de habla (ADR-007).
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({required this.onRecorded, this.onError, super.key});

  final void Function(List<int> audioBytes) onRecorded;

  /// Se dispara si no se pudo grabar (p. ej. sin microfono disponible en
  /// el dispositivo, o permiso denegado). FR-01.4: el llamador debe
  /// mostrar un mensaje amigable, nunca el detalle tecnico.
  final void Function()? onError;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _recorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) return;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/jota_voice_input.wav';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
        path: path,
      );
      if (mounted) setState(() => _isRecording = true);
    } catch (_) {
      // Sin microfono disponible u otro fallo de hardware/permiso: no se
      // deja la app en un estado inconsistente de "grabando".
      widget.onError?.call();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _recorder.stop();
      if (mounted) setState(() => _isRecording = false);
      if (path == null || !await File(path).exists()) {
        widget.onError?.call();
        return;
      }

      final bytes = await File(path).readAsBytes();
      widget.onRecorded(bytes);
    } catch (_) {
      if (mounted) setState(() => _isRecording = false);
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: _stopRecording,
      child: CircleAvatar(
        radius: 36,
        backgroundColor: _isRecording ? AppColors.emergency : AppColors.primary,
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 32,
          semanticLabel: _isRecording ? 'Grabando' : 'Mantén presionado para hablar',
        ),
      ),
    );
  }
}

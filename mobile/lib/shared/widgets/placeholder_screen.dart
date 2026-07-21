import 'package:flutter/material.dart';

/// Pantalla temporal usada durante la Fase 0 (setup de infraestructura).
/// Cada ruta se reemplaza por su pantalla real en la fase del roadmap
/// correspondiente (docs/10_DEVELOPMENT_ROADMAP.md).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(pendiente de implementar)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

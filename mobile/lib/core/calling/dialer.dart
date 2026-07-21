import 'package:url_launcher/url_launcher.dart';

/// Inicia una llamada nativa. Inyectable (usado por ConversationController
/// y EmergencyButton) para poder sustituirlo en pruebas, donde no hay
/// canal de plataforma registrado para url_launcher.
typedef Dialer = Future<void> Function(Uri uri);

Future<void> defaultDialer(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Uri phoneUri(String phoneNumber) => Uri(scheme: 'tel', path: phoneNumber);

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/avatar/avatar_state.dart';
import '../../../core/avatar/avatar_state_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_provider.dart';
import '../../contacts/domain/contact.dart';
import '../../contacts/domain/contact_repository.dart';
import '../../contacts/presentation/contacts_controller.dart';
import '../data/conversation_repository_impl.dart';
import '../domain/chat_message.dart';
import '../domain/conversation_repository.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

class ConversationControllerState {
  const ConversationControllerState({
    this.messages = const [],
    this.conversationId,
    this.errorMessage,
    this.pendingCall,
  });

  final List<ChatMessage> messages;
  final String? conversationId;
  final String? errorMessage;

  /// UC-08: contacto encontrado a partir de un "llama a X" detectado en la
  /// conversacion, pendiente de confirmacion del usuario antes de llamar.
  final Contact? pendingCall;

  ConversationControllerState copyWith({
    List<ChatMessage>? messages,
    String? conversationId,
    String? errorMessage,
    Object? pendingCall = _unset,
  }) {
    return ConversationControllerState(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      errorMessage: errorMessage,
      pendingCall: identical(pendingCall, _unset) ? this.pendingCall : pendingCall as Contact?,
    );
  }
}

const _unset = Object();

final conversationControllerProvider =
    StateNotifierProvider<ConversationController, ConversationControllerState>((ref) {
      return ConversationController(
        ref.watch(conversationRepositoryProvider),
        ref.watch(contactRepositoryProvider),
        ref,
      );
    });

/// Inicia una llamada nativa al numero dado. Inyectable para pruebas: en
/// plataformas de escritorio sin telefono (o en tests, sin canal de
/// plataforma registrado) simplemente no hay nada que llamar.
Future<void> _defaultDialer(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

class ConversationController extends StateNotifier<ConversationControllerState> {
  ConversationController(
    this._repository,
    this._contactRepository,
    this._ref, {
    Future<void> Function(Uri uri) dialer = _defaultDialer,
  }) : _dialer = dialer,
       super(const ConversationControllerState());

  final ConversationRepository _repository;
  final ContactRepository _contactRepository;
  final Future<void> Function(Uri uri) _dialer;
  final Ref _ref;
  final _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> sendText(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: MessageRole.user, content: trimmed)],
      errorMessage: null,
    );
    _setAvatar(AvatarState.thinking);

    try {
      final result = await _repository.sendTextMessage(
        conversationId: state.conversationId,
        message: trimmed,
      );
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: MessageRole.assistant, content: result.reply),
        ],
        conversationId: result.conversationId,
      );
      _setAvatar(AvatarState.idle);
      await _handleIntent(result);
    } on ApiException catch (exception) {
      state = state.copyWith(errorMessage: _friendlyError(exception));
      _setAvatar(AvatarState.idle);
    }
  }

  Future<void> sendVoice(List<int> audioBytes) async {
    state = state.copyWith(errorMessage: null);
    _setAvatar(AvatarState.thinking);

    try {
      final result = await _repository.sendVoiceMessage(
        conversationId: state.conversationId,
        audioBytes: audioBytes,
      );

      final messages = [...state.messages];
      if (result.transcript.isNotEmpty) {
        messages.add(ChatMessage(role: MessageRole.user, content: result.transcript));
      }
      messages.add(ChatMessage(role: MessageRole.assistant, content: result.reply));
      state = state.copyWith(messages: messages, conversationId: result.conversationId);

      await _playReply(result.audioBytes);
      _setAvatar(AvatarState.idle);
      await _handleIntent(result);
    } on ApiException catch (exception) {
      state = state.copyWith(errorMessage: _friendlyError(exception));
      _setAvatar(AvatarState.idle);
    }
  }

  /// UC-08: si JOTA detecto la intencion de llamar a alguien, se busca el
  /// contacto entre los frecuentes. Nunca se llama directamente - solo se
  /// deja pendiente de confirmacion (ConfirmationCard en HomeScreen).
  Future<void> _handleIntent(TurnResult result) async {
    if (result.intent != 'call_contact') return;

    final name = _extractContactName(result.entities);
    if (name == null || name.trim().isEmpty) return;

    final contacts = await _contactRepository.listContacts();
    final match = _findContact(contacts, name);

    if (match == null) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: MessageRole.assistant,
            content:
                'No encontré a "$name" en tus contactos frecuentes. '
                'Puedes revisarlos en la sección de Contactos.',
          ),
        ],
      );
      return;
    }

    state = state.copyWith(pendingCall: match);
  }

  Future<void> confirmPendingCall() async {
    final contact = state.pendingCall;
    if (contact == null) return;

    state = state.copyWith(pendingCall: null);
    try {
      await _dialer(Uri(scheme: 'tel', path: contact.phoneNumber));
    } catch (_) {
      // Sin capacidad de llamada nativa en esta plataforma (p. ej. Windows
      // en desarrollo): no bloquea el registro del intento en el historial.
    }
    await _contactRepository.logCall(contact.id);
  }

  void dismissPendingCall() {
    state = state.copyWith(pendingCall: null);
  }

  String? _extractContactName(Map<String, dynamic> entities) {
    for (final key in ['contact_name', 'contact', 'name']) {
      final value = entities[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Contact? _findContact(List<Contact> contacts, String name) {
    final needle = name.toLowerCase();
    for (final contact in contacts) {
      final haystack = contact.name.toLowerCase();
      if (haystack.contains(needle) || needle.contains(haystack.split(' ').first)) {
        return contact;
      }
    }
    return null;
  }

  Future<void> _playReply(List<int> audioBytes) async {
    _setAvatar(AvatarState.speaking);
    await _player.play(BytesSource(Uint8List.fromList(audioBytes)));
    await _player.onPlayerComplete.first;
  }

  void _setAvatar(AvatarState value) {
    _ref.read(avatarStateProvider.notifier).state = value;
  }

  /// FR-01.4: nunca lenguaje tecnico complejo en los mensajes de error.
  String _friendlyError(ApiException exception) {
    switch (exception.code) {
      case 'ai_provider_timeout':
        return 'No pude responder a tiempo. ¿Puedes intentar de nuevo?';
      case 'ai_provider_unavailable':
        return 'No puedo conectarme ahora. Intenta de nuevo en un momento.';
      case 'not_found':
        return 'No encontré esa conversación. Empecemos una nueva.';
      case 'invalid_token':
        return 'Necesito que vuelvas a configurar la app.';
      default:
        return 'Algo salió mal. Intenta de nuevo.';
    }
  }
}

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/avatar/avatar_state.dart';
import '../../../core/avatar/avatar_state_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_client_provider.dart';
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
  });

  final List<ChatMessage> messages;
  final String? conversationId;
  final String? errorMessage;

  ConversationControllerState copyWith({
    List<ChatMessage>? messages,
    String? conversationId,
    String? errorMessage,
  }) {
    return ConversationControllerState(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      errorMessage: errorMessage,
    );
  }
}

final conversationControllerProvider =
    StateNotifierProvider<ConversationController, ConversationControllerState>((ref) {
      return ConversationController(ref.watch(conversationRepositoryProvider), ref);
    });

class ConversationController extends StateNotifier<ConversationControllerState> {
  ConversationController(this._repository, this._ref)
    : super(const ConversationControllerState());

  final ConversationRepository _repository;
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
    } on ApiException catch (exception) {
      state = state.copyWith(errorMessage: _friendlyError(exception));
      _setAvatar(AvatarState.idle);
    }
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

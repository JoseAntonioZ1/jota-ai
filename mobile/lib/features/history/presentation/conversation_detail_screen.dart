import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/history_message.dart';
import 'history_providers.dart';

/// docs/04_USE_CASES.md UC-11, paso 3: contenido completo de una conversacion.
class ConversationDetailScreen extends ConsumerWidget {
  const ConversationDetailScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(conversationMessagesProvider(conversationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Conversación')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: messagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'No pude cargar esta conversación. Intenta de nuevo.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          data: (messages) => ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) => _MessageBubble(messages[index]),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(this.message);

  final HistoryMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == HistoryMessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE3EEFF) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.content, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

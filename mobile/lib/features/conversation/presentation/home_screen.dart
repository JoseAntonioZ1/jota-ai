import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/latency_indicator.dart';
import '../../../shared/widgets/voice_input_button.dart';
import '../domain/chat_message.dart';
import 'conversation_controller.dart';

/// docs/05_UX_UI_DESIGN.md seccion 7.1.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    await ref.read(conversationControllerProvider.notifier).sendText(text);
    _scrollToBottom();
  }

  Future<void> _sendVoice(List<int> audioBytes) async {
    await ref.read(conversationControllerProvider.notifier).sendVoice(audioBytes);
    _scrollToBottom();
  }

  void _showRecordingError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No pude usar el micrófono. ¿Puedes intentar de nuevo?')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationControllerProvider);

    ref.listen(conversationControllerProvider, (previous, next) {
      final changed = next.errorMessage != null && next.errorMessage != previous?.errorMessage;
      if (changed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('JOTA'),
        actions: [
          IconButton(
            onPressed: () => context.push('/reminders'),
            icon: const Icon(Icons.alarm),
            tooltip: 'Recordatorios',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          children: [
            const AvatarWidget(),
            const LatencyIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: state.messages.isEmpty
                  ? Center(
                      child: Text(
                        'Escríbeme o mantén presionado el micrófono para hablarme.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) => _MessageBubble(state.messages[index]),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                    onSubmitted: (_) => _sendText(),
                  ),
                ),
                IconButton(iconSize: 32, onPressed: _sendText, icon: const Icon(Icons.send)),
              ],
            ),
            const SizedBox(height: 12),
            Center(child: VoiceInputButton(onRecorded: _sendVoice, onError: _showRecordingError)),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(this.message);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
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

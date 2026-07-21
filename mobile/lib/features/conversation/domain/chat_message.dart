enum MessageRole { user, assistant }

class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final MessageRole role;
  final String content;
}

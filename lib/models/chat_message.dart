enum ChatRole {
  user,
  assistant;

  String get wire => switch (this) {
        ChatRole.user => 'user',
        ChatRole.assistant => 'assistant',
      };
}

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  final ChatRole role;
  final String content;
  final DateTime timestamp;
}

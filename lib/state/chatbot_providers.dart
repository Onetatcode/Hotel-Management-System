import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat_message.dart';
import '../services/chatbot_service.dart';

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  return ChatbotService();
});

/// True while a reply is being fetched, so the UI can show a typing
/// indicator without replacing the message list with a spinner.
final isSendingProvider = StateProvider<bool>((ref) => false);

final chatMessagesProvider = AsyncNotifierProvider<ChatMessagesController,
    List<ChatMessage>>(ChatMessagesController.new);

class ChatMessagesController extends AsyncNotifier<List<ChatMessage>> {
  static const _fallbackReply =
      "Sorry, I couldn't reach the assistant right now. Please try again in a moment.";

  @override
  Future<List<ChatMessage>> build() async => [
        ChatMessage(
          role: ChatRole.assistant,
          content:
              "Hi! I'm your hotel ops assistant. Ask me about using the app — "
              "rooms, availability, bookings, or guests — and I'll walk you through it.",
          timestamp: DateTime.now(),
        ),
      ];

  /// Appends the user message immediately, fetches a reply, and appends it
  /// (or a friendly fallback when the request fails — the chat never crashes).
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state.value ?? const <ChatMessage>[];
    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );
    state = AsyncData([...current, userMessage]);
    ref.read(isSendingProvider.notifier).state = true;

    try {
      final reply = await ref
          .read(chatbotServiceProvider)
          .sendChat([...current, userMessage]);
      state = AsyncData([
        ...state.value!,
        ChatMessage(
          role: ChatRole.assistant,
          content: reply,
          timestamp: DateTime.now(),
        ),
      ]);
    } catch (_) {
      state = AsyncData([
        ...state.value!,
        ChatMessage(
          role: ChatRole.assistant,
          content: _fallbackReply,
          timestamp: DateTime.now(),
        ),
      ]);
    } finally {
      ref.read(isSendingProvider.notifier).state = false;
    }
  }
}

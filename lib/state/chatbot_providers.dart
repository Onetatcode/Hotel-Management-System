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
  /// Hard cap on a single user message (OWASP LLM05 input side).
  static const int maxMessageLength = 2000;

  /// Only the most recent messages are sent to the model — bounds cost and
  /// shrinks the prompt-injection surface.
  static const int maxHistoryMessages = 20;

  static const _fallbackReply =
      "Sorry, I couldn't reach the assistant right now. Please try again in a moment.";
  static const _tooLongReply =
      'That message is too long (max $maxMessageLength characters). Please shorten it and try again.';
  static const _blockedReply =
      "I can't help with that request. I'm here for hotel operations and using this app — ask me about rooms, availability, bookings, or guests.";

  /// Instruction-override / prompt-extraction attempts (OWASP LLM01 + LLM07).
  static final List<RegExp> _jailbreakPatterns = [
    RegExp(
      r'ignore (all |any |the )?(previous|prior|above|earlier) (instructions|prompts|rules|guidelines)',
      caseSensitive: false,
    ),
    RegExp(
      r'(repeat|reveal|show|print|say) (me )?(your|the) (system )?(prompt|instructions)',
      caseSensitive: false,
    ),
    RegExp(
      r'what (are|is) (your|the) (system )?(prompt|instructions|rules)',
      caseSensitive: false,
    ),
    RegExp(
      r'developer mode|jailbreak|do anything now',
      caseSensitive: false,
    ),
  ];

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
  /// Guarded locally: blank, over-length, and jailbreak-pattern inputs never
  /// reach the API.
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

    if (trimmed.length > maxMessageLength) {
      await _appendAssistantReply(_tooLongReply);
      return;
    }
    if (_jailbreakPatterns.any((p) => p.hasMatch(trimmed))) {
      await _appendAssistantReply(_blockedReply);
      return;
    }

    ref.read(isSendingProvider.notifier).state = true;
    try {
      final history = [...current, userMessage];
      final capped = history.length > maxHistoryMessages
          ? history.sublist(history.length - maxHistoryMessages)
          : history;
      final reply = await ref.read(chatbotServiceProvider).sendChat(capped);
      await _appendAssistantReply(reply);
    } catch (_) {
      await _appendAssistantReply(_fallbackReply);
    } finally {
      ref.read(isSendingProvider.notifier).state = false;
    }
  }

  Future<void> _appendAssistantReply(String content) async {
    state = AsyncData([
      ...state.value!,
      ChatMessage(
        role: ChatRole.assistant,
        content: content,
        timestamp: DateTime.now(),
      ),
    ]);
  }
}

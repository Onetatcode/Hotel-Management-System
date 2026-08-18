import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chat_message.dart';
import '../services/assistant_usage_service.dart';
import '../services/chatbot_service.dart';
import 'auth_providers.dart';

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  return ChatbotService();
});

final assistantUsageServiceProvider = Provider<AssistantUsageService>((ref) {
  return AssistantUsageService();
});

/// Per-staff daily message quota (OWASP LLM10). Enforced against the
/// server-side usage counts returned by `update_assistant_usage`.
final assistantDailyQuotaProvider = Provider<int>((ref) => 30);

/// Minimum gap between initiated sends — stops double-tap/spam bursts.
final assistantMinSendIntervalProvider =
    Provider<Duration>((ref) => const Duration(seconds: 1));

/// After this many consecutive API failures, sends are blocked for the
/// cooldown window instead of hammering OpenRouter.
final assistantBreakerThresholdProvider = Provider<int>((ref) => 3);

/// How long the circuit breaker stays open.
final assistantBreakerCooldownProvider =
    Provider<Duration>((ref) => const Duration(seconds: 30));

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
  static const _unavailableReply =
      'The assistant is temporarily unavailable. Please try again in a few minutes.';
  static const _quotaReplyPrefix =
      "You've reached today's assistant limit of ";

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

  int _consecutiveFailures = 0;
  DateTime? _breakerBlockedUntil;
  DateTime? _lastSendAt;

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
  /// reach the API; sends are throttled, counted against the daily quota, and
  /// cut off by a circuit breaker after repeated API failures.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final minInterval = ref.read(assistantMinSendIntervalProvider);
    if (_lastSendAt != null && now.difference(_lastSendAt!) < minInterval) {
      return;
    }
    _lastSendAt = now;

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
    if (_breakerBlockedUntil != null && now.isBefore(_breakerBlockedUntil!)) {
      await _appendAssistantReply(_unavailableReply);
      return;
    }

    final staffId = await _staffIdOrNull();

    ref.read(isSendingProvider.notifier).state = true;
    try {
      if (staffId != null) {
        final quota = ref.read(assistantDailyQuotaProvider);
        final count = await _recordUsage(staffId, messageDelta: 1);
        if (count > quota) {
          await _appendAssistantReply('$_quotaReplyPrefix$quota '
              'messages. It resets tomorrow.');
          return;
        }
      }

      final history = [...current, userMessage];
      final capped = history.length > maxHistoryMessages
          ? history.sublist(history.length - maxHistoryMessages)
          : history;
      final reply = await ref.read(chatbotServiceProvider).sendChat(capped);
      _consecutiveFailures = 0;
      await _appendAssistantReply(reply);
    } catch (_) {
      _consecutiveFailures++;
      if (staffId != null) {
        await _recordUsage(staffId, messageDelta: 0, errorDelta: 1);
      }
      if (_consecutiveFailures >=
          ref.read(assistantBreakerThresholdProvider)) {
        _breakerBlockedUntil = DateTime.now()
            .add(ref.read(assistantBreakerCooldownProvider));
        _consecutiveFailures = 0;
      }
      await _appendAssistantReply(_fallbackReply);
    } finally {
      ref.read(isSendingProvider.notifier).state = false;
    }
  }

  /// Best-effort usage recording — a DB failure must not break the chat or
  /// trip the breaker (quota fails open rather than fail closed).
  Future<int> _recordUsage(String staffId,
      {int messageDelta = 0, int errorDelta = 0}) async {
    try {
      return await ref
          .read(assistantUsageServiceProvider)
          .recordUsage(staffId: staffId, messageDelta: messageDelta, errorDelta: errorDelta);
    } catch (_) {
      return 0;
    }
  }

  /// The staff profile lookup fails open too: if it can't be resolved
  /// (auth not ready, profile fetch error), the quota is simply skipped
  /// rather than blocking the chat.
  Future<String?> _staffIdOrNull() async {
    try {
      final profile = await ref.read(staffProfileProvider.future);
      return profile?.id;
    } catch (_) {
      return null;
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

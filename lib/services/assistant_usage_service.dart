import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin client for the AI Assistant usage quota (Phase B — OWASP LLM10).
/// No state — same shape as the Supabase-backed services.
class AssistantUsageService {
  AssistantUsageService({this._client});

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  /// Records usage for the current day (via the security-definer RPC) and
  /// returns the new daily message count — the caller uses it to enforce
  /// the per-staff quota. Content is never stored, only counts.
  Future<int> recordUsage({
    required String staffId,
    int messageDelta = 1,
    int errorDelta = 0,
  }) async {
    final result = await _supabase.rpc('update_assistant_usage', params: {
      'p_staff_id': staffId,
      'p_message_delta': messageDelta,
      'p_error_delta': errorDelta,
    });
    return result as int;
  }
}

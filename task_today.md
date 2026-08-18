# Task Today

> This file is the project's active memory. Keep it focused on ONE current task only. Overwrite it when the task changes — do not let it accumulate history (history belongs in `audit.md`).

---

## Current Task
✅ **COMPLETE — AI Assistant security red-team (OWASP LLM Top 10, 2025).** Finished 2026-08-18 across three phases:

- **Phase A** (committed `a8afc9b`): defensive system prompt (BEGIN/END markers, no-CoT, no-reveal/no-fabrication), input guards (2,000-char cap, last-20 history cap, jailbreak/extraction filter), output guards (`max_tokens` 500, `temperature` 0.4, leak-signature + HTML/code-fence rejection), UI disclaimer, model swap to `nvidia/nemotron-3-super-120b-a12b:free` after the previous free model leaked chain-of-thought live.
- **Phase B** (committed `0241008`): per-staff 30/day quota (Supabase `assistant_usage` + `update_assistant_usage` RPC, RLS self-scope), 1s send throttle, circuit breaker (3 fails → 30s cooldown), fail-open design.
- **Phase D** (this commit): adversarial unit suite `test/assistant_security_test.dart` (22 tests, all hermetic); live red-team battery (12 adversarial prompts through the real OpenRouter API) — **12/12 clean**: zero system-prompt leak, zero chain-of-thought dump, zero markup, clean refusals on every jailbreak/extraction/PII/credential ask; OWASP item-by-item audit entry in `audit.md`.

## Why This Task Is Closed
- Every in-scope OWASP LLM item closed: LLM01 Prompt Injection PASS (client filter + model defense), LLM02 Sensitive Info PASS (no data auto-attached), LLM03 Supply Chain PARTIAL (deferred to Phase C relay), LLM04/LLM08 N/A (no RAG/embeddings — documented), LLM05 Output Handling PASS, LLM06 Excessive Agency PASS (zero tools), LLM07 Prompt Leakage PASS, LLM09 Misinformation PASS (caps + disclaimer + no-fabricate rules), LLM10 Unbounded Consumption PASS (quota 30/day server-counted, throttle, breaker).
- Full verification: `flutter analyze` clean; `flutter test` green (chat + security suites).

## Remaining (owner-decisions, not code debt)
- **Rotate the OpenRouter API key** (and the xAI key) — both were pasted into a chat session; per the feature's own security note, any key ever shared must be rotated. Rotate at https://openrouter.ai/keys and update `.env` only.
- **Phase C server-side relay (deferred by owner)** — moves the key off the client; would close LLM03. Only if the owner funds/wants it.
- **RAG ("ask about your actual bookings")** — would reopen LLM01/LLM04/LLM08 and needs a fresh audit before enabling; not currently planned.
- **Budget ceiling** — only relevant if a paid model (e.g. `x-ai/grok-4.6`) is funded; consider an OpenRouter credit-limit alert then.
- **Post-launch roadmap:** payment processing, email notifications, multi-property support — require external credentials or schema redesign.

## Notes / Blockers
- Dev test accounts kept per owner instruction — do NOT rotate/delete them.
- All flutter commands must use the `C:\flutter` junction path (space-in-SDK-path hook bug).
- The Assistant never sends live booking/guest data to the model; system prompt enforces it has no data access; history is in-memory only.
- The 12-prompt live red-team script was a temporary evidence script (results recorded in `audit.md`) — intentionally not kept in the repo so the suite stays hermetic.
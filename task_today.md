# Task Today

> This file is the project's active memory. Keep it focused on ONE current task only. Overwrite it when the task changes — do not let it accumulate history (history belongs in `audit.md`).

---

## Current Task
✅ **COMPLETE — Assistant (AI chatbot) feature shipped.** 7th nav destination — finished 2026-08-15. Provider: OpenRouter (`nvidia/nemotron-3.5-lightning:free`; `x-ai/grok-4.6` swap-in when account is funded). Full audit entry in `audit.md` (post-launch feature). No active implementation task remains.

## Why This Task Is Closed
- `lib/models/chat_message.dart`, `lib/services/chatbot_service.dart` (xAI chat-completions client, `ChatbotException`), `lib/state/chatbot_providers.dart` (`ChatMessagesController` + `isSendingProvider`), `lib/screens/chatbot/chatbot_screen.dart` (neumorphic chat UI) — all following existing Beta 1.2 patterns.
- 7th `StatefulShellBranch` (`/assistant`) + `smart_toy` destination on both rail and pill nav.
- `XAI_API_KEY`/`OPENROUTER_API_KEY` in `.env` (git-ignored) + `.env.example` placeholder + `AppConfig` getter. `http` added to pubspec.
- `flutter analyze` clean; `flutter test` 18/18 (6 new chatbot tests: service payload/errors, controller append/fallback/blank-input).
- README updated (feature section, tech stack, `.env` docs, structure tree).

## Remaining (owner-decisions, not code debt)
- **Rotate the OpenRouter API key** (and the xAI key) — both were pasted into a chat session; per the feature's own security note, any key ever shared must be rotated. Rotate at https://openrouter.ai/keys and update `.env` only.
- **Post-launch roadmap:** payment processing, email notifications, multi-property support — require external credentials (payment gateway, email provider) or schema redesign.
- **Production hardening (optional, deferred):** credential rotation before real deployment (dev accounts intentionally retained for now), optional `total_price` DB trigger (SQL documented in README), hosting + APK release when the owner decides.

## Notes / Blockers
- Dev test accounts kept per owner instruction — do NOT rotate/delete them.
- All flutter commands must use the `C:\flutter` junction path (space-in-SDK-path hook bug).
- The Assistant never sends live booking/guest data to Grok; system prompt enforces it has no data access.

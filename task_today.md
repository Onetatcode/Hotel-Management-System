# Task Today

> This file is the project's active memory. Keep it focused on ONE current task only. Overwrite it when the task changes — do not let it accumulate history (history belongs in `audit.md`).

---

## Current Task
✅ **COMPLETE — all planned phases shipped.** Phase 5 (Polish & deployment prep) finished 2026-08-15, including the owner-requested Beta 1.2 soft neumorphic black + lime redesign. Full project closed out in `audit.md` (Phase 5 entry + Beta 1.2 audit). No active implementation task remains.

## Why This Task Is Closed
- Phase 1–5 all audited ("Ready to proceed"); Beta 1.2 pushed to `main` (2d4da4f) with the new README + `App POC 1.1/` screenshots.
- `flutter analyze` clean, `flutter test` 12/12, release web bundle rebuilt post-redesign.
- Machine fix in place for native-assets hooks: `C:\flutter` junction → `F:\Flutter SDk\flutter` (error_bug #4) — run flutter commands via `C:\flutter\bin\flutter.bat`.

## Remaining (owner-decisions, not code debt)
- **Post-launch roadmap:** payment processing, email notifications, multi-property support — require external credentials (payment gateway, email provider) or schema redesign.
- **Production hardening (optional, deferred):** credential rotation before real deployment (dev accounts intentionally retained for now), optional `total_price` DB trigger (SQL documented in README), hosting + APK release when the owner decides.

## Notes / Blockers
- Dev test accounts kept per owner instruction — do NOT rotate/delete them.
- All flutter commands must use the `C:\flutter` junction path (space-in-SDK-path hook bug).

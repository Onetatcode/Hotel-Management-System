# Task Today

> This file is the project's active memory. Keep it focused on ONE current task only. Overwrite it when the task changes — do not let it accumulate history (history belongs in `audit.md`).

---

## Current Task
Phase 5 — Polish & deployment prep (post-MVP placeholder, now active). Audit loading/error/empty states across all screens, run an accessibility pass, check performance on mobile + web, and prepare deployment (env separation, credentials, hosting choice).

## Why This Task
Phase 5 is the final planned phase (implementation_plan.md lines 48–49). Phases 1–4 are complete and audited (Ready to proceed); the app is functionally whole. This phase hardens what exists before any real deployment.

## Related Requirements
- Phase reference: Phase 5 (Post-MVP placeholder)
- Relevant PRD sections: UI/UX — polish, accessibility
- implementation_plan.md: Phase 5 note

## Reference Files
- `implementation_plan.md` — Phase 5 note
- `prd.md` — UI/UX
- Code files (existing): all `lib/screens/*`, `lib/widgets/*`, `lib/state/*`, `lib/services/*`, `audit.md` (Phase 4 entry with flagged items)

## Acceptance Criteria (draft — refine during the step)
- [ ] Error/loading/empty states audit: every screen handles load-failure, loading, and empty data without raw error text or blank screens
- [ ] Accessibility pass: readable contrast, touch target sizes, form field labels, semantics on icon-only buttons
- [ ] Performance check: web bundle size sanity + app startup on mobile; no jank hotspots in lists
- [ ] Deployment prep documented: environment config for staging/prod, credential rotation plan (replace `test123` dev accounts), hosting options for web + APK
- [ ] `flutter analyze` clean; `flutter test` green
- [ ] Verified on mobile-width layout
- [ ] Verified on web/desktop-width layout

## Notes / Blockers
- **User action:** decide deployment targets (hosting for web + APK distribution) when we get there; may want fresh README screenshots + GitHub push/new release (Phase 3+4 work is still uncommitted/unpushed — pending user request).
- **Flagged carry-over items to resolve in Phase 5:** `total_price` DB trigger vs client-side computation; dev credentials rotation; `New folder/` stray dir deletion; decide whether `update_room_status` needs an RLS policy for the RPC grants audit.
- Phase 5 is intentionally loose — each sub-item is a small step done one at a time.

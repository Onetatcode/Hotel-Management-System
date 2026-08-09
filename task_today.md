# Task Today

> This file is the project's active memory. Keep it focused on ONE current task only. Overwrite it when the task changes — do not let it accumulate history (history belongs in `audit.md`).

---

## Current Task
Build the responsive navigation shell (Phase 3, step 1 of 2): a single shared shell with a bottom navigation bar on mobile widths and a side rail/drawer on web/desktop widths, plus the go_router route table covering Dashboard, Rooms, Availability Search, Bookings, Guests, Profile — wired to real auth state (unauthenticated users always land on Login).

## Why This Task
Phase 3 — Navigation & App Shell UI (implementation_plan.md lines 28–34). Phase 2 delivered working auth with role data (admin vs front_desk) already flowing through providers; this phase turns the placeholder HomeScreen into the real app shell and replaces the current hardcoded auth gate in `main.dart` with router-based redirects.

## Related Requirements
- Phase reference: Phase 3 — Navigation & App Shell UI
- Relevant PRD sections: Core Features — "Auth & roles", "Dashboard", "Room management", "Availability search", "Booking management", "Guest management"; UI/UX — responsive design
- implementation_plan.md: Phase 3 bullets 1–4

## Reference Files
- `implementation_plan.md` — Phase 3 (shell, routes, design system, auth wiring)
- `prd.md` — Core Features + UI/UX sections
- Code files (existing): `lib/main.dart` (replace home gate with GoRouter), `lib/screens/home_screen.dart` (replaced by shell), `lib/state/auth_providers.dart` (consumed by redirects); (new): `lib/router/app_router.dart`, `lib/screens/shell/app_shell.dart` + shell scaffold/widgets, `lib/screens/{dashboard,rooms,availability,bookings,guests,profile}/…` placeholder screens

## Acceptance Criteria
- [ ] go_router route table: `/login` and 6 primary routes under a shell; redirect rules — unauthenticated → `/login`, authenticated → `/login` is inaccessible (redirect to shell)
- [ ] Single shared `AppShell` with Material 3 `NavigationBar` on mobile widths and `NavigationRail` (or Drawer) on desktop widths, breakpoint-driven (e.g. 600–800px), one code path
- [ ] Design system seeded: typography scale, spacing, color palette, reusable `StatusBadge`/`Card`/form-field components per prd.md
- [ ] All 6 destination screens exist as routed placeholders (no mock data; "coming in Phase 4" content)
- [ ] `Profile` screen shows signed-in staff name + role (from `staffProfileProvider`) and Sign Out
- [ ] Session persistence respected by router on cold start (stored session restores → straight to shell)
- [ ] `flutter analyze` clean; `flutter test` green (existing tests updated for router; add a signed-in navigation smoke test)
- [ ] Verified on mobile-width layout
- [ ] Verified on web/desktop-width layout

## Notes / Blockers
- **User action:** none required. I verify with `flutter analyze` + `flutter test`, then run on Edge web (existing `CHROME_EXECUTABLE` env needed) and Android emulator `emulator-5554`; you do the final visual pass at both widths.
- **Flagged assumptions:** shell + routes first, design system second (both Phase 3, same task file — will split into two steps if it grows too large); placeholder screens show "coming in Phase 4" instead of mock data; nav destinations constant for both roles in this step — role-based nav differences (if prd.md requires any) come with Phase 4 features.
- Session persistence on web = localStorage (gotrue); already proven during Phase 2 smoke test.
- Dev accounts for testing: `admin@hotelms.test` / `frontdesk@hotelms.test`, password `test123`.

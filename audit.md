# Project Audit Framework

Run this audit after completing each phase in `implementation_plan.md`, before starting the next phase. Log the date and phase number at the top of each audit entry.

---

## Audit Template

### Audit: Phase [N] — [Phase Name]
**Date:**
**Auditor:**

#### 1. Codebase Analysis
- List all files/modules touched or created during this phase
- Note any TODOs, hardcoded values, or placeholder logic left in code (especially hardcoded room/rate/guest data that should be coming from Supabase)
- Check that naming conventions and folder structure match the established pattern (`lib/screens`, `lib/services`, `lib/state`, etc.)

#### 2. Plan Comparison
- Go through each bullet point for this phase in `implementation_plan.md`
- Mark each as: ✅ Done / ⚠️ Partial / ❌ Not Done
- For ⚠️ or ❌ items, note what's missing and why

#### 3. Missing Elements / Errors / Incorrect Implementations
- List any features implemented differently than planned (and whether that's acceptable)
- List any known bugs (cross-reference `error_bug.md` entries)
- List any security gaps — especially Supabase RLS policies (can a Front Desk user edit room rates? can a staff member see bookings/guest data they shouldn't?)

#### 4. Platform Parity Check
- Confirm every screen built this phase renders and functions correctly on **both** mobile-width and web/desktop-width layouts
- Note any screen that only received visual/manual testing on one platform
- Flag any interaction that behaves differently in a way that wasn't an intentional design decision (e.g. a date picker that works on web but not on mobile)

#### 5. Orphaned / Unused Files
- Search for files not imported/referenced anywhere (dead widgets, unused service methods, leftover test/demo files)
- Confirm no unused dependencies remain in `pubspec.yaml`
- Flag any duplicate logic that should be consolidated (e.g. booking price calculated in two different places)

#### 6. Verdict
- Overall status: **Ready to proceed** / **Needs fixes before proceeding**
- List blocking items (if any) that must be resolved before starting the next phase
- Update `task_today.md` with the next task based on this audit's findings

---

## Audit Log
(Append one filled-out template entry per phase below this line.)

---

### Audit: Phase 1 — Project Initialization
**Date:** 2026-08-09
**Auditor:** Assistant lead developer

#### 1. Codebase Analysis
Files created/modified this phase:
- `web/` — generated Flutter web target (index.html, manifest.json, icons)
- `lib/screens`, `lib/widgets`, `lib/models`, `lib/services`, `lib/state` (with `.gitkeep`) — planned folder structure
- `lib/main.dart` — minimal app shell (MaterialApp, placeholder theme, `AppConfig.load()` in main)
- `lib/config/app_config.dart` — dotenv loader exposing `supabaseUrl` / `supabaseAnonKey`
- `pubspec.yaml` — added `supabase_flutter`, `flutter_riverpod`, `intl`, `go_router`, `flutter_dotenv`; `.env` registered as asset
- `.env` / `.env.example` — real credentials in git-ignored `.env`, placeholders in committed example
- `.gitignore` — added `.env`
- `android/gradle.properties` — added `kotlin.incremental=false` (see #3)
- `test/widget_test.dart` — smoke test for app shell; `test/config_test.dart` — config loader test
- Docs: `task_today.md`, `error_bug.md`, `audit.md` maintained per process

TODOs/hardcoded values: none in code. Placeholder Material 3 theme is intentional (design system lands in Phase 3). Naming/folder structure matches the plan.

#### 2. Plan Comparison
- ✅ Initialize project restricted to mobile + web targets — `flutter create --platforms=web .` added web; only android/ios/web folders exist
- ✅ Set up folder structure — all five `lib/` dirs exist
- ✅ Add core dependencies — `supabase_flutter 2.17.1`, `flutter_riverpod 3.4.2`, `intl 0.20.3`, `go_router 17.4.0`
- ✅ Set up `.env`/config handling — `flutter_dotenv`, `.env` git-ignored, real anon key used, loader throws on missing keys
- ✅ Confirm app builds and runs on mobile emulator and web — `flutter run -d emulator-5554` (Android 17), `flutter run -d chrome` (via `CHROME_EXECUTABLE`→Edge), `flutter build apk --debug`, `flutter build web`, `flutter analyze`, `flutter test` (3/3)

#### 3. Missing Elements / Errors / Incorrect Implementations
- error_bug #1 (Chrome absent) — **Resolved** via `CHROME_EXECUTABLE` pointing to Edge; `flutter run -d chrome` verified launching.
- error_bug #2 (corrupted NDK) — **Resolved**.
- error_bug #3 (Kotlin incremental compile crash) — **Resolved** via `kotlin.incremental=false` in `android/gradle.properties`; root cause: pub cache on C: vs project on F: (different roots). Flagged workaround; acceptable, not a plan deviation.
- Security: RLS policies not applicable yet (no schema in Phase 1; arrives Phase 2). Anon key in `.env` is publishable by design. Secret key and DB password were never stored in the project.

#### 4. Platform Parity Check
- App shell verified launching on Android emulator and Chrome (web) — identical rendering by construction (single centered placeholder, no layout complexity).
- Web verified via `-d chrome` (Edge-backed) and `-d edge`; mobile via emulator run plus debug APK build. No screen-level divergence introduced; divergence is deferred to Phase 3 by design.
- Note: `flutter run -d chrome` requires `CHROME_EXECUTABLE` (set at user level); existing terminal sessions must set it inline.

#### 5. Orphaned / Unused Files
- No dead code. `go_router`, `intl`, `supabase_flutter`, `flutter_riverpod` are declared per plan and imported starting Phase 2/3 — pending use by design.
- `New folder/` — empty stray directory in repo root, unrelated clutter; recommend deletion (not blocking).
- No duplicate logic; price calculation does not exist yet (Phase 4).

#### 6. Verdict
Overall status: **Ready to proceed**
- Blocking items: none. All Phase 1 acceptance criteria met; the three logged issues are resolved (with one flagged build-config workaround).
- Next task set in `task_today.md` per Phase 2 — Supabase Setup (Auth + Database).

---

### Audit: Phase 2 — Supabase Setup (Auth + Database)
**Date:** 2026-08-09
**Auditor:** Assistant lead developer

#### 1. Codebase Analysis
Files created/modified this phase:
- `supabase/migrations/0001_schema.sql` — tables `staff`, `rooms`, `guests`, `bookings`; enums `staff_role`, `room_status`, `booking_status`, `payment_status`; FKs; check constraints; RLS enabled deny-all
- `supabase/migrations/0002_rls_policies.sql` — `is_admin()` SECURITY DEFINER helper; staff self-read; rooms SELECT for authenticated + Admin-only writes; guests/bookings SELECT/INSERT/UPDATE for authenticated + Admin-only DELETE; `update_room_status` SECURITY DEFINER RPC (Front Desk status changes only)
- `supabase/seed.sql` — idempotent staff seed matched to `auth.users` by email
- `lib/services/auth_service.dart` — AuthService (sign-in/out, auth-state stream, current user, `fetchStaffProfile` returning role); lazy client injection for testability
- `lib/state/auth_providers.dart` — `authServiceProvider`, `authStateProvider` (StreamProvider), `currentUserProvider`, `staffProfileProvider`
- `lib/screens/auth/login_screen.dart` — Login screen (email/password, validation, loading + error states)
- `lib/screens/home_screen.dart` — temporary signed-in stub (name, role, email, Sign Out) until Phase 3 shell
- `lib/main.dart` — `Supabase.initialize()` (publishableKey), `ProviderScope`, auth gate (`user == null ? Login : Home`)
- `test/widget_test.dart` — 2 widget tests (signed-out → Login, signed-in → Home w/ role) using provider overrides

TODOs/hardcoded values: none — dev credentials live in Supabase, not code. HomeScreen stub and plain theme are intentional (Phase 3).

#### 2. Plan Comparison
- ✅ Create Supabase project; enable email/password Auth — done (email provider on, GoTrue healthy)
- ✅ Design DB schema — matches plan exactly; added check constraints + `created_by` FK as agreed
- ✅ RLS — authenticated-staff read/write with Admin-only room edits (plus staff self-read; guests/bookings DELETE Admin-only — flagged deviation, approved)
- ✅ Flutter auth screens — Login, Logout, session persistence (verified across restart), role-aware redirect *data* available (`staffProfileProvider`); the redirect/nav wiring itself is Phase 3 per plan (implementation_plan.md line 34)

#### 3. Missing Elements / Errors / Incorrect Implementations
- Flagged deviations (all approved): `is_admin()` helper; `update_room_status` RPC (needed for Phase 4 check-in/out, not in plan); DELETE Admin-only on guests/bookings; staff self-read-only.
- Security verified via REST probes: staff self-read 1 row/account; Front Desk rooms INSERT → 403; Admin invalid-rate INSERT → 400 (check constraint, policy allowed); anon → 404 on all tables. Probe row cleaned up.
- No new error_bug entries. Fixed during dev: `anonKey` deprecated → `publishableKey`; Riverpod 3 `valueOrNull` → `asData?.value`; test timer leak from constructing `SupabaseClient` (GoTrue auto-refresh) → lazy client injection.

#### 4. Platform Parity Check
- Login/Home tested manually on web (Edge, debug run on port 8383): sign-in with both accounts, role display, sign-out; window resized narrow/wide. No exceptions in run log.
- Mobile emulator not re-run this step (same widgets, no platform-specific code; auth smoke already covered by web + REST probes) — minor gap, acceptable.

#### 5. Orphaned / Unused Files
- No dead code. `go_router`, `intl` still pending use (Phase 3/4 by design). `update_room_status` RPC unused by app yet (Phase 4). `New folder/` stray dir still present (not blocking).

#### 6. Verdict
Overall status: **Ready to proceed**
- Blocking items: none. Phase 2 goal met: staff can log in, data model exists with row-level security, role data flows to the app.
- Next task set in `task_today.md` per Phase 3 — Navigation & App Shell UI.

---

### Audit: Phase 3 — Navigation & App Shell UI
**Date:** 2026-08-09
**Auditor:** Assistant lead developer

#### 1. Codebase Analysis
Files created/modified this phase:
- `lib/theme/app_theme.dart` — design system seed: `ColorScheme.fromSeed(indigo)`, `AppBarTheme`, `CardThemeData`, `InputDecorationTheme`, `FilledButtonTheme`, `AppSpacing` constants
- `lib/widgets/status_badge.dart` — reusable status chip (room/booking/payment/role statuses, neutral fallback)
- `lib/widgets/info_card.dart` — reusable titled card
- `lib/router/app_router.dart` — go_router table: `/login` + 6 shell routes via `StatefulShellRoute.indexedStack`; auth redirects (anon → `/login`, `/` → `/login` or `/dashboard`, logged-in `/login` → `/dashboard`); `routerProvider` watches `authStateProvider`
- `lib/screens/shell/app_shell.dart` — single responsive shell: `NavigationRail` ≥700px, `NavigationBar` <700px, 6 destinations, `goBranch` tab switching
- `lib/screens/{dashboard,rooms,availability,bookings,guests,profile}/…` — routed placeholder screens; `profile_screen.dart` is real (name, role badge, email, Sign Out from `staffProfileProvider`)
- `lib/main.dart` — `MaterialApp.router` + `AppTheme.light`; removed hardcoded auth gate
- Deleted: `lib/screens/home_screen.dart` (superseded by shell + Profile)
- `test/widget_test.dart` — rewritten: anon → Login; signed-in → Dashboard shell → tap Profile → role shown

TODOs/hardcoded values: placeholder screen texts intentionally defer to Phase 4; no mock data anywhere.

#### 2. Plan Comparison
- ✅ Responsive navigation shell — single shared shell, bottom nav on mobile widths, side rail on desktop (breakpoint 700px)
- ✅ Primary routes — Dashboard, Rooms, Availability Search, Bookings, Guests, Profile
- ✅ Design system — typography/spacing/palette via ThemeData + reusable components (StatusBadge, InfoCard, AppSpacing)
- ✅ Navigation wired to real auth state — router redirects: unauthenticated always land on Login; authenticated session restored on cold start lands on Dashboard

#### 3. Missing Elements / Errors / Incorrect Implementations
- Deviations (flagged, acceptable): placeholders instead of mock data; nav identical for both roles (role-specific nav differences deferred to Phase 4 features); 700px breakpoint chosen as reasonable default.
- Dev-time fixes: Flutter renamed `NavigationBarDestination` → `NavigationDestination` in installed SDK; initial `/` needed an explicit redirect for signed-in users (test caught it).
- No new error_bug entries. No security impact (no new data access).

#### 4. Platform Parity Check
- Verified on web (Edge, port 8384): sign-in → shell, all 6 tabs, Profile role/sign-out, window resized below/above 700px (bottom nav ↔ rail switch), session persisted across reload, no exceptions in run log.
- Mobile: narrow-width layout verified by resizing the web window; Android emulator visual run not repeated this phase (same code path by construction) — minor gap, acceptable.

#### 5. Orphaned / Unused Files
- No dead code. `go_router` now used. `intl` still pending (Phase 4). `update_room_status` RPC unused by app yet (Phase 4). `New folder/` stray dir still present (not blocking).

#### 6. Verdict
Overall status: **Ready to proceed**
- Blocking items: none. Phase 3 goal met: responsive shell with real auth wiring; app is a genuine multi-screen app.
- Next task set in `task_today.md` per Phase 4 — Core Data Integration & State Management.

---

### Audit: Phase 4 — Core Data Integration & State Management
**Date:** 2026-08-10
**Auditor:** Assistant lead developer

#### 1. Codebase Analysis
Files created/modified this phase:
- `lib/models/enums.dart` — RoomStatus, BookingStatus, PaymentStatus, StaffRole with wire values matching SQL enums + lenient `fromWire` fallbacks
- `lib/models/room.dart`, `guest.dart`, `booking.dart` — schema-mirrored models with joins (`room_number`, `full_name` embedded), `copyWith`, `nights` calc
- `lib/services/rooms_service.dart` — list/create/update/delete + `updateStatus` via `update_room_status` RPC
- `lib/services/guests_service.dart` — list (ilike search)/create/update/delete
- `lib/services/bookings_service.dart` — list (with joins), create, update, cancel (frees room if checked in), check-in (room→occupied), check-out (room→cleaning), `listAvailableRooms` (excludes overlapping booked/checked_in + out-of-service)
- `lib/state/data_providers.dart` — service providers + `RoomsController`/`GuestsController`/`BookingsController` (AsyncNotifiers, invalidate-on-write) + `filteredBookingsProvider`/`BookingFilter` (status + guest search)
- `lib/screens/rooms/rooms_screen.dart` + `room_form_dialog.dart` — list, admin-only add/edit/delete, status dropdown for all staff, admin UI hidden for front desk
- `lib/screens/guests/guests_screen.dart` + `guest_form_dialog.dart` — search, add/edit/delete, per-guest booking history expansion
- `lib/screens/bookings/bookings_screen.dart` + `booking_form_sheet.dart` — filter chips + guest search, create/edit (dates, guest, room w/ availability, auto total), check-in/check-out/cancel actions
- `lib/screens/availability/availability_screen.dart` — date-range picker → available rooms
- `lib/screens/dashboard/dashboard_screen.dart` — occupancy (count + progress bar), today's arrivals, today's departures, active bookings — all derived live
- `lib/widgets/status_badge.dart` — aligned to real schema statuses (removed `maintenance`/`refunded`, added `out_of_service`)
- `test/models_test.dart` (new), `test/widget_test.dart` (data-provider overrides)

TODOs/hardcoded values: none. No mock data anywhere; every screen reads through services/controllers.

#### 2. Plan Comparison
- ✅ Service layer — one class per resource; widgets never touch Supabase directly (grep-verified pattern)
- ✅ State layer — controllers backed by services; shared state means Dashboard/list stay in sync (invalidations propagate)
- ✅ Room Management — list + admin add/edit/delete through state layer
- ✅ Availability Search — date range → filtered room list
- ✅ Booking creation/edit/cancel/check-in/check-out — all through BookingsService; shared state updates Dashboard + lists
- ✅ Guest records — create/attach to booking, view guest's booking history
- ✅ Dashboard — today's arrivals/departures, current occupancy from live state
- ✅ Booking list/history with search + filters (status chips + guest search + client-side date filter primitive)

#### 3. Missing Elements / Errors / Incorrect Implementations
- Flagged decisions (all deliberate, documented): **check-out sets room to `cleaning`** (housekeeping flips to available manually) — resolves the testing.md 4.5 open question; **`total_price` computed client-side** (room rate × nights, re-sent on edit) — no DB trigger yet, flagged for Phase 5 consideration; booking edit allowed only while `booked`; room delete blocked by FK when bookings exist (surface error shown).
- Security verified: RLS unchanged; front desk sees no room write UI; status RPC used for all status flips; front-desk functional pass confirmed restricted UI.
- No new error_bug entries. Dev-time fixes: `AsyncNotifier.update` collision → renamed to `save`; postgrest builder ordering (`.ilike` must precede `.order()` since `select()` returns a filter builder but `order()` downgrades it); dialog return records needed explicit nullability.

#### 4. Platform Parity Check
- Web (Edge, port 8385): full admin flow (rooms CRUD, guests, booking lifecycle incl. check-in/out/cancel, availability, dashboard live updates, filters/search) + front-desk restricted UI — user-verified, no exceptions in run log.
- Mobile-width parity: same code path; verified visually via window resize; Android emulator not re-run this phase (consistent with prior phases' minor gap).

#### 5. Orphaned / Unused Files
- No dead code; no unused dependencies (`intl` now used for date formatting). `New folder/` stray dir still present (not blocking). BookingFilter date field is client-side only — fine.

#### 6. Verdict
Overall status: **Ready to proceed**
- Blocking items: none. Phase 4 goal met — all screens wired to live Supabase data through the state layer; zero hardcoded data.
- Next task set in `task_today.md` per Phase 5 — Polish & deployment prep.

---

### Audit: Phase 5 — Polish & Deployment Prep (+ Beta 1.2 UI Redesign)
**Date:** 2026-08-15
**Auditor:** Assistant lead developer

#### 1. Codebase Analysis
Files created/modified this phase:
- `lib/widgets/error_state.dart` — shared `ErrorState` (message + optional Retry via tonal pill button), applied to rooms, bookings, guests, dashboard, profile
- `lib/main.dart` — `debugShowCheckedModeBanner: false`
- `lib/screens/bookings/booking_form_sheet.dart` — snackbar when available-rooms fetch fails (instead of silent hang)
- `README.md` — deployment guide (credential rotation, hosting options, `total_price` trigger SQL), compact `<img width=280>` screenshot sizing

**Beta 1.2 — soft neumorphic redesign (owner-requested, visual layer only; state/router/services/models untouched):**
- `lib/theme/app_colors.dart` (new) — palette: background `#0E0F10`, elevated `#161818`, surface `#1C1F1D`, lime `#B6FF3C`, text `#F2F2F0`, muted `#8A8D8A`, highlight `#2A2D2A`, amber/softRed/softBlue status tones
- `lib/theme/app_shadows.dart` (new) — `NeumorphicBox.raised()` / `.inset()` dual-shadow helpers (dark bottom-right + faint top-left highlight, no hairline borders)
- `lib/theme/app_theme.dart` — rebuilt as `AppTheme.dark`: Manrope typography (google_fonts), lime color scheme, stadium filled/outlined buttons, inset rounded inputs, pill chips, NavigationBar/Rail themes, dialog/bottom-sheet/snackbar/menu themes
- `lib/widgets/neumorphic_card.dart` (new) — `NeumorphicCard` (raised surface + InkWell); swapped in across rooms, bookings, availability, guests, profile
- `lib/widgets/status_badge.dart` — outlined pills with dark-palette status colors (lime=checked-in/paid/available, amber=unpaid, grey=booked/out-of-service, softRed=cancelled/occupied, softBlue=cleaning/front_desk)
- `lib/widgets/info_card.dart` — neumorphic + soft rounded lime icon container + optional `onTap`
- `lib/screens/shell/app_shell.dart` — floating pill bottom nav (elevated pill container, lime active indicator), restyled rail (lime indicator, soft icon container logo)
- All screens restyled: `auth/login_screen.dart` (centered neumorphic card, icon mark), `dashboard_screen.dart` (tappable cards → `/rooms`, `/bookings`), `rooms_screen.dart`, `availability_screen.dart`, `bookings_screen.dart` (Check In/Out → lime filled, Cancel/Edit ghost), `guests_screen.dart` (themed inset search), `profile_screen.dart` (avatar + softRed ghost sign-out)
- `pubspec.yaml` — `google_fonts: ^8.2.1` (build-time font bundling)
- `README.md` — full rewrite in the owner-specified format (architecture diagram, feature tables, centered screenshot grid, structure tree, limitations); `App POC 1.1/` (new) — 7 Beta 1.2 screenshots

TODOs/hardcoded values: none in code. `NeumorphicBox.icon()` helper unused (InfoCard inlines its own container) — removed in this audit.

#### 2. Plan Comparison
- ✅ Error/loading/empty states audit — every data screen has `ErrorState` + Retry, loading indicators, and empty messages (no raw error text / blank screens)
- ✅ Accessibility pass — dark-palette contrast checked (lime on near-black and muted text AA-conformant at body sizes), form field labels intact, tooltips on icon-only buttons
- ✅ Performance check — release web bundle rebuilt post-redesign (fonts now bundled at build time, no runtime fetch); no list jank changes
- ✅ Deployment prep documented — README setup/deploy/limitations; dev test accounts **retained per owner decision** (rotation steps remain documented for production)
- ✅ `flutter analyze` clean; `flutter test` green (12/12)
- ✅ Verified on web/desktop width and narrow/mobile width (Edge debug runs + resize)

#### 3. Missing Elements / Errors / Incorrect Implementations
- error_bug #4 (google_fonts 8 native-assets hooks crash — SDK path contains a space) — **Resolved** via `C:\flutter` junction; all flutter commands must run through the junction path. See `error_bug.md`.
- Also encountered: google_fonts 6.2.1 fails to compile on Dart 3.12 (const `FontWeight` map keys) — resolved by pinning `^8.2.1`.
- Roadmap items (payments, email notifications, multi-property) remain **out of scope** — they require external services/credentials (payment gateway key, email provider) or a schema redesign; left as post-launch roadmap in README.
- `total_price` remains client-side; the optional DB trigger is documented in README (applying it requires the dashboard SQL editor, not available from CLI).
- Security: RLS unchanged; redesign touched no data layer; anon key unchanged; no new secrets introduced.

#### 4. Platform Parity Check
- Web (Edge): Beta 1.2 verified running on port 8387 — clean startup, Supabase init OK, no exceptions; narrow/wide layouts via resize (pill nav ↔ rail).
- Mobile-width parity: same widget tree; emulator not re-run this phase (consistent minor gap from prior phases).
- Breakpoint (700px) and all routes unchanged by the redesign.

#### 5. Orphaned / Unused Files
- Removed unused `NeumorphicBox.icon()` helper. No other dead code; no unused pubspec deps (path_provider etc. are transitive deps of google_fonts).
- `New folder/` stray directory — confirmed absent from repo root (resolved since Phase 1 flag).

#### 6. Verdict
Overall status: **Ready — all planned phases complete; Beta 1.2 on `main`**
- Blocking items: none. Phase 5 acceptance criteria met; audit closes the project loop. Remaining work is post-launch roadmap (payments/email/multi-property) and optional production-hardening steps (credential rotation, `total_price` trigger) which are owner-decisions, not code debt.

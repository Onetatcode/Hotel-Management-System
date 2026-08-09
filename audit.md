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

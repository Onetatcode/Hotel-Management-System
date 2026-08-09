# Hotel Management System

A modern hotel management app built with **Flutter** (mobile + web) and **Supabase** (PostgreSQL + Auth + Row Level Security). Staff can log in with role-based access (Admin / Front Desk), manage rooms, guests, and bookings, and track availability — all through a single responsive codebase that adapts between mobile and desktop layouts.

> **Status: Beta 1.0** — Phase 1 (project init), Phase 2 (Supabase setup: schema, auth, RLS) and Phase 3 (navigation shell) are complete. Phase 4 (live data integration: rooms, availability, bookings, guests, dashboard) is in progress.

![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup & Run](#setup--run)
- [Supabase Setup](#supabase-setup)
- [Database Schema](#database-schema)
- [Security (RLS)](#security-rls)
- [Test Accounts](#test-accounts)
- [Testing](#testing)
- [Building for Release](#building-for-release)
- [Roadmap](#roadmap)
- [License](#license)

---

## Features

### Auth & Roles
- Email/password sign-in with session persistence (stays signed in across restarts)
- Role-aware access: **Admin** and **Front Desk** staff roles stored in the `staff` table
- Unauthenticated users are always redirected to the Login screen
- Row Level Security enforces exactly what each role can see and do

### Navigation Shell (Phase 3)
- Single shared shell, breakpoint-driven: **bottom navigation bar** on mobile widths, **side navigation rail** on web/desktop widths
- Routes: Dashboard, Rooms, Availability Search, Bookings, Guests, Profile

### Core Data Model (Phase 2)
- `staff` — profiles linked to auth users with role (`admin` / `front_desk`)
- `rooms` — room number, type, nightly rate, capacity, live status (`available` / `occupied` / `cleaning` / `maintenance`)
- `guests` — contact details and ID number
- `bookings` — room/guest links, check-in/out dates, status lifecycle (`booked` → `checked_in` → `checked_out` / `cancelled`), total price, payment status, created-by tracking

### Security
- Row Level Security on every table; Admin-only room management; Front Desk can change room status via a restricted RPC (`update_room_status`) without full room-edit rights
- Anonymous access fully blocked (verified with live probes)
- Secrets never committed: `.env` is git-ignored

---

## Screenshots

> Proof-of-concept captures from the Beta 1.0 build.

| | |
|---|---|
| ![Login screen](App%20POC%201.0/Beta_Login_screen.png) | ![Home screen](App%20POC%201.0/Beta_Home_screen.png) |
| **Login screen** — email/password with validation and loading/error states | **Signed-in view** — shows staff name, role, and email with a Sign Out action |

| | |
|---|---|
| ![Database tables](App%20POC%201.0/Database_Tables.png) | ![Database schema](App%20POC%201.0/Database_schema_visual.png) |
| **Database tables** — `staff`, `rooms`, `guests`, `bookings` in Supabase | **Schema visual** — relationships, FKs, enums and constraints |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.44 / Dart 3.12 (mobile + web, no desktop) |
| State management | flutter_riverpod 3.x |
| Navigation | go_router 17.x |
| Backend | Supabase (PostgreSQL, GoTrue auth, RLS) |
| Config | flutter_dotenv (`.env`, git-ignored) |
| Formatting/parsing | intl |

---

## Project Structure

```
lib/
├── config/          # AppConfig — .env loader (Supabase URL + anon key)
├── screens/
│   ├── auth/        # Login screen
│   ├── shell/       # Responsive app shell (bottom nav / side rail)   [Phase 3]
│   ├── dashboard/   # Dashboard placeholder                             [Phase 3]
│   ├── rooms/       # Rooms placeholder                                 [Phase 3]
│   ├── availability/# Availability Search placeholder                   [Phase 3]
│   ├── bookings/    # Bookings placeholder                              [Phase 3]
│   ├── guests/      # Guests placeholder                                [Phase 3]
│   └── profile/     # Profile — staff name, role, sign out              [Phase 3]
├── services/        # AuthService — Supabase auth wrapper, staff profile fetch
├── state/           # Riverpod providers (auth state, current user, staff profile)
└── main.dart        # App entry — Supabase init + router
supabase/
├── migrations/
│   ├── 0001_schema.sql   # Tables, enums, FKs, constraints, RLS enable
│   └── 0002_rls_policies.sql  # RLS policies + is_admin() + update_room_status RPC
└── seed.sql          # Idempotent staff seed (matched to auth.users by email)
test/                 # Widget + config tests
App POC 1.0/          # Screenshots used in this README
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44+ (bundled Dart 3.12+)
- A [Supabase](https://supabase.com) project
- (Windows dev note) A browser for web runs — `flutter run -d chrome` uses Edge via the `CHROME_EXECUTABLE` environment variable

---

## Setup & Run

```bash
# 1. Clone
git clone https://github.com/Onetatcode/Hotel-Management-System.git
cd Hotel-Management-System

# 2. Install dependencies
flutter pub get

# 3. Create the environment file (never commit it)
copy .env.example .env      # Windows
# then fill in your Supabase URL and anon key

# 4. Run
flutter run -d chrome       # web
flutter run                 # Android (connected device/emulator)
```

`.env` contents:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

---

## Supabase Setup

1. Create a Supabase project.
2. Enable **Email** auth provider (Authentication → Providers).
3. In the dashboard **SQL Editor**, run:
   - `supabase/migrations/0001_schema.sql` — schema
   - `supabase/migrations/0002_rls_policies.sql` — RLS policies + RPC
4. Create staff auth users (Authentication → Users → Add user), then run `supabase/seed.sql` to link `staff` rows to those users by email.

---

## Database Schema

```
staff    (id, user_id → auth.users, name, role: admin|front_desk)
rooms    (id, room_number, room_type, rate_per_night ≥ 0, capacity, status: available|occupied|cleaning|maintenance)
guests   (id, full_name, contact_email, contact_phone, id_number)
bookings (id, room_id → rooms, guest_id → guests, check_in_date, check_out_date,
          status: booked|checked_in|checked_out|cancelled, total_price ≥ 0,
          payment_status: unpaid|paid|refunded, created_by → staff)
```

All tables have `created_at`; bookings checks `check_out_date > check_in_date`; `staff.user_id` is unique.

---

## Security (RLS)

| Table | Authenticated staff | Anonymous |
|---|---|---|
| `staff` | read own row only | blocked |
| `rooms` | SELECT all; writes Admin-only | blocked |
| `guests` | SELECT / INSERT / UPDATE | blocked |
| `bookings` | SELECT / INSERT / UPDATE; DELETE Admin-only | blocked |

- `is_admin()` — SECURITY DEFINER helper used by policies
- `update_room_status(room_id, status)` — SECURITY DEFINER RPC callable by any authenticated staff member; changes *only* the room status (enables Front Desk check-in/out without room-edit rights)
- All policies verified live against the real database (permission vs constraint errors distinguished)

---

## Test Accounts

> Development-only credentials — **replace before any real deployment.**

| Role | Email | Password |
|---|---|---|
| Admin | `admin@hotelms.test` | `test123` |
| Front Desk | `frontdesk@hotelms.test` | `test123` |

---

## Testing

```bash
flutter analyze    # static analysis — must be clean
flutter test       # widget tests: auth gate (signed out → Login, signed in → Home/Profile)
```

---

## Building for Release

```bash
flutter build web                        # web bundle → build/web
flutter build apk --release              # Android APK → build/app/outputs/flutter-apk
```

(Android build note: `kotlin.incremental=false` is set in `android/gradle.properties` to work around a cross-drive incremental-compile issue on this dev machine — harmless, slightly slower builds.)

---

## Roadmap

- [x] **Phase 1** — Project initialization (web target, deps, config, app shell)
- [x] **Phase 2** — Supabase setup (schema, auth, seed, RLS — verified live)
- [x] **Phase 3** — Navigation & app shell (go_router, responsive shell, design system, auth wiring)
- [ ] **Phase 4** — Core data integration (services → providers → screens: rooms, availability, bookings, guests, dashboard)
- [ ] **Phase 5** — Polish & deployment prep

---

## License

Proprietary — © Onetatcode. All rights reserved. Single-contributor project; no external collaborators.

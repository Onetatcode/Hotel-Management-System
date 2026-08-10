# Hotel Management System

A modern hotel management app built with **Flutter** (mobile + web) and **Supabase** (PostgreSQL + Auth + Row Level Security). Staff log in with role-based access (Admin / Front Desk) and manage rooms, guests, and bookings — from availability search to check-in/out — through one responsive codebase that adapts between mobile and desktop layouts.

> **Status: Beta 1.1** — Phases 1–4 complete: project init, Supabase setup (schema + auth + RLS), responsive navigation shell, and full live-data integration (rooms, availability, bookings, guests, dashboard). Phase 5 (polish & deployment prep) is next.

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
- Role-aware access: **Admin** and **Front Desk** staff roles, enforced by both the UI and Row Level Security
- Unauthenticated users are always redirected to the Login screen
- Profile screen shows the signed-in staff member, role badge, and email with one-tap Sign Out

### Responsive Navigation Shell
- Single shared shell, breakpoint-driven: **bottom navigation bar** on mobile widths, **side navigation rail** on web/desktop widths
- Six destinations: Dashboard, Rooms, Availability Search, Bookings, Guests, Profile
- go_router routing with auth-aware redirects (session restored on cold start → straight to Dashboard)

### Rooms (live data, Admin-managed)
- Room list with number, type, nightly rate, capacity, and live status badge
- **Admin only:** add / edit / delete rooms (write controls hidden for Front Desk)
- All staff can flip a room's status (`available` / `occupied` / `cleaning` / `out of service`) via a restricted RPC

### Availability Search
- Pick check-in / check-out dates → instantly see rooms that are free for that range
- Correctly excludes rooms with overlapping active bookings and out-of-service rooms

### Bookings (full lifecycle)
- Create bookings with guest + dates + room; **total price auto-computed** (rate × nights)
- Status lifecycle: `booked → checked in → checked out`, with room status kept in sync (check-in marks the room occupied; check-out marks it for cleaning)
- Cancel anytime; editing allowed while the booking is still `booked`
- Filter chips (status) + guest-name search; every change instantly reflects on the Dashboard

### Guests
- Guest records with contact email / phone / ID number
- Search by name, add / edit / delete, and expand any guest to see their **booking history**

### Dashboard
- Live metrics derived from shared state: **current occupancy** (count + progress bar), **today's arrivals**, **today's departures**, and active bookings

### Security
- Row Level Security on every table; Admin-only room management; Front Desk changes room status via a restricted `update_room_status` RPC without room-edit rights
- Anonymous access fully blocked (verified with live probes)
- Secrets never committed: `.env` is git-ignored

---

## Screenshots

> Proof-of-concept captures from the Beta 1.1 build. (Click an image for the full-size version.)

### Auth

| | |
|---|---|
| <img src="App%20POC%201.0/Beta_Login_screen.png" alt="Login screen" width="280"> | <img src="App%20POC%201.0/Beta_Profile_screen.png" alt="Profile screen" width="280"> |
| **Login** — email/password with validation and loading/error states | **Profile** — staff name, role badge, email, Sign Out |

### Core Screens (Beta 1.1)

| | |
|---|---|
| <img src="App%20POC%201.0/Beta_1.1_Home_screen.png" alt="Home screen" width="280"> | <img src="App%20POC%201.0/Beta_1.1_Rooms_screen.png" alt="Rooms screen" width="280"> |
| **Dashboard** — today's arrivals/departures, current occupancy, active bookings | **Rooms** — live room list with status badges and admin controls |

| | |
|---|---|
| <img src="App%20POC%201.0/Beta_1.1_Availability_screen.png" alt="Availability screen" width="280"> | <img src="App%20POC%201.0/Beta_1.1_Booking_screen.png" alt="Booking screen" width="280"> |
| **Availability Search** — date-range picker and free-room results | **Bookings** — full lifecycle with filters, search, check-in/out/cancel |

| | |
|---|---|
| <img src="App%20POC%201.0/Beta_1.1_Guests_screen.png" alt="Guests screen" width="280"> | |
| **Guests** — records, search, and per-guest booking history | |

### Database

| | |
|---|---|
| <img src="App%20POC%201.0/Database_Tables.png" alt="Database tables" width="240"> | <img src="App%20POC%201.0/Database_schema_visual.png" alt="Database schema" width="360"> |
| **Database tables** — `staff`, `rooms`, `guests`, `bookings` in Supabase | **Schema visual** — relationships, FKs, enums and constraints |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.44 / Dart 3.12 (mobile + web, no desktop) |
| State management | flutter_riverpod 3.x (AsyncNotifier controllers, auto-refresh on writes) |
| Navigation | go_router 17.x (stateful shell with branch navigation) |
| Backend | Supabase (PostgreSQL, GoTrue auth, RLS) |
| Config | flutter_dotenv (`.env`, git-ignored) |
| Formatting/parsing | intl |

---

## Project Structure

```
lib/
├── config/          # AppConfig — .env loader (Supabase URL + anon key)
├── models/          # Room, Guest, Booking, enums — mirror the SQL schema
├── screens/
│   ├── auth/        # Login screen
│   ├── shell/       # Responsive app shell (bottom nav / side rail)
│   ├── dashboard/   # Occupancy, today's arrivals/departures, active bookings
│   ├── rooms/       # Room list + admin add/edit dialogs
│   ├── availability/# Date-range availability search
│   ├── bookings/    # Booking list + create/edit sheet, check-in/out/cancel
│   ├── guests/      # Guest records + per-guest booking history
│   └── profile/     # Staff profile, role badge, sign out
├── services/        # AuthService, RoomsService, GuestsService, BookingsService
├── state/           # Riverpod providers + controllers (auth, rooms, guests, bookings)
├── widgets/         # StatusBadge, InfoCard
├── theme/           # AppTheme (Material 3, indigo seed, spacing scale)
└── main.dart        # App entry — Supabase init + router
supabase/
├── migrations/
│   ├── 0001_schema.sql   # Tables, enums, FKs, constraints, RLS enable
│   └── 0002_rls_policies.sql  # RLS policies + is_admin() + update_room_status RPC
└── seed.sql          # Idempotent staff seed (matched to auth.users by email)
test/                 # Model + widget tests (auth gate, shell, navigation)
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
rooms    (id, room_number, room_type, rate_per_night >= 0, capacity,
          status: available|occupied|cleaning|out_of_service)
guests   (id, full_name, contact_email, contact_phone, id_number)
bookings (id, room_id → rooms, guest_id → guests, check_in_date, check_out_date,
          status: booked|checked_in|checked_out|cancelled, total_price >= 0,
          payment_status: unpaid|paid, created_by → staff)
```

All tables have `created_at`; bookings checks `check_out_date > check_in_date`; `staff.user_id` is unique. Booking `total_price` is computed client-side (room rate × nights) and stored with the booking.

---

## Security (RLS)

| Table | Authenticated staff | Anonymous |
|---|---|---|
| `staff` | read own row only | blocked |
| `rooms` | SELECT all; writes Admin-only | blocked |
| `guests` | SELECT / INSERT / UPDATE | blocked |
| `bookings` | SELECT / INSERT / UPDATE; DELETE Admin-only | blocked |

- `is_admin()` — SECURITY DEFINER helper used by policies
- `update_room_status(room_id, status)` — SECURITY DEFINER RPC callable by any authenticated staff member; changes *only* the room status (enables Front Desk check-in/out housekeeping without room-edit rights)
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
flutter test       # model tests + widget tests (auth gate, shell, navigation)
```

---

## Building for Release

```bash
flutter build web                        # web bundle → build/web
flutter build apk --release              # Android APK → build/app/outputs/flutter-apk
```

(Android build note: `kotlin.incremental=false` is set in `android/gradle.properties` to work around a cross-drive incremental-compile issue on this dev machine — harmless, slightly slower builds.)

---

## Deployment

### Before deploying (checklist)
1. **Rotate credentials** — the `test123` dev accounts (`*.hotelms.test`) must be deleted and replaced with real staff users (Authentication → Users in the dashboard); re-run `supabase/seed.sql` for their `staff` rows.
2. **Environment separation** — keep a `.env` per environment (dev/staging/prod). `.env` is git-ignored; never commit real keys. The anon/publishable key is safe to expose; the **service-role key and DB password must never leave the dashboard**.
3. **RLS is the security boundary** — it ships with the migrations; do not disable it in production.

### Web hosting
The web build (`build/web/`) is a static bundle — deployable to:
- **Supabase Hosting** (same dashboard as the backend; easiest)
- Netlify / Vercel / Cloudflare Pages (standard static deploys)
- GitHub Pages (repo already on GitHub)

There is no server-side rendering requirement — the app talks to Supabase directly from the browser (CORS is already configured for Supabase projects).

### Android
- `flutter build apk --release` → distribute via the Google Play Console or sideload the APK.

### Known trade-off (documented decision)
Booking `total_price` is computed **client-side** (room rate × nights) and stored with the booking. If you want server-side enforcement, add a trigger before exposing real payments:

```sql
create or replace function public.compute_booking_total()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.total_price := round(
    (select rate_per_night from public.rooms where id = new.room_id) *
    (new.check_out_date - new.check_in_date), 2);
  return new;
end $$;

create trigger bookings_compute_total
before insert or update on public.bookings
for each row execute function public.compute_booking_total();
```

---

## Roadmap

- [x] **Phase 1** — Project initialization (web target, deps, config, app shell)
- [x] **Phase 2** — Supabase setup (schema, auth, seed, RLS — verified live)
- [x] **Phase 3** — Navigation & app shell (go_router, responsive shell, design system, auth wiring)
- [x] **Phase 4** — Core data integration (rooms, availability, bookings, guests, dashboard — all live)
- [x] **Phase 5** — Polish & deployment prep (error/loading/empty states, accessibility, performance check, deployment guide)
- [ ] Post-launch: payment processing, email notifications, multi-property support

---

## License

Proprietary — © Onetatcode. All rights reserved. Single-contributor project; no external collaborators.

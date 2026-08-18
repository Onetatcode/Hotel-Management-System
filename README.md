# Hotel Management System

A **role-based hotel operations app** for staff — combines a responsive Flutter app (mobile + web) with Supabase (PostgreSQL, Auth, Row Level Security) to manage rooms, guests, and bookings end-to-end, wrapped in a soft neumorphic black + lime interface.

**Try it**: Sign in as Admin or Front Desk staff → land on the Dashboard with today's arrivals, departures, and live occupancy → open Rooms to flip statuses or (as Admin) add/edit/delete rooms → search Availability by date range → create bookings with auto-computed totals, then Check In, Cancel, or Edit them → Check Out and the room goes to cleaning automatically → manage guest records with per-guest booking history → sign out from the Profile screen.


---


## Architecture


```
┌─────────────────────────┐     ┌────────────────────────────────────────────┐
│       Flutter App       │────▶│                 Supabase                    │
│    (mobile + web)       │     │                                            │
│                         │     │  - Auth (GoTrue email/password)            │
│  - Login / Session      │     │  - PostgreSQL                              │
│  - Dashboard            │     │    (staff, rooms, guests, bookings)        │
│  - Rooms                │     │  - Row Level Security policies             │
│  - Availability Search  │     │  - SECURITY DEFINER RPC                     │
│  - Bookings             │     │    (update_room_status)                    │
│  - Guests               │     │  - Constraints + enums + FKs               │
│  - Profile              │     └────────────────────────────────────────────┘
│  - Soft neumorphic      │                       ▲
│    black + lime UI      │                       │
└─────────────────────────┘                       │
        │                                        │
        └────────────────────────────────────────┘
        (supabase_flutter, publishable key,
         RLS enforced server-side on every query)
```


## Features


### 🔐 Auth & Roles (2 roles)
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Email/password sign-in** | Session persistence (stays signed in across restarts), validation + loading/error states | Supabase GoTrue via `supabase_flutter` |
| **Role-aware access** | Admin vs Front Desk write rights, enforced in UI **and** RLS | `is_admin()` SECURITY DEFINER helper in policies |
| **Auth routing** | Unauthenticated users always land on Login; cold start restores session → Dashboard | go_router redirects |
| **Profile** | Staff name, role badge, email, one-tap Sign Out | `staff` table joined to `auth.users` |


### 🛏️ Rooms (Admin-managed)
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Room list** | Number, type, nightly rate, capacity, live status badge | `rooms` table, Riverpod async state |
| **Status control** | `available` / `occupied` / `cleaning` / `out of service` | Restricted `update_room_status` RPC (any staff) |
| **Admin CRUD** | Add / edit / delete rooms — write controls hidden for Front Desk | RLS policy + UI gating |


### 📅 Availability Search
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Date-range search** | Pick check-in / check-out → instantly see free rooms | `listAvailableRooms` service query |
| **Overlap exclusion** | Correctly excludes rooms with overlapping active bookings and out-of-service rooms | SQL window logic over `bookings` + `rooms.status` |


### 📖 Bookings (full lifecycle)
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Create / Edit** | Guest + dates + room; total price auto-computed (rate × nights) | Bottom-sheet form, client-side total |
| **Lifecycle** | `booked → checked in → checked out`, cancel anytime, edit while `booked` | `bookingsController` actions |
| **Housekeeping sync** | Check-in marks room occupied; check-out marks it `cleaning` | Transactional controller calls |
| **Filter & search** | Status filter chips + guest-name search | Local filter provider on shared state |
| **Payment status** | `unpaid` / `paid` badge per booking | `payment_status` column |


### 👤 Guests
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Guest records** | Full name, contact email / phone, ID number | `guests` table |
| **Search & CRUD** | Search by name/email; add, edit, delete (blocked when bookings exist) | FK + service layer |
| **Booking history** | Expand any guest to see their past bookings | Join on shared `bookings` state |


### 📊 Dashboard
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Live occupancy** | Count + lime progress bar, tappable → Rooms | Rooms state |
| **Today's arrivals / departures** | Booked check-ins and checked-in departures for today, tappable → Bookings | Bookings state |
| **Active bookings** | Total booked or checked in | Derived count |


### 🤖 Assistant (AI chatbot — OpenRouter)
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **7th nav destination** | Assistant tab on both mobile pill nav and desktop rail, after Profile | go_router branch + `AppShell` destinations |
| **Conversational help** | Hotel-ops / app-usage assistant with greeting, typing indicator, auto-scroll | `ChatMessagesController` + `ChatbotService` (OpenRouter, `nvidia/nemotron-3-super-120b-a12b:free`) |
| **Neumorphic chat UI** | Raised surface bubbles (assistant) / lime-filled bubbles (user), inset input pill, lime send button, `ErrorState` + retry | `NeumorphicBox` / `AppColors` / shared widgets |
| **Failure handling** | Non-200 / empty replies / timeouts surface a friendly fallback reply — the chat never crashes | `ChatbotException` + controller catch-all |

> The assistant has **no direct access** to live booking/guest data (system prompt enforces this) — it guides staff on using the app, it doesn't read the database.


### 🎨 UI & Design
| Feature | What's Covered | Method |
|---------|----------------|--------|
| **Soft neumorphic theme** | Black `#0E0F10` base, `#1C1F1D` cards, lime `#B6FF3C` accent — dual shadow (dark drop + faint highlight), no hairline borders | `AppColors`, `NeumorphicBox` in `lib/theme/` |
| **Typography** | Manrope geometric sans, bold headings | `google_fonts` (bundled at build time) |
| **Components** | Floating pill bottom nav, lime-filled pill buttons, ghost/outline secondary, inset search fields, outlined status pills, large-radius cards/dialogs/sheets | Shared `AppTheme` + `NeumorphicCard` / `StatusBadge` / `InfoCard` |
| **Responsive shell** | Bottom navigation bar on mobile, side navigation rail on desktop (breakpoint 700) — 7 destinations | `AppShell` + go_router stateful shell |
| **Error handling** | Error/empty states with Retry across all data screens | `ErrorState` widget |


## Screenshots


<div align="center">
  <table>
    <tr>
      <td><img src="App%20POC%201.1/Sign_in_screen.png" alt="Sign In" width="250"/></td>
      <td><img src="App%20POC%201.1/Dashboard_screen.png" alt="Dashboard" width="250"/></td>
      <td><img src="App%20POC%201.1/Rooms_screen.png" alt="Rooms" width="250"/></td>
    </tr>
    <tr>
      <td align="center"><b>Sign In</b></td>
      <td align="center"><b>Dashboard</b></td>
      <td align="center"><b>Rooms</b></td>
    </tr>
    <tr>
      <td><img src="App%20POC%201.1/Availability_screen.png" alt="Availability Search" width="250"/></td>
      <td><img src="App%20POC%201.1/Bookings_screen.png" alt="Bookings" width="250"/></td>
      <td><img src="App%20POC%201.1/Guests_screen.png" alt="Guests" width="250"/></td>
    </tr>
    <tr>
      <td align="center"><b>Availability Search</b></td>
      <td align="center"><b>Bookings</b></td>
      <td align="center"><b>Guests</b></td>
    </tr>
    <tr>
      <td><img src="App%20POC%201.1/Profile_screen.png" alt="Profile" width="250"/></td>
      <td><img src="App%20POC%20Ai/Ai1.0.png" alt="Assistant Chat" width="250"/></td>
      <td><img src="App%20POC%20Ai/Model%20Ai%201.0.png" alt="Assistant Model" width="250"/></td>
    </tr>
    <tr>
      <td align="center"><b>Profile</b></td>
      <td align="center"><b>Assistant Chat</b></td>
      <td align="center"><b>Assistant Model</b></td>
    </tr>
  </table>
</div>


## Tech Stack


| Layer          | Technology                                                                 |
|----------------|---------------------------------------------------------------------------|
| Frontend       | Flutter 3.44 / Dart 3.12 (mobile + web)                                    |
| State          | flutter_riverpod 3.x (AsyncNotifier controllers, shared live state)        |
| Navigation     | go_router 17.x (stateful shell, auth redirects, branch navigation)         |
| Backend        | Supabase (PostgreSQL, GoTrue auth, Row Level Security)                     |
| Typography     | google_fonts — Manrope (bundled at build time)                             |
| Formatting     | intl (date formatting)                                                     |
| Config         | flutter_dotenv (`.env`, git-ignored)                                       |
| Assistant      | OpenRouter API — `nvidia/nemotron-3-super-120b-a12b:free` via `https://openrouter.ai/api/v1/chat/completions` (`http` package) |


## Prerequisites


- Flutter SDK 3.44+ (bundled Dart 3.12+)
- Chrome or Edge (for Flutter web runs)
- Supabase project (free tier works)
- (Windows dev note) `flutter run -d chrome` uses Edge via the `CHROME_EXECUTABLE` environment variable


## Setup


### 1. Clone and Install Dependencies


```powershell
git clone https://github.com/Onetatcode/Hotel-Management-System.git
cd Hotel-Management-System
flutter pub get
```


### 2. Configure Supabase


Create a Supabase project at [supabase.com](https://supabase.com), enable the **Email** auth provider, then run the two migrations in the dashboard **SQL Editor**:

- `supabase/migrations/0001_schema.sql` — tables, enums, FKs, constraints, RLS enable
- `supabase/migrations/0002_rls_policies.sql` — RLS policies + `is_admin()` + `update_room_status` RPC

**Database — `bookings` table (core):**

```sql
create type booking_status as enum ('booked', 'checked_in', 'checked_out', 'cancelled');
create type payment_status as enum ('unpaid', 'paid');

create table bookings (
  id uuid default gen_random_uuid() primary key,
  room_id uuid not null references rooms(id),
  guest_id uuid not null references guests(id),
  check_in_date date not null,
  check_out_date date not null,
  status booking_status not null default 'booked',
  total_price numeric(10,2) not null check (total_price >= 0),
  payment_status payment_status not null default 'unpaid',
  created_by uuid references staff(id),
  created_at timestamptz default now(),
  constraint check_out_after_in check (check_out_date > check_in_date)
);
```


### 3. Environment Variables


**`.env`:**
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
OPENROUTER_API_KEY=your-openrouter-api-key
```

Get the Supabase values from your Supabase project (Project Settings → API). The publishable/anon key is safe to expose; the **service-role key and DB password must never leave the dashboard**. `OPENROUTER_API_KEY` powers the Assistant (chatbot) tab — create one at https://openrouter.ai/keys; paid models (e.g. `x-ai/grok-4.6`) need credits at https://openrouter.ai/settings/credits. The key lives in `.env` only (git-ignored); never hardcode or commit it, and rotate any key that was ever shared.


### 4. Seed Staff and Run


Create two staff auth users (Authentication → Users → Add user), then link them to `staff` rows by email with the idempotent `supabase/seed.sql`.

**Terminal — Flutter (dev mode):**
```powershell
flutter run -d chrome       # web
flutter run                 # Android (connected device/emulator)
```

**Or serve the pre-built app:**
```powershell
cd build\web
python -m http.server 3000
# Open http://localhost:3000
```

> **Development-only test accounts** — replace before any real deployment.

| Role | Email | Password |
|---|---|---|
| Admin | `admin@hotelms.test` | `test123` |
| Front Desk | `frontdesk@hotelms.test` | `test123` |


## Security (RLS)


| Table | Authenticated staff | Anonymous |
|-------|---------------------|-----------|
| `staff` | read own row only | blocked |
| `rooms` | SELECT all; writes Admin-only | blocked |
| `guests` | SELECT / INSERT / UPDATE | blocked |
| `bookings` | SELECT / INSERT / UPDATE; DELETE Admin-only | blocked |

- `is_admin()` — SECURITY DEFINER helper used by policies
- `update_room_status(room_id, status)` — SECURITY DEFINER RPC callable by any authenticated staff member; changes *only* the room status (enables Front Desk check-in/out housekeeping without room-edit rights)
- All policies verified live against the real database (permission vs constraint errors distinguished; anonymous access fully blocked)


## Project Structure


```
├── lib/                               # Flutter App
│   ├── main.dart                      # App entry — Supabase init + router
│   ├── config/
│   │   └── app_config.dart            # .env loader (Supabase URL/anon key + OpenRouter key)
│   ├── models/
│   │   ├── room.dart                  # Room model + wire statuses
│   │   ├── guest.dart                 # Guest model
│   │   ├── booking.dart               # Booking model (dates, totals, joins)
│   │   ├── chat_message.dart          # Chat roles + messages (Assistant)
│   │   └── enums.dart                 # Room/Booking/Payment status enums
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart      # Sign-in card
│   │   ├── shell/
│   │   │   └── app_shell.dart         # Floating pill nav (mobile) / rail (desktop)
│   │   ├── dashboard/                 # Occupancy, arrivals/departures, active
│   │   ├── rooms/                     # Room list + admin add/edit dialogs
│   │   ├── availability/              # Date-range availability search
│   │   ├── bookings/                  # List + create/edit sheet + lifecycle actions
│   │   ├── guests/                    # Guest records + booking history
│   │   ├── profile/                   # Staff profile, role badge, sign out
│   │   └── chatbot/                   # Assistant chat screen (OpenRouter)
│   ├── services/
│   │   ├── auth_service.dart          # Supabase auth
│   │   ├── rooms_service.dart         # Rooms CRUD + status RPC
│   │   ├── guests_service.dart        # Guests CRUD
│   │   └── bookings_service.dart      # Bookings CRUD + availability query
│   │   └── chatbot_service.dart       # OpenRouter chat-completions client
│   ├── state/
│   │   ├── auth_providers.dart        # Session + staff profile providers
│   │   ├── data_providers.dart        # rooms/guests/bookings controllers
│   │   └── chatbot_providers.dart     # Chat messages controller + is-sending flag
│   ├── widgets/
│   │   ├── neumorphic_card.dart       # Raised neumorphic surface
│   │   ├── status_badge.dart          # Outlined status pills
│   │   ├── info_card.dart             # Dashboard summary card
│   │   └── error_state.dart           # Error/empty state + retry
│   ├── theme/
│   │   ├── app_colors.dart            # Black + lime palette
│   │   ├── app_shadows.dart           # NeumorphicBox raised/inset shadows
│   │   └── app_theme.dart             # AppTheme.dark (Manrope, radii, components)
│   └── router/
│       └── app_router.dart            # Stateful shell routes + auth redirects
│
├── supabase/
│   ├── migrations/
│   │   ├── 0001_schema.sql            # Tables, enums, FKs, constraints, RLS enable
│   │   └── 0002_rls_policies.sql      # RLS policies + is_admin() + status RPC
│   └── seed.sql                       # Idempotent staff seed (matched by email)
│
├── test/                              # Model tests + widget tests (auth gate, shell)
├── App POC 1.0/                       # Beta 1.0/1.1 screenshots
├── App POC 1.1/                       # Beta 1.2 screenshots (neumorphic redesign)
├── App POC Ai/                        # Assistant chatbot screenshots (Ai 1.0)
├── .env                               # Environment variables (git-ignored)
└── README.md
```


## Current Limitations


- **Client-side `total_price`** — booking totals are computed as room rate × nights on the client and stored with the booking. For server-side enforcement before real payments, add a trigger:
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
- **Dev-only staff accounts** — the `test123` accounts (`*.hotelms.test`) must be deleted and replaced with real staff users before any production deployment (rotate credentials and re-run `seed.sql`).
- **No payments, email, or multi-property support yet** — planned post-launch.
- **Desktop target not built** — mobile + web are the supported targets.


## License


Proprietary — © Onetatcode. All rights reserved. Single-contributor project; no external collaborators.

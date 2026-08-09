# Implementation Plan — Hotel Management App

Stack: Flutter/Dart (frontend — mobile + web only, no desktop), Supabase (auth + database), Provider or Riverpod (state management). Backend logic lives primarily in Supabase (Postgres + RLS + optional Edge Functions) rather than a separate custom API server, unless a step below says otherwise.

---

## Phase 1: Project Initialization
**Goal:** A runnable Flutter skeleton targeting mobile and web, with a clean architecture in place.

- Initialize the Flutter project restricted to mobile + web targets: `flutter create --platforms=android,ios,web .`
- Set up folder structure: `lib/screens`, `lib/widgets`, `lib/models`, `lib/services`, `lib/state` (or `lib/providers`)
- Add core dependencies: `supabase_flutter`, state management package (`provider` or `flutter_riverpod`), `intl` (dates/currency), `go_router` (navigation)
- Set up `.env`/config handling for Supabase URL and anon key (do not hardcode secrets)
- Confirm the app builds and runs on both a mobile simulator/emulator and `flutter run -d chrome`

## Phase 2: Supabase Setup (Auth + Database)
**Goal:** Staff can log in, and the core data model exists with row-level security.

- Create Supabase project; enable email/password Auth
- Design DB schema (Postgres tables):
  - `staff` — id, user_id (FK to auth.users), name, role (admin | front_desk)
  - `rooms` — id, room_number, room_type, rate_per_night, capacity, status
  - `guests` — id, full_name, contact_email, contact_phone, id_number
  - `bookings` — id, room_id, guest_id, check_in_date, check_out_date, status (booked | checked_in | checked_out | cancelled), total_price, payment_status, created_by
- Set up Row Level Security: only authenticated staff can read/write; consider restricting room/rate edits to Admin role only
- Build Flutter auth screens: Login, Logout, session persistence, role-aware redirect (Admin vs Front Desk landing)

## Phase 3: Navigation & App Shell UI
**Goal:** Clean, responsive navigation shell that adapts between mobile and web layouts.

- Build a responsive navigation shell: bottom nav bar on mobile widths, a side rail/drawer on web/desktop widths (single shared shell, breakpoint-driven layout, not two separate apps)
- Define primary routes: Dashboard, Rooms, Availability Search, Bookings, Guests, Profile
- Establish the visual design system: typography scale, spacing, color palette, reusable components (status badges, cards, form fields)
- Wire navigation to real auth state (unauthenticated users always land on Login)

## Phase 4: Core Data Integration & State Management
**Goal:** Screens are wired to live Supabase data through a proper state management layer — no hardcoded/mock data remaining.

- Build the service layer (`lib/services`) — one class per resource (RoomsService, BookingsService, GuestsService) wrapping Supabase queries; no direct Supabase calls from widgets
- Build the state layer (`lib/state` or `lib/providers`) — providers/notifiers for rooms, bookings, guests, and current-user/role, backed by the service layer
- Implement Room Management screens (list, add/edit — Admin only) reading/writing through the state layer
- Implement Availability Search (date range picker → filtered room list)
- Implement Booking creation, edit, cancel, check-in, check-out — all flowing through BookingsService and updating shared state so the Dashboard and Booking List reflect changes immediately
- Implement Guest records (create/attach to booking, view guest's booking history)
- Implement Dashboard (today's arrivals/departures, current occupancy) computed from live booking state
- Implement Booking List/History with search and filters

## Phase 5 (Post-MVP placeholder — not detailed here)
Polish pass: loading/error states audit, empty states, accessibility pass, performance check on both platforms. Track this phase in `task_today.md` once Phase 4 is stable and audited.

---

**Note:** Each phase ends with an entry in `audit.md` — including a platform parity check (mobile + web) — before moving to the next phase.

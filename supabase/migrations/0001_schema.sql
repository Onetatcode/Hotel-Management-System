-- 0001_schema.sql
-- Hotel Management App — Phase 2 schema migration.
-- Creates the core data model: staff, rooms, guests, bookings.
-- RLS is ENABLED on every table with no policies yet (deny-all until 0002).

-- ---------- Enums ----------

create type staff_role as enum ('admin', 'front_desk');
create type room_status as enum ('available', 'occupied', 'cleaning', 'out_of_service');
create type booking_status as enum ('booked', 'checked_in', 'checked_out', 'cancelled');
create type payment_status as enum ('unpaid', 'paid');

-- ---------- staff ----------

create table public.staff (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  name text not null,
  role staff_role not null default 'front_desk'
);

alter table public.staff enable row level security;

-- ---------- rooms ----------

create table public.rooms (
  id uuid primary key default gen_random_uuid(),
  room_number text not null unique,
  room_type text not null,
  rate_per_night numeric(10, 2) not null check (rate_per_night >= 0),
  capacity int not null check (capacity > 0),
  status room_status not null default 'available'
);

alter table public.rooms enable row level security;

-- ---------- guests ----------

create table public.guests (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  contact_email text,
  contact_phone text,
  id_number text
);

alter table public.guests enable row level security;

-- ---------- bookings ----------

create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms (id) on delete restrict,
  guest_id uuid not null references public.guests (id) on delete restrict,
  check_in_date date not null,
  check_out_date date not null,
  status booking_status not null default 'booked',
  total_price numeric(10, 2) not null check (total_price >= 0),
  payment_status payment_status not null default 'unpaid',
  created_by uuid references public.staff (id) on delete set null,
  created_at timestamptz not null default now(),
  check (check_out_date > check_in_date)
);

alter table public.bookings enable row level security;

-- ---------- Indexes ----------

create index bookings_room_id_idx on public.bookings (room_id);
create index bookings_guest_id_idx on public.bookings (guest_id);
create index bookings_created_by_idx on public.bookings (created_by);
create index bookings_status_idx on public.bookings (status);
create index bookings_check_in_date_idx on public.bookings (check_in_date);
create index bookings_check_out_date_idx on public.bookings (check_out_date);

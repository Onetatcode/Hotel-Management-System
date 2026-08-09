# App Name
Hotel Management App

# Core Problem
Small-to-mid-size hotels typically juggle room availability, bookings, and guest records across spreadsheets, phone calls, and disconnected tools. Front-desk staff have no single, reliable app to check room availability, create or modify a booking, and see a guest's stay details — on either a desktop/web front desk or a mobile device while walking the property. There is no lightweight, purpose-built app that covers the core booking lifecycle end-to-end on both mobile and web from one codebase.

# Target Audience
- Hotel front-desk staff (primary users) — checking availability, creating/managing bookings, checking guests in and out
- Hotel managers/admins — overseeing rooms, rates, and booking activity
- Small-to-mid-size independent hotels or guesthouses without an existing PMS (property management system)

# Core Features (MVP Scope Only)
- **Auth & roles:** staff login (email/password via Supabase); two roles — Admin and Front Desk
- **Room management:** list of rooms with type, rate, capacity, and status (available / occupied / cleaning / out of service); Admin can add/edit rooms
- **Availability search:** pick a date range and see which rooms are available
- **Booking creation:** create a booking for a guest against an available room and date range, with auto-calculated total price
- **Booking management:** view, edit, and cancel existing bookings; check a guest in and check a guest out
- **Guest records:** basic guest profile (name, contact info, ID/passport number) attached to bookings
- **Dashboard:** today's arrivals, today's departures, and current occupancy at a glance
- **Booking list/history:** searchable/filterable list of all bookings (by date, status, guest name, room)
- **Responsive UI:** every screen above works correctly on both a mobile-width layout and a web/desktop-width layout from the same Flutter codebase

# Out of Scope (Do Not Build These)
- Native desktop apps (Windows/macOS/Linux) — mobile and web only
- Online guest-facing booking portal (this app is for staff use only, not public booking)
- Payment processing / payment gateway integration (record price and payment status only, no live transactions)
- Housekeeping task management, staff scheduling, or POS/restaurant billing
- Multi-property / multi-hotel management (single-property scope for MVP)
- Loyalty programs, discount codes, or dynamic/seasonal pricing engines
- Channel manager integrations (Booking.com, Expedia, etc.)
- Offline-first / full offline mode (assume network connectivity)
- Push notifications
- Reporting/analytics dashboards beyond the basic today's-arrivals/departures/occupancy view

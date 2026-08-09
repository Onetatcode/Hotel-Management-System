# Manual Testing Guide — Hotel Management App

Follow these steps in order after any build to confirm core functionality works end-to-end. Each test lists Preconditions, Steps, and Expected Result. **Run every test on both a mobile-width layout and a web/desktop-width layout** unless noted otherwise. Mark Pass/Fail per platform and log failures in `error_bug.md`.

---

## 1. Authentication & Roles

### 1.1 Login (Front Desk)
- **Preconditions:** App installed/running, not logged in, valid Supabase connection, a seeded Front Desk staff account
- **Steps:** Open app → enter Front Desk credentials → submit
- **Expected Result:** Logged in, redirected to Dashboard, session persists on app restart

### 1.2 Login (Admin)
- **Steps:** Log in with an Admin account
- **Expected Result:** Logged in, redirected to Dashboard, Admin-only actions (e.g. edit room rates) are visible/enabled

### 1.3 Invalid Login
- **Steps:** Enter incorrect password
- **Expected Result:** Clear error message shown, no crash, no navigation

### 1.4 Role Restriction
- **Steps:** As a Front Desk user, attempt to reach an Admin-only screen/action (e.g. edit a room's rate)
- **Expected Result:** Action is hidden or blocked with a clear message; direct navigation attempts don't bypass this

### 1.5 Logout
- **Steps:** Tap Logout
- **Expected Result:** Session cleared, returned to Login, protected screens no longer accessible

---

## 2. Room Management

### 2.1 View Room List
- **Steps:** Navigate to Rooms
- **Expected Result:** All rooms shown with type, rate, capacity, and current status; matches actual `rooms` table data

### 2.2 Add Room (Admin)
- **Steps:** As Admin, add a new room with valid details
- **Expected Result:** Room appears in the list immediately, persisted in Supabase

### 2.3 Edit Room (Admin)
- **Steps:** Edit an existing room's rate or status
- **Expected Result:** Change reflected immediately in the list and in any screen showing that room (e.g. Availability Search)

---

## 3. Availability Search

### 3.1 Search Available Rooms
- **Preconditions:** At least one room booked for a known date range, at least one room free
- **Steps:** Pick a date range that overlaps the booked room's dates
- **Expected Result:** The booked room is excluded from results; free rooms for that range are shown

### 3.2 Invalid Date Range
- **Steps:** Select a check-out date before the check-in date
- **Expected Result:** App blocks the search or shows a validation error, no crash

---

## 4. Booking Lifecycle

### 4.1 Create Booking
- **Preconditions:** Logged in, a room available for chosen dates, a guest record (new or existing)
- **Steps:** From Availability Search, select a room → enter/select guest → confirm dates → submit
- **Expected Result:** Booking created with status `booked`, correct auto-calculated total price, visible in Booking List and on Dashboard if check-in is today

### 4.2 Edit Booking
- **Steps:** Open an existing booking, change dates or room
- **Expected Result:** Updated booking reflects new details; price recalculates correctly; room availability updates accordingly

### 4.3 Cancel Booking
- **Steps:** Cancel an existing booking
- **Expected Result:** Status becomes `cancelled`; the room becomes available again for those dates; booking still visible in history with cancelled status

### 4.4 Check-In
- **Steps:** On a booking with today's check-in date, tap Check In
- **Expected Result:** Status becomes `checked_in`; room status updates to `occupied`; guest appears correctly under "current occupancy" on Dashboard

### 4.5 Check-Out
- **Steps:** On a checked-in booking, tap Check Out
- **Expected Result:** Status becomes `checked_out`; room status updates (e.g. to `cleaning` or `available` per business rule); booking moves out of "current occupancy"

---

## 5. Guests

### 5.1 Create Guest During Booking
- **Steps:** During booking creation, enter a new guest's details
- **Expected Result:** Guest record created and correctly linked to the booking

### 5.2 Reuse Existing Guest
- **Steps:** Search for an existing guest while creating a new booking
- **Expected Result:** Existing guest is found and attached; no duplicate guest record created

### 5.3 View Guest Booking History
- **Steps:** Open a guest's profile
- **Expected Result:** All of that guest's past and current bookings are listed accurately

---

## 6. Dashboard

### 6.1 Today's Arrivals / Departures
- **Preconditions:** At least one booking with check-in today, one with check-out today
- **Steps:** Open Dashboard
- **Expected Result:** Both bookings appear in the correct sections; counts match actual data

### 6.2 Current Occupancy
- **Steps:** Check a guest in, then reload Dashboard
- **Expected Result:** Occupancy count/percentage updates correctly

---

## 7. Booking List / History

### 7.1 Filter by Status
- **Steps:** Filter the booking list by each status (booked, checked_in, checked_out, cancelled)
- **Expected Result:** Only matching bookings shown for each filter

### 7.2 Search by Guest Name / Room
- **Steps:** Search using a known guest name, then a known room number
- **Expected Result:** Correct, matching results returned for each search

---

## 8. UI / Responsive Design QA

### 8.1 Navigation Shell Adapts Correctly
- **Steps:** Resize the web app across breakpoints; compare against mobile app
- **Expected Result:** Bottom nav on mobile widths, side rail/drawer on web/desktop widths; no broken or overlapping nav elements at any width

### 8.2 No Layout Overflow
- **Steps:** Visit every screen on both a small phone width and a wide desktop width
- **Expected Result:** No overflow, clipped text, or broken layouts on either extreme

### 8.3 Design Consistency
- **Steps:** Navigate through every screen
- **Expected Result:** Typography, spacing, colors, and reusable components (status badges, cards, form fields) are consistent across the app

---

## 9. Regression Pass (Run Before Each Release)
- [ ] Login as Front Desk and as Admin
- [ ] Create, edit, and cancel a booking
- [ ] Check a guest in and out
- [ ] Dashboard reflects the above changes correctly
- [ ] Room availability search excludes booked rooms correctly
- [ ] All of the above verified on both mobile and web
- [ ] No console errors during the full flow above

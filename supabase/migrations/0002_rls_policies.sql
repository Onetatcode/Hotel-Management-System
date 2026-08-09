-- 0002_rls_policies.sql
-- Hotel Management App — Phase 2 RLS policies.
-- Run AFTER 0001_schema.sql and after staff accounts are seeded (seed.sql).

-- ---------- Helper: is_admin() ----------
-- SECURITY DEFINER so it can read the staff table (which is RLS-protected)
-- as the function owner.

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.staff
    where user_id = auth.uid() and role = 'admin'
  );
$$;

-- ---------- staff: self-read only ----------
-- Staff rows are created via seed/scripts; no self-service DML.

create policy "staff_self_select" on public.staff
  for select to authenticated
  using (auth.uid() = user_id);

-- ---------- rooms ----------
-- All authenticated staff can view; only admins can add/edit/delete.

create policy "rooms_select_authenticated" on public.rooms
  for select to authenticated
  using (true);

create policy "rooms_insert_admin" on public.rooms
  for insert to authenticated
  with check (public.is_admin());

create policy "rooms_update_admin" on public.rooms
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "rooms_delete_admin" on public.rooms
  for delete to authenticated
  using (public.is_admin());

-- ---------- guests ----------
-- All authenticated staff can read/create/update guests; delete is Admin-only.

create policy "guests_select_authenticated" on public.guests
  for select to authenticated
  using (true);

create policy "guests_insert_authenticated" on public.guests
  for insert to authenticated
  with check (true);

create policy "guests_update_authenticated" on public.guests
  for update to authenticated
  using (true)
  with check (true);

create policy "guests_delete_admin" on public.guests
  for delete to authenticated
  using (public.is_admin());

-- ---------- bookings ----------
-- All authenticated staff can read/create/update bookings; delete is Admin-only
-- (cancellation is a status update, not a delete).

create policy "bookings_select_authenticated" on public.bookings
  for select to authenticated
  using (true);

create policy "bookings_insert_authenticated" on public.bookings
  for insert to authenticated
  with check (true);

create policy "bookings_update_authenticated" on public.bookings
  for update to authenticated
  using (true)
  with check (true);

create policy "bookings_delete_admin" on public.bookings
  for delete to authenticated
  using (public.is_admin());

-- ---------- update_room_status RPC ----------
-- Lets Front Desk staff change only a room's status (check-in/out, cleaning)
-- without granting full room-editing rights. SECURITY DEFINER (bypasses RLS)
-- but requires the caller to be an authenticated staff member.

create or replace function public.update_room_status(
  p_room_id uuid,
  p_status public.room_status
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.staff where user_id = auth.uid()
  ) then
    raise exception 'Not a staff member';
  end if;

  update public.rooms
  set status = p_status
  where id = p_room_id;

  if not found then
    raise exception 'Room not found';
  end if;
end;
$$;

grant execute on function public.update_room_status(uuid, public.room_status) to authenticated;

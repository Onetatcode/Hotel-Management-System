-- seed.sql
-- Hotel Management App — Phase 2 seed data.
-- Creates staff profile rows linked to auth.users by email.
-- Run AFTER creating the auth users in the dashboard (Authentication > Users > Add user).
-- Idempotent: safe to run multiple times.

insert into public.staff (user_id, name, role)
select id, 'Hotel Admin', 'admin'
from auth.users
where email = 'admin@hotelms.test'
on conflict (user_id) do nothing;

insert into public.staff (user_id, name, role)
select id, 'Front Desk Staff', 'front_desk'
from auth.users
where email = 'frontdesk@hotelms.test'
on conflict (user_id) do nothing;

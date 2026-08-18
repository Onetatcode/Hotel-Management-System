-- 0003_assistant_usage.sql
-- Hotel Management App — AI Assistant usage quota (Phase B, OWASP LLM10).
-- Run AFTER 0002_rls_policies.sql.

-- ---------- assistant_usage ----------
-- One row per staff member per day. Counts are write-only via the RPC below;
-- staff can read only their own row.

create table public.assistant_usage (
  id uuid primary key default gen_random_uuid(),
  staff_id uuid not null references public.staff(id) on delete cascade,
  usage_date date not null default current_date,
  message_count integer not null default 0 check (message_count >= 0),
  error_count integer not null default 0 check (error_count >= 0),
  updated_at timestamptz not null default now(),
  unique (staff_id, usage_date)
);

alter table public.assistant_usage enable row level security;

create policy "assistant_usage_self_select" on public.assistant_usage
  for select to authenticated
  using (auth.uid() = (select user_id from public.staff where id = staff_id));

-- ---------- update_assistant_usage RPC ----------
-- SECURITY DEFINER (same pattern as update_room_status): verifies the caller
-- owns the staff row, upserts today's usage with the given deltas, and returns
-- the new daily message count so the client can enforce its quota.

create or replace function public.update_assistant_usage(
  p_staff_id uuid,
  p_message_delta integer default 1,
  p_error_delta integer default 0
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  if not exists (
    select 1 from public.staff
    where id = p_staff_id and user_id = auth.uid()
  ) then
    raise exception 'Not an authorized staff member';
  end if;

  insert into public.assistant_usage (staff_id, usage_date, message_count, error_count)
  values (p_staff_id, current_date, greatest(p_message_delta, 0), greatest(p_error_delta, 0))
  on conflict (staff_id, usage_date)
  do update set
    message_count = public.assistant_usage.message_count + excluded.message_count,
    error_count = public.assistant_usage.error_count + excluded.error_count,
    updated_at = now();

  select message_count into v_count
  from public.assistant_usage
  where staff_id = p_staff_id and usage_date = current_date;

  return v_count;
end;
$$;

grant execute on function public.update_assistant_usage(uuid, integer, integer) to authenticated;

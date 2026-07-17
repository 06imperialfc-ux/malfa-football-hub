-- MALFA security hardening migration
-- Review, then run once in Supabase SQL Editor.
-- This is idempotent and does not delete competition data.

begin;

-- Separate ordinary administrators from super administrators.
create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
      and active = true
      and role = 'super_admin'
  );
$$;

revoke all on function public.is_super_admin() from public;
grant execute on function public.is_super_admin() to authenticated;

-- Ordinary admins can read only their own role. Super admins can manage the allow-list.
drop policy if exists "admin users read" on public.admin_users;
drop policy if exists "admin users manage" on public.admin_users;
drop policy if exists "admins read own role" on public.admin_users;
drop policy if exists "super admins manage admin users" on public.admin_users;

create policy "admins read own role" on public.admin_users
for select to authenticated
using (user_id = auth.uid() or public.is_super_admin());

create policy "super admins manage admin users" on public.admin_users
for all to authenticated
using (public.is_super_admin())
with check (public.is_super_admin());

-- Do not expose arbitrary future settings to anonymous users.
drop policy if exists "public settings" on public.site_settings;
drop policy if exists "public safe settings" on public.site_settings;
create policy "public safe settings" on public.site_settings
for select to anon, authenticated
using (
  public.is_admin()
  or key in ('season', 'show_tournaments', 'show_partners')
);

-- Keep internal fixture notes and timestamps out of the anonymous Data API.
revoke select on public.fixtures from anon;
grant select (
  id, competition_id, season, matchday, round_name, kickoff_at, venue,
  home_club_id, away_club_id, home_score, away_score,
  status, verified, featured
) on public.fixtures to anon;

-- Restrict the media bucket to common web image types and a sensible size.
update storage.buckets
set file_size_limit = 5242880,
    allowed_mime_types = array['image/png','image/jpeg','image/webp']::text[]
where id = 'league-media';

-- Content-change audit trail for accountability and incident investigation.
create table if not exists public.content_audit_log (
  id bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  actor_id uuid,
  action text not null check (action in ('INSERT','UPDATE','DELETE')),
  table_name text not null,
  record_key text,
  old_data jsonb,
  new_data jsonb
);

create index if not exists content_audit_log_occurred_idx
  on public.content_audit_log (occurred_at desc);
create index if not exists content_audit_log_actor_idx
  on public.content_audit_log (actor_id, occurred_at desc);

alter table public.content_audit_log enable row level security;
revoke all on public.content_audit_log from anon, authenticated;
grant select on public.content_audit_log to authenticated;

drop policy if exists "super admins read audit log" on public.content_audit_log;
create policy "super admins read audit log" on public.content_audit_log
for select to authenticated
using (public.is_super_admin());

create or replace function public.write_content_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  old_row jsonb;
  new_row jsonb;
  key_value text;
begin
  if tg_op <> 'INSERT' then old_row := to_jsonb(old); end if;
  if tg_op <> 'DELETE' then new_row := to_jsonb(new); end if;

  key_value := coalesce(
    new_row ->> 'id', new_row ->> 'key',
    old_row ->> 'id', old_row ->> 'key'
  );

  insert into public.content_audit_log
    (actor_id, action, table_name, record_key, old_data, new_data)
  values
    (auth.uid(), tg_op, tg_table_name, key_value, old_row, new_row);

  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;

revoke all on function public.write_content_audit_log() from public;

-- Recreate triggers safely.
do $$
declare
  t text;
begin
  foreach t in array array[
    'competitions','clubs','competition_entries','fixtures','standings',
    'news_posts','partners','site_settings','admin_users'
  ]
  loop
    execute format('drop trigger if exists audit_%I_changes on public.%I', t, t);
    execute format(
      'create trigger audit_%I_changes after insert or update or delete on public.%I for each row execute function public.write_content_audit_log()',
      t, t
    );
  end loop;
end $$;

commit;

-- MALFA scoped administrator roles
-- Run after supabase-schema.sql and malfa-security-hardening.sql.
-- Existing `admin` users are migrated to league_admin but receive no scope until a superadmin assigns it.

begin;

alter table public.admin_users drop constraint if exists admin_users_role_check;
update public.admin_users set role = 'league_admin' where role = 'admin';
alter table public.admin_users add constraint admin_users_role_check
  check (role in ('super_admin','league_admin','club_admin'));

create table if not exists public.admin_competitions (
  user_id uuid not null references public.admin_users(user_id) on delete cascade,
  competition_id text not null references public.competitions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, competition_id)
);

create table if not exists public.admin_clubs (
  user_id uuid not null references public.admin_users(user_id) on delete cascade,
  club_id uuid not null references public.clubs(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, club_id)
);

alter table public.admin_competitions enable row level security;
alter table public.admin_clubs enable row level security;

create or replace function public.has_admin_role(required_role text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.admin_users where user_id=auth.uid() and active and role=required_role);
$$;

create or replace function public.can_manage_competition(target_id text)
returns boolean language sql stable security definer set search_path = public as $$
  select public.has_admin_role('super_admin') or exists(
    select 1 from public.admin_users u join public.admin_competitions s on s.user_id=u.user_id
    where u.user_id=auth.uid() and u.active and u.role='league_admin' and s.competition_id=target_id
  );
$$;

create or replace function public.can_manage_club(target_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.has_admin_role('super_admin') or exists(
    select 1 from public.admin_users u join public.admin_clubs s on s.user_id=u.user_id
    where u.user_id=auth.uid() and u.active and u.role='club_admin' and s.club_id=target_id
  );
$$;

revoke all on function public.has_admin_role(text), public.can_manage_competition(text), public.can_manage_club(uuid) from public;
grant execute on function public.has_admin_role(text), public.can_manage_competition(text), public.can_manage_club(uuid) to authenticated;

drop policy if exists "admin competitions" on public.competitions;
drop policy if exists "admin clubs" on public.clubs;
drop policy if exists "admin entries" on public.competition_entries;
drop policy if exists "admin fixtures" on public.fixtures;
drop policy if exists "admin standings" on public.standings;
drop policy if exists "admin news" on public.news_posts;
drop policy if exists "admin partners" on public.partners;
drop policy if exists "admin settings" on public.site_settings;

create policy "super admins manage competitions" on public.competitions for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));
create policy "scoped admins update clubs" on public.clubs for update to authenticated
  using (public.can_manage_club(id) or public.has_admin_role('super_admin'))
  with check (public.can_manage_club(id) or public.has_admin_role('super_admin'));
create policy "super admins create delete clubs" on public.clubs for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));
create policy "super admins manage entries" on public.competition_entries for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));
create policy "league admins manage fixtures" on public.fixtures for all to authenticated
  using (public.can_manage_competition(competition_id)) with check (public.can_manage_competition(competition_id));
create policy "league admins manage standings" on public.standings for all to authenticated
  using (public.can_manage_competition(competition_id)) with check (public.can_manage_competition(competition_id));
create policy "scoped admins manage news" on public.news_posts for all to authenticated
  using (public.has_admin_role('super_admin') or public.can_manage_competition(competition_id) or public.can_manage_club(club_id))
  with check (public.has_admin_role('super_admin') or public.can_manage_competition(competition_id) or public.can_manage_club(club_id));
create policy "super admins manage partners" on public.partners for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));
create policy "super admins manage settings" on public.site_settings for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

drop policy if exists "admins read own competition scopes" on public.admin_competitions;
drop policy if exists "super admins manage competition scopes" on public.admin_competitions;
drop policy if exists "admins read own club scopes" on public.admin_clubs;
drop policy if exists "super admins manage club scopes" on public.admin_clubs;
create policy "admins read own competition scopes" on public.admin_competitions for select to authenticated
  using (user_id=auth.uid() or public.has_admin_role('super_admin'));
create policy "super admins manage competition scopes" on public.admin_competitions for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));
create policy "admins read own club scopes" on public.admin_clubs for select to authenticated
  using (user_id=auth.uid() or public.has_admin_role('super_admin'));
create policy "super admins manage club scopes" on public.admin_clubs for all to authenticated
  using (public.has_admin_role('super_admin')) with check (public.has_admin_role('super_admin'));

grant select on public.admin_competitions, public.admin_clubs to authenticated;
grant insert, update, delete on public.admin_competitions, public.admin_clubs to authenticated;

create or replace function public.grant_admin_access(
  target_email text, target_role text, competition_ids text[] default '{}', club_ids uuid[] default '{}'
) returns uuid language plpgsql security definer set search_path = public, auth as $$
declare target_user uuid;
begin
  if not public.has_admin_role('super_admin') then raise exception 'Superadmin access required'; end if;
  if target_role not in ('super_admin','league_admin','club_admin') then raise exception 'Invalid administrator role'; end if;
  select id into target_user from auth.users where lower(email)=lower(trim(target_email));
  if target_user is null then raise exception 'No Supabase Auth user exists for this email'; end if;
  insert into public.admin_users(user_id,role,active) values(target_user,target_role,true)
    on conflict(user_id) do update set role=excluded.role,active=true;
  delete from public.admin_competitions where user_id=target_user;
  delete from public.admin_clubs where user_id=target_user;
  if target_role='league_admin' then
    insert into public.admin_competitions(user_id,competition_id) select target_user,unnest(competition_ids);
  elsif target_role='club_admin' then
    insert into public.admin_clubs(user_id,club_id) select target_user,unnest(club_ids);
  end if;
  return target_user;
end; $$;

revoke all on function public.grant_admin_access(text,text,text[],uuid[]) from public;
grant execute on function public.grant_admin_access(text,text,text[],uuid[]) to authenticated;

create or replace function public.list_admin_access()
returns table(user_id uuid, email text, role text, active boolean, competition_ids text[], club_ids uuid[])
language sql stable security definer set search_path = public, auth as $$
  select u.id, u.email::text, a.role, a.active,
    coalesce((select array_agg(s.competition_id order by s.competition_id) from public.admin_competitions s where s.user_id=u.id),'{}'::text[]),
    coalesce((select array_agg(s.club_id) from public.admin_clubs s where s.user_id=u.id),'{}'::uuid[])
  from public.admin_users a join auth.users u on u.id=a.user_id
  where public.has_admin_role('super_admin')
  order by a.role, u.email;
$$;

revoke all on function public.list_admin_access() from public;
grant execute on function public.list_admin_access() to authenticated;

commit;

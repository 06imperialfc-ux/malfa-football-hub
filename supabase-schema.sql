-- MALFA production competition platform schema
-- Run this entire file once in Supabase SQL Editor.
-- After creating the first Auth user, run the administrator command in CMS-SETUP.md.

create extension if not exists pgcrypto;

create table if not exists public.competitions (
  id text primary key,
  slug text not null unique,
  name text not null,
  short_name text not null,
  category text,
  type text not null default 'league' check (type in ('league','tournament')),
  description text,
  accent text default '#d8202f',
  sort_order integer not null default 100,
  visible boolean not null default true,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clubs (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  short_name text,
  crest_url text,
  location text,
  ground text,
  founded_year integer,
  description text,
  website text,
  instagram text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.competition_entries (
  id uuid primary key default gen_random_uuid(),
  competition_id text not null references public.competitions(id) on delete cascade,
  club_id uuid not null references public.clubs(id) on delete cascade,
  season text not null default '2026',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (competition_id,club_id,season)
);

create table if not exists public.fixtures (
  id uuid primary key default gen_random_uuid(),
  competition_id text not null references public.competitions(id) on delete cascade,
  season text not null default '2026',
  matchday integer,
  round_name text,
  kickoff_at timestamptz,
  venue text,
  home_club_id uuid not null references public.clubs(id) on delete restrict,
  away_club_id uuid not null references public.clubs(id) on delete restrict,
  home_score integer check (home_score is null or home_score >= 0),
  away_score integer check (away_score is null or away_score >= 0),
  status text not null default 'scheduled' check (status in ('scheduled','live','finished','postponed','cancelled')),
  verified boolean not null default false,
  featured boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (home_club_id <> away_club_id)
);

create table if not exists public.standings (
  id uuid primary key default gen_random_uuid(),
  competition_id text not null references public.competitions(id) on delete cascade,
  season text not null default '2026',
  club_id uuid not null references public.clubs(id) on delete cascade,
  position integer not null default 1,
  played integer not null default 0,
  won integer not null default 0,
  drawn integer not null default 0,
  lost integer not null default 0,
  goals_for integer not null default 0,
  goals_against integer not null default 0,
  goal_difference integer not null default 0,
  points_adjustment integer not null default 0,
  points integer not null default 0,
  updated_at timestamptz not null default now(),
  unique (competition_id,season,club_id)
);

create table if not exists public.news_posts (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  category text not null default 'Football News',
  excerpt text,
  body text,
  image_url text,
  competition_id text references public.competitions(id) on delete set null,
  club_id uuid references public.clubs(id) on delete set null,
  published boolean not null default false,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tier text not null default 'Official Partner',
  logo_url text,
  website text,
  description text,
  display_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- Explicit administrator allow-list. Merely having a Supabase Auth account does not grant editing access.
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role in ('admin','super_admin')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid() and active = true
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

insert into public.competitions (id,slug,name,short_name,category,type,description,accent,sort_order,visible,active) values
('u11','u11','Under 11','U11','Junior','league','Foundation football and early player development.','#e23b47',10,true,true),
('u13','u13','Under 13','U13','Junior','league','Technical growth and competitive junior football.','#e23b47',20,true,true),
('u15','u15','Under 15','U15','Junior','league','A key development stage for young players and teams.','#d8202f',30,true,true),
('u17','u17','Under 17','U17','Junior','league','Advanced youth competition preparing players for senior football.','#c21827',40,true,true),
('u19','u19','Under 19','U19','Junior','league','The bridge between junior development and senior football.','#ab101d',50,true,true),
('mpl','mpl','Men''s Promotional League','MPL','Senior','league','Senior competition and a pathway towards promotion.','#8f0d18',60,true,true),
('super-league','super-league','Super League','SUPER','Senior','league','The leading MALFA senior league competition.','#202020',70,true,true),
('wpl','wpl','Women''s Promotional League','WPL','Women','league','Competitive women''s football and a platform for growth.','#ef5964',80,true,true)
on conflict (id) do update set
  slug = excluded.slug,
  name = excluded.name,
  short_name = excluded.short_name,
  category = excluded.category,
  type = excluded.type,
  description = excluded.description,
  accent = excluded.accent,
  sort_order = excluded.sort_order;

insert into public.site_settings (key,value)
values ('season','"2026"'::jsonb)
on conflict (key) do nothing;

create index if not exists fixtures_competition_date_idx on public.fixtures (competition_id,kickoff_at);
create index if not exists standings_competition_idx on public.standings (competition_id,season,points desc,goal_difference desc);
create index if not exists news_publish_idx on public.news_posts (published,published_at desc);
create index if not exists partners_order_idx on public.partners (active,display_order);

alter table public.competitions enable row level security;
alter table public.clubs enable row level security;
alter table public.competition_entries enable row level security;
alter table public.fixtures enable row level security;
alter table public.standings enable row level security;
alter table public.news_posts enable row level security;
alter table public.partners enable row level security;
alter table public.site_settings enable row level security;
alter table public.admin_users enable row level security;

-- Drop older policy names so this file can safely replace a previous test schema.
drop policy if exists "public visible competitions" on public.competitions;
drop policy if exists "public active clubs" on public.clubs;
drop policy if exists "public visible entries" on public.competition_entries;
drop policy if exists "public competition fixtures" on public.fixtures;
drop policy if exists "public competition standings" on public.standings;
drop policy if exists "public published news" on public.news_posts;
drop policy if exists "public active partners" on public.partners;
drop policy if exists "public settings" on public.site_settings;
drop policy if exists "admin competitions" on public.competitions;
drop policy if exists "admin clubs" on public.clubs;
drop policy if exists "admin entries" on public.competition_entries;
drop policy if exists "admin fixtures" on public.fixtures;
drop policy if exists "admin standings" on public.standings;
drop policy if exists "admin news" on public.news_posts;
drop policy if exists "admin partners" on public.partners;
drop policy if exists "admin settings" on public.site_settings;
drop policy if exists "admin users read" on public.admin_users;
drop policy if exists "admin users manage" on public.admin_users;

create policy "public visible competitions" on public.competitions
for select to anon, authenticated
using ((active and visible) or public.is_admin());

create policy "public active clubs" on public.clubs
for select to anon, authenticated
using (active or public.is_admin());

create policy "public visible entries" on public.competition_entries
for select to anon, authenticated
using (active or public.is_admin());

create policy "public competition fixtures" on public.fixtures
for select to anon, authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.competitions c
    where c.id = competition_id and c.active and c.visible
  )
);

create policy "public competition standings" on public.standings
for select to anon, authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.competitions c
    where c.id = competition_id and c.active and c.visible
  )
);

create policy "public published news" on public.news_posts
for select to anon, authenticated
using (published or public.is_admin());

create policy "public active partners" on public.partners
for select to anon, authenticated
using (active or public.is_admin());

create policy "public settings" on public.site_settings
for select to anon, authenticated
using (true);

create policy "admin competitions" on public.competitions
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin clubs" on public.clubs
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin entries" on public.competition_entries
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin fixtures" on public.fixtures
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin standings" on public.standings
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin news" on public.news_posts
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin partners" on public.partners
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin settings" on public.site_settings
for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin users read" on public.admin_users
for select to authenticated using (public.is_admin());
create policy "admin users manage" on public.admin_users
for all to authenticated using (public.is_admin()) with check (public.is_admin());

grant usage on schema public to anon, authenticated;
grant select on public.competitions, public.clubs, public.competition_entries, public.fixtures,
  public.standings, public.news_posts, public.partners, public.site_settings to anon, authenticated;
grant insert, update, delete on public.competitions, public.clubs, public.competition_entries,
  public.fixtures, public.standings, public.news_posts, public.partners, public.site_settings to authenticated;
grant select, insert, update, delete on public.admin_users to authenticated;

insert into storage.buckets (id,name,public)
values ('league-media','league-media',true)
on conflict (id) do update set public=true;

drop policy if exists "public league media" on storage.objects;
drop policy if exists "admin upload league media" on storage.objects;
drop policy if exists "admin update league media" on storage.objects;
drop policy if exists "admin delete league media" on storage.objects;

create policy "public league media" on storage.objects
for select to public using (bucket_id='league-media');
create policy "admin upload league media" on storage.objects
for insert to authenticated with check (bucket_id='league-media' and public.is_admin());
create policy "admin update league media" on storage.objects
for update to authenticated using (bucket_id='league-media' and public.is_admin())
with check (bucket_id='league-media' and public.is_admin());
create policy "admin delete league media" on storage.objects
for delete to authenticated using (bucket_id='league-media' and public.is_admin());

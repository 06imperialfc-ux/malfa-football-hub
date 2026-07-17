-- Read-only MALFA security audit checks.
-- Run each section in Supabase SQL Editor.

-- 1. All exposed public tables should have Row Level Security enabled.
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;

-- 2. Review all public-schema RLS policies.
select schemaname, tablename, policyname, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

-- 3. Confirm administrator roles and active state.
select u.email, a.role, a.active, a.created_at
from public.admin_users a
join auth.users u on u.id = a.user_id
order by a.role desc, u.email;

-- 4. Confirm media bucket restrictions after hardening.
select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id = 'league-media';

-- 5. Confirm no service-role or secret-like value was accidentally stored in site settings.
select key, value
from public.site_settings
where key ~* '(secret|password|token|service|private|key)';

-- 6. Find public content that may need a privacy review.
select id, title, published, club_id, competition_id, published_at
from public.news_posts
where published = true
order by published_at desc nulls last;

-- 7. Review recent content changes after the audit-log migration.
select occurred_at, actor_id, action, table_name, record_key
from public.content_audit_log
order by occurred_at desc
limit 100;

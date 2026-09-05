-- Run after malfa-role-scope-migration.sql. Transactional and rerunnable.
begin;

-- Public readers see published data; private records require the relevant scope.
-- These helpers return false for anonymous callers.
grant execute on function public.has_admin_role(text), public.can_manage_competition(text), public.can_manage_club(uuid) to anon;

drop policy if exists "public visible competitions" on public.competitions;
create policy "public visible competitions" on public.competitions for select to anon, authenticated
using ((active and visible) or public.can_manage_competition(id));
drop policy if exists "public active clubs" on public.clubs;
create policy "public active clubs" on public.clubs for select to anon, authenticated
using (active or public.can_manage_club(id));
drop policy if exists "public visible entries" on public.competition_entries;
create policy "public visible entries" on public.competition_entries for select to anon, authenticated
using (public.can_manage_competition(competition_id) or public.can_manage_club(club_id) or
  (active and exists(select 1 from public.competitions c where c.id=competition_id and c.active and c.visible)));
drop policy if exists "public competition fixtures" on public.fixtures;
create policy "public competition fixtures" on public.fixtures for select to anon, authenticated
using (public.can_manage_competition(competition_id) or
  exists(select 1 from public.competitions c where c.id=competition_id and c.active and c.visible));
drop policy if exists "public competition standings" on public.standings;
create policy "public competition standings" on public.standings for select to anon, authenticated
using (public.can_manage_competition(competition_id) or
  exists(select 1 from public.competitions c where c.id=competition_id and c.active and c.visible));
drop policy if exists "public published news" on public.news_posts;
create policy "public published news" on public.news_posts for select to anon, authenticated
using (published or public.has_admin_role('super_admin') or
  public.can_manage_competition(competition_id) or public.can_manage_club(club_id));
drop policy if exists "public active partners" on public.partners;
create policy "public active partners" on public.partners for select to anon, authenticated
using (active or public.has_admin_role('super_admin'));
drop policy if exists "public safe settings" on public.site_settings;
create policy "public safe settings" on public.site_settings for select to anon, authenticated
using (key in ('season','show_tournaments','show_partners') or public.has_admin_role('super_admin'));

-- Scope media mutation to the uploading administrator. Superadmins retain control
-- of existing legacy files. Public image reads remain available.
drop policy if exists "admin upload league media" on storage.objects;
drop policy if exists "admin update league media" on storage.objects;
drop policy if exists "admin delete league media" on storage.objects;
create policy "admin upload league media" on storage.objects for insert to authenticated
with check (bucket_id='league-media' and public.is_admin() and (storage.foldername(name))[1]=auth.uid()::text);
create policy "admin update league media" on storage.objects for update to authenticated
using (bucket_id='league-media' and (public.has_admin_role('super_admin') or
  (public.is_admin() and (storage.foldername(name))[1]=auth.uid()::text)))
with check (bucket_id='league-media' and (public.has_admin_role('super_admin') or
  (public.is_admin() and (storage.foldername(name))[1]=auth.uid()::text)));
create policy "admin delete league media" on storage.objects for delete to authenticated
using (bucket_id='league-media' and (public.has_admin_role('super_admin') or
  (public.is_admin() and (storage.foldername(name))[1]=auth.uid()::text)));

-- Audit assignment changes as well as role changes.
drop trigger if exists audit_competition_scopes on public.admin_competitions;
create trigger audit_competition_scopes after insert or update or delete on public.admin_competitions
for each row execute function public.write_content_audit_log();
drop trigger if exists audit_club_scopes on public.admin_clubs;
create trigger audit_club_scopes after insert or update or delete on public.admin_clubs
for each row execute function public.write_content_audit_log();
commit;

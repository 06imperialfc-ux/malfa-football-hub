# MALFA Competition Platform

A responsive multi-competition website for the Mamelodi Local Football Association.

## Divisions

- U11
- U13
- U15
- U17
- U19
- Men's Promotional League (MPL)
- Super League
- Women's Promotional League (WPL)

## Public website

- `index.html` — homepage
- `matches.html` — verified results
- `fixtures.html` — upcoming fixtures
- `standings.html` — responsive league tables
- `clubs.html` and `club.html` — club directory and profiles
- `news.html` and `article.html` — association news
- `competitions.html` — division overview
- `tournaments.html` — hidden or public cup competitions
- `partners.html` — sponsors and partners
- `about.html` and `contact.html` — association information

## Administration

Open `admin.html` after completing `CMS-SETUP.md`.

Authorised administrators can manage:

- divisions
- hidden and public tournaments
- clubs, division assignments and crest changes
- fixtures, live status and verified results
- league tables
- football news
- sponsors and partners

## Demo and live modes

With blank values in `js/cms-config.js`, the website runs in local demo mode and browser changes are not shared.

After a Supabase project URL and publishable key are added, the same site runs as a live shared CMS. The status in `admin.html` changes to **Live CMS**.

## Launch order

1. Create and secure Supabase.
2. Run `supabase-schema.sql`.
3. Create and allow-list the first administrator.
4. Connect `js/cms-config.js`.
5. Test locally.
6. Upload to GitHub.
7. Enable GitHub Pages.
8. Add official clubs, fixtures and news.

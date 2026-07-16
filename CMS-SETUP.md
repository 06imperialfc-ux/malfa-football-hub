# MALFA CMS Production Setup

This setup uses Supabase for the shared database, administrator login and media storage. The public website remains a static site that can be hosted on GitHub Pages.

## 1. Create the Supabase project

Create a new Supabase project. Use a strong database password and store it safely. The password is not added to the website files.

## 2. Create the database

Open **SQL Editor**, create a new query, paste the complete contents of `supabase-schema.sql`, and run it.

The schema creates:

- league divisions and hidden/revealable tournaments
- clubs and division assignments
- fixtures and verified results
- automatically stored league standings
- news posts
- sponsors and partners
- site settings
- a public media bucket for crests, news images and partner logos
- an explicit administrator allow-list

## 3. Create the first administrator

In **Authentication > Users**, create the authorised administrator account.

Then return to **SQL Editor** and run this command after replacing the email address:

```sql
insert into public.admin_users (user_id, role)
select id, 'super_admin'
from auth.users
where lower(email) = lower('YOUR-ADMIN-EMAIL@example.com')
on conflict (user_id) do update
set role = excluded.role, active = true;
```

Confirm it worked:

```sql
select au.email, adm.role, adm.active
from public.admin_users adm
join auth.users au on au.id = adm.user_id;
```

Only users listed in `public.admin_users` can edit the CMS.

## 4. Lock down public sign-ups

Open the Supabase authentication settings and disable **Allow new users to sign up**. Existing authorised users can still sign in.

## 5. Connect the website

Open **Project Settings > API Keys** and copy:

- Project URL
- Publishable key

Edit `js/cms-config.js`:

```js
window.MALFA_CMS = {
  supabaseUrl: "https://YOUR-PROJECT.supabase.co",
  supabasePublishableKey: "YOUR-PUBLISHABLE-KEY",
  storageBucket: "league-media"
};
```

The publishable key is intended for browser use with Row Level Security. Never add a secret key, service-role key or database password to this file or to GitHub.

## 6. Test before deployment

Run the folder using a local web server, then check:

1. The public site loads all eight divisions.
2. `admin.html` displays **Live CMS**, not **Demo mode**.
3. The administrator can sign in.
4. A test club can be created with a crest.
5. The test club appears publicly.
6. A fixture can be added and edited.
7. A verified finished result rebuilds its league table.
8. A tournament remains hidden until **Reveal publicly** is enabled.

## 7. Publish with GitHub Pages

Upload the contents of the `mamelodi-football-hub` folder to the root of a GitHub repository. In the repository's **Settings > Pages**, select **Deploy from a branch**, choose the main branch and the root folder, then save.

## Table calculation rules

The dashboard ranks clubs in this order:

1. Points
2. Goal difference
3. Goals scored
4. Wins
5. Club name

Points are calculated as three per win and one per draw, plus any administrator-entered points adjustment. The **Rebuild from verified results** button recalculates a table from finished fixtures marked as verified. Saving a verified finished result also triggers a rebuild.

## Crest changes

Edit a club in the **Clubs** tab and upload a replacement crest. Tables, fixtures, results and club profiles all use the same crest record, so the replacement appears throughout the site.

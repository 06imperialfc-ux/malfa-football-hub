# Apply the MALFA security patch

1. Back up the Supabase project and GitHub repository.
2. Run `malfa-security-hardening.sql` in Supabase SQL Editor.
3. Run the first four sections of `malfa-security-audit-checks.sql` and confirm the expected policies and bucket restrictions.
4. Upload the HTML files, `js/admin.js`, `js/site.js`, `js/theme.js`, and `vercel.json` to the matching repository locations.
5. Commit and push. Wait for Vercel to redeploy.
6. Confirm `privacy.html` opens and replace the privacy contact if `info@malfa.co.za` is not the official Information Officer address.
7. Test that an unauthorised Supabase Auth account is rejected by `admin.html`.
8. Test that SVG/PDF uploads and images over 5 MB are rejected.
9. Inspect production response headers for CSP, HSTS, no-sniff, frame denial and permissions policy.

The SQL migration does not delete competition data. It changes administrator-role policies, restricts anonymous fixture columns, limits media uploads, narrows public settings and adds a content audit log.

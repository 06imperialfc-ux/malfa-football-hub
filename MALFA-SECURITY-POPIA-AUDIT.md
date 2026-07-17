# MALFA Website Security and POPIA Audit

**Audit date:** 17 July 2026  
**Scope:** Static MALFA website, administrator dashboard JavaScript, Supabase schema/RLS/storage configuration, and Vercel deployment configuration supplied in the current project package.  
**Audit type:** Source-code and configuration review. This is not a full penetration test and did not include live network scanning because the final Vercel URL was not supplied and the audit environment could not resolve the Supabase host.

## Executive assessment

**Current overall risk before hardening: Medium–High**  
**POPIA launch readiness before hardening: Incomplete**

The project has a good base: it uses a browser-safe Supabase publishable key, enables Row Level Security on the application tables, restricts writes to an explicit administrator allow-list, escapes most CMS text before rendering, and does not currently store player identity numbers, medical details, addresses or similar high-risk information.

However, one critical role-management weakness and several high-priority security and POPIA gaps should be fixed before the platform is presented as a fully production-ready association system.

## Critical and high-priority technical findings

### F-01 — Any administrator can manage all administrators

**Severity:** Critical  
**Evidence:** `supabase-schema.sql` gives the `admin users manage` policy to every user for whom `is_admin()` returns true. The `role` field exists, but `super_admin` is not used to restrict administrator management.

**Impact:** A normal administrator can add another administrator, promote accounts, deactivate the legitimate super administrator, or expand access without approval.

**Required remediation:** Only `super_admin` accounts may insert, update or delete rows in `admin_users`. Ordinary administrators should be able to read only their own role.

**Status in supplied hardening package:** Fixed by `malfa-security-hardening.sql`.

### F-02 — The dashboard does not verify the allow-list before opening

**Severity:** High  
**Evidence:** The current `admin.js` displays the dashboard for any valid Supabase Auth session and relies on RLS to reject unauthorised database actions.

**Impact:** An authenticated but unauthorised user sees the management interface. RLS currently limits the data and blocks writes, but the behaviour is misleading and increases exposure to future policy mistakes.

**Required remediation:** Query the signed-in user’s active `admin_users` record before showing the dashboard. Sign out and deny access if no active record exists.

**Status in supplied hardening package:** Fixed in `js/admin.js`.

### F-03 — No multi-factor authentication for administrators

**Severity:** High  
**Impact:** A stolen or reused password gives access to competition data, publishing, tables and media.

**Required remediation:** Protect the Supabase organisation and GitHub/Vercel accounts with MFA immediately. Add TOTP MFA to the application administrator flow before allowing multiple association officials to use the CMS. Require long unique passwords, disable public sign-up, review Auth rate limits and enable bot protection where practical.

**Status:** Operational action still required. The supplied patch does not implement the MFA enrolment screen.

### F-04 — Missing Content Security Policy and other browser security headers

**Severity:** High  
**Evidence:** The current project has no `vercel.json` security headers and loads `@supabase/supabase-js@2` without an exact version.

**Impact:** A future HTML or dependency injection bug has fewer browser-level controls. The floating major-version CDN reference can change without a reviewed code commit.

**Required remediation:** Pin the SDK version, move inline JavaScript to a local file, deploy a restrictive Content Security Policy, deny framing, disable MIME sniffing, restrict browser permissions and prevent admin-page caching.

**Status in supplied hardening package:** Fixed with `vercel.json`, `js/theme.js`, exact SDK version `2.110.7`, and updated HTML files.

### F-05 — Media uploads lack application and bucket restrictions

**Severity:** High  
**Evidence:** The live upload code accepts any extension and size. The public storage bucket is not configured with allowed MIME types or a per-bucket size limit.

**Impact:** An administrator account or compromised session could upload unexpected file types or very large files, increasing malware, content-abuse, egress and denial-of-service risk.

**Required remediation:** Accept only PNG, JPEG and WebP; cap images at 5 MB in both the browser and Supabase bucket; reject SVG, HTML and arbitrary extensions.

**Status in supplied hardening package:** Fixed in `js/admin.js` and `malfa-security-hardening.sql`.

## Medium-priority technical findings

### F-06 — Internal fixture notes are available through the anonymous API

**Severity:** Medium  
**Evidence:** Anonymous users receive table-level `SELECT` on `fixtures`, and the public client queries `select("*")`. The `notes` column is therefore queryable even though it is not shown on the page.

**Impact:** An administrator may mistakenly enter internal notes, phone numbers, disciplinary details or ground-management information that becomes publicly retrievable.

**Required remediation:** Grant anonymous users access only to safe fixture columns and make the public website request those columns explicitly. Never put private operational information into a public fixture record.

**Status in supplied hardening package:** Fixed.

### F-07 — No content-change audit trail

**Severity:** Medium  
**Impact:** MALFA cannot reliably determine who changed a score, deleted a club, published an article or altered an administrator account. This weakens accountability, dispute handling and incident investigation.

**Required remediation:** Record actor ID, action, table, record key, timestamp, old values and new values. Restrict audit-log access to super administrators.

**Status in supplied hardening package:** Fixed by database triggers in `malfa-security-hardening.sql`.

### F-08 — All future site settings would be publicly readable

**Severity:** Medium  
**Evidence:** The public `site_settings` policy uses `true` for every row.

**Impact:** A future administrator could accidentally store an internal token, email template or private configuration in that table and expose it publicly.

**Required remediation:** Publicly allow-list only non-sensitive setting keys such as season and visibility flags. Secrets must never be stored in browser-readable tables.

**Status in supplied hardening package:** Fixed.

### F-09 — No documented backup and recovery process

**Severity:** Medium  
**Impact:** Accidental deletion, malicious edits or a platform failure may cause loss of standings, fixtures or news. Audit logs do not replace backups.

**Required remediation:** Document database backup/export frequency, storage-media backup, restore testing, repository recovery and the people authorised to initiate a restore. Test restoration before the official handover.

**Status:** Operational action required.

## POPIA and South African compliance findings

### L-01 — No complete section 18 privacy notification

**Risk:** High compliance gap  
**Relevant law:** POPIA sections 17–18 and data-subject rights in sections 23–25.

The live site needs a clear privacy notice identifying MALFA, the information processed, purposes, whether provision is mandatory, recipients/operators, international transfers, retention criteria, rights, Information Officer contact and complaint route.

**Status in supplied hardening package:** A `privacy.html` template is included. MALFA must confirm the official legal name, Information Officer details, address and email before launch.

### L-02 — Junior divisions create child-data risk

**Risk:** High if names or images of junior players are published  
**Relevant law:** POPIA sections 34–35.

The current database does not have player-profile fields, which materially reduces risk. However, news articles and images can identify children. MALFA needs a documented rule requiring a valid lawful basis and, where required, prior consent from a competent person. Consent records should be retained securely outside the public website. Do not collect or publish children’s identity numbers, medical details, private phone numbers, home addresses, school details or precise routine information.

**Status:** Governance and consent process required before publishing junior-player content.

### L-03 — Operator contracts and cross-border processing need formal review

**Risk:** Medium–High  
**Relevant law:** POPIA sections 21 and 72.

Supabase processes authentication, database and media information; Vercel processes hosting, delivery and technical logs. MALFA should retain written operator arrangements covering security and breach notification, sign/request the applicable Supabase DPA, retain the applicable Vercel DPA/terms, document subprocessors and verify the selected database region. Any processing outside South Africa needs a documented section 72 transfer basis and adequate safeguards.

**Status:** Contractual and governance action required.

### L-04 — No formal retention and deletion schedule

**Risk:** Medium  
**Relevant law:** POPIA sections 13–14.

MALFA needs a schedule for administrator accounts, authentication/audit logs, correspondence, media, consent records, public sporting archives and backups. Records must be deleted, destroyed or de-identified when MALFA is no longer authorised to retain them.

**Status:** Operational policy required.

### L-05 — No data-subject request procedure

**Risk:** Medium  
**Relevant law:** POPIA sections 23–25.

MALFA needs an internal process for access, correction, deletion, restriction and objection requests, including identity verification, response ownership and a request register.

**Status:** Operational procedure required.

### L-06 — No security-compromise response plan

**Risk:** High during an incident  
**Relevant law:** POPIA section 22.

Create an incident plan covering containment, evidence preservation, operator notification, scope analysis, password/session revocation, communication approval, Information Regulator reporting and data-subject notification. The Information Officer must own the process. Do not wait for a website relaunch to define it.

**Status:** Operational procedure required.

### L-07 — Information Officer and PAIA governance not evidenced

**Risk:** Medium  
**Relevant law:** POPIA section 55 and PAIA.

MALFA should confirm whether it is operating as a private body or another legal form, register the Information Officer with the Information Regulator, designate deputies where appropriate, prepare and publish the applicable PAIA manual, and maintain the prescribed request channels.

**Status:** Association/legal administration action required.

## Positive controls observed

- No Supabase secret/service-role key or database password appears in the website source.
- Application tables have Row Level Security enabled.
- Public access is limited to visible/active competitions, active clubs, published news and active partners.
- Database writes are limited to authenticated allow-listed administrators.
- The schema prevents a club from playing itself.
- Most CMS text is HTML-escaped before it is inserted into the page.
- Public results require a verified state before they appear as completed results.
- Media writes are restricted to administrators.
- The current data model does not collect player ID numbers, birth dates, medical records or private contact information.

## Required launch sequence

### Before the president presentation

1. Run `malfa-security-hardening.sql` in Supabase.
2. Upload the hardened website files and allow Vercel to redeploy.
3. Confirm public sign-up is disabled.
4. Enable MFA on Supabase, GitHub and Vercel owner accounts.
5. Confirm the official Information Officer contact shown in `privacy.html`.
6. Do not publish identifiable junior-player content unless the consent/lawful-basis process is operating.
7. Test public pages, administrator access, unauthorised login rejection, image restrictions and table edits.

### Before wider administrator access

1. Implement application-level TOTP MFA.
2. Sign/retain operator DPAs and document cross-border safeguards.
3. Register the Information Officer and finalise the PAIA manual.
4. Adopt retention, access-request, child-content and breach-response procedures.
5. Establish backups and test a restore.
6. Review audit logs regularly and remove dormant administrators immediately.

## Verification after applying the patch

Run `malfa-security-audit-checks.sql`. Confirm:

- every application table has RLS enabled;
- ordinary admins cannot insert/update/delete `admin_users`;
- the media bucket allows only PNG, JPEG and WebP up to 5 MB;
- anonymous users cannot query `fixtures.notes`;
- unauthorised authenticated accounts cannot open the dashboard;
- security headers are visible on the Vercel deployment;
- recent content changes appear in `content_audit_log`.

## Final conclusion

The website is suitable for public football information after the critical database policy, administrator verification, upload restriction and browser-header fixes are deployed. It should not be described as fully POPIA-compliant solely because the code is hardened. POPIA compliance also requires accountable people, notices, child-data controls, contracts, retention, request handling, incident response and continuing review.

# MALFA implementation status

## Completed in repository

* Admin authentication callback and scope error handling fixed.
* Dashboard navigation checks administrator roles.
* Standings calculations isolate the configured season and reject missing scores.
* Unverification and competition changes rebuild affected tables.
* Club assignment updates preserve other seasons.
* Separate public and admin build outputs; public output omits admin source and SQL.
* Private-record and media permission migration prepared in `malfa-access-boundaries.sql`.

## Live verification

The project has resumed and reports Healthy. The owner applied all three
security migrations and activated the temporary superadmin. Direct SQL checks
confirmed both scope tables and the audit table exist. Under the authenticated
role, the superadmin can manage MPL and read one directory entry. A nonexistent
user has no superadmin or MPL management rights and sees zero directory/audit
rows. These checks ran in rolled-back transactions without persisting data.
League/club isolation and actual browser login still require testing.

The portal now includes role-editing controls and an on-demand recent activity
view. Separate admin deployment requires signing into the Vercel owner account.

## Remaining work

* Build and test invitations, password recovery and access revocation; browser-test role editing.
* Protect the last superadmin, validate grants and expose audit history.
* Make result and standings updates transactional in the database.
* Deploy a separate admin project and configure Auth redirect URLs.
* Test public pages, mobile layouts, performance and accessibility.
* Import approved official data, configure and test backup recovery.
* Exercise every role and the fixture-to-table workflow against the live project.

## Builds

Public: `node scripts/build.cjs`.

Admin: set `MALFA_DEPLOYMENT=admin` and run the same command in a separate
deployment project. Publish `dist`. Public project redirects must not be copied
to the admin project; configure its root to serve the generated `index.html`.
An admin address is not a substitute for database permissions.

## Migration order

1. `supabase-schema.sql` (initial setup only).
2. `malfa-security-hardening.sql`.
3. `malfa-role-scope-migration.sql`.
4. `malfa-access-boundaries.sql`.

Do not rerun the initial schema on a secured production project: it reinstates
the original broad access policies. Back up first and validate every role after
migration. The newest migration has not yet been executed against PostgreSQL.

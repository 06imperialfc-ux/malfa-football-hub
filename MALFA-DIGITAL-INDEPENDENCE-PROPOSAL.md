# MALFA Digital Independence Proposal

## Purpose

This document explains the idea behind a MALFA-owned competition and registration platform.

The proposal is not based on seeking personal profit or asking the football community to create a new source of money. It is based on using existing registration expenditure more efficiently so that MALFA can own and operate more of its digital infrastructure.

The intended outcome is:

- MALFA ownership of its website, competition records and operational data
- lower long-term platform costs
- continued compliance with SAFA and FIFA requirements
- transparent use of registration income
- any remaining operational surplus retained for football development

## The Current Situation

MALFA currently relies on Inqaku/MYSAFA for functions that include player registration, player verification, competition information and player cards.

Based on information currently available to the project team, registration fees are approximately:

- Junior player: R15
- Senior player: R25

These figures must be confirmed against current official invoices, contracts or fee schedules before they are used in a formal financial decision.

The concern is not simply that a third-party service is being used. The concern is that a per-player charge grows every time the number of registered players grows. MALFA therefore carries a recurring variable cost while ownership of the operational platform and its future development remains outside the association.

Inqaku/MYSAFA also provides an important function: access to the recognised SAFA and FIFA player-registration structure. MALFA must not lose this legitimacy while pursuing greater independence.

## The Proposed Model

MALFA would own and operate its own platform for:

- competitions and divisions
- clubs and club profiles
- fixtures and venues
- verified results
- league tables
- news and official notices
- partners and sponsors
- registration applications
- club confirmation and administrator approval
- digital player cards
- QR-based card verification
- operational reporting and backups

SAFA would remain the authority for:

- official player recognition
- SAFA and FIFA identifiers
- national registration status
- transfers and regulatory legitimacy
- any requirements that only the national association may approve

The goal is therefore not independence from SAFA. It is operational independence from avoidable third-party dependency while preserving the official football-registration chain.

## Existing Money, Not New Money

This proposal does not depend on finding a new source of money.

The registration income already exists:

```text
Registration income =
(junior registrations x R15) + (senior registrations x R25)
```

Under the current model, the per-player amount is paid to the third-party registration platform.

Under the proposed model, the same registration income could be applied in this order:

1. Pay any unavoidable SAFA/FIFA registration or integration cost.
2. Cover payment-processing charges.
3. Cover MALFA platform infrastructure and approved operating expenses.
4. Maintain a restricted emergency reserve.
5. Retain the remaining balance for approved football-development purposes.

No balance should be paid into a developer's personal account. All income and expenditure should pass through an approved association-controlled account and be supported by receipts and periodic reports.

## Evidence of Scale

The revised MALFA fixture for 5-6 September 2026 contains approximately:

- 41 matches
- 82 team appearances
- 32 junior fixtures
- 9 senior, women's or other fixtures
- approximately 69 distinct team/division entries after repeated teams are removed

Using a working estimate of 20 registered players per team:

```text
69 teams x 20 players = approximately 1,380 players
```

Using an approximate 8:2 junior-to-senior ratio:

```text
1,104 juniors x R15 = R16,560
276 seniors x R25 = R6,900
Estimated registration value = R23,460
```

This is not R23,460 generated every weekend. Players ordinarily register for a season or registration window. The weekend fixture is evidence of the number of players and teams represented in MALFA competitions.

It may also understate the complete MALFA player base because:

- not every registered team plays every weekend
- clubs may operate multiple teams across age divisions
- squad registrations can exceed the players selected for one match
- younger registered players may be eligible to play in older age groups
- MPL and SPL activity may be limited during their off-season
- other teams and competitions may not appear in this particular fixture

A final projection requires MALFA's complete club, team and player-registration totals.

## Lean Operating Model

The platform is being developed by the project lead as an in-kind contribution. MALFA officials and existing volunteers would continue assisting with the administrative work they already perform.

The initial model assumes:

| Item | Working estimate |
|---|---:|
| ChatGPT Plus | R400 per month |
| Electricity and development data | R200 per month |
| Primary and defensive domains | R1,100-R2,400 per year |
| Hosting | Free tier initially |
| Database | Supabase Free tier initially |
| SSL certificates | Free |
| GitHub repository | Free |
| Basic backup storage | R500-R1,000 per year |
| Restricted contingency reserve | R6,000 |
| Development and design labour charged to MALFA | R0 initially |
| Use of the developer's personal computer | R0 initially |

A reasonable first-year working provision is approximately R15,000-R18,000. This is not necessarily a request for outside funding. It can potentially be recovered from the existing registration flow once the model is approved.

Paid hosting, a higher database tier, a dedicated computer, SMS notifications and physical card equipment should only be introduced when actual usage demonstrates the need.

## Example Financial Scenarios

With an estimated 80% junior and 20% senior registration mix, the average registration income is approximately R17 per player.

| Registered players | Estimated registration income | Balance after an R18,000 first-year provision |
|---:|---:|---:|
| 1,380 | R23,460 | R5,460 |
| 2,000 | R34,000 | R16,000 |
| 3,000 | R51,000 | R33,000 |
| 4,000 | R68,000 | R50,000 |
| 5,000 | R85,000 | R67,000 |
| 6,000 | R102,000 | R84,000 |
| 8,000 | R136,000 | R118,000 |
| 10,000 | R170,000 | R152,000 |

These are planning estimates, not guaranteed profits. They exclude:

- payment-processing charges
- physical card production
- refunds or failed payments
- confirmed SAFA/FIFA fees
- taxes or accounting obligations
- future paid infrastructure
- any approved operational staffing

For an association or non-profit body, the preferred term is **operational surplus**, not personal profit.

## Player Cards

Automatic cards can be an optional feature rather than a requirement for the first release.

A practical initial workflow would be:

1. The player submits a registration application.
2. The club confirms the player and documents.
3. An authorised MALFA registrar checks the official SAFA/MYSAFA record.
4. The registrar approves or rejects the application.
5. The MALFA platform automatically generates a digital or printable card.
6. A QR code links to a MALFA verification page showing the card's current status.

A card may include:

- player photograph
- full name
- club and division
- season
- MALFA registration number
- authorised SAFA/FIFA identifier
- verification date
- expiry date
- QR verification code
- active, suspended, transferred or expired status

The public QR page must not expose identity numbers, passport numbers, private contact details or sensitive information concerning junior players.

## SAFA and FIFA Legitimacy

MALFA can build its own registration intake, administration and card-generation system. However, MALFA cannot independently invent SAFA or FIFA identifiers or describe cards as officially SAFA-verified without authorisation.

A legitimate route requires one of the following:

1. An official SAFA-approved API integration.
2. An authorised data exchange or scheduled export.
3. Delegated access allowing MALFA registrars to work directly with the official registration system.
4. Manual verification by an authorised registrar during the pilot period.

MALFA must obtain written clarification from SAFA covering:

- whether MALFA may operate its own electronic registration system
- how SAFA and FIFA IDs may be created, retrieved or confirmed
- whether an official integration interface is available
- the conditions for recognition of MALFA-generated player cards
- mandatory national, regional or LFA fees
- player-transfer and duplicate-registration controls
- data ownership and data-export rights
- security, POPIA and retention requirements
- the approval and testing process for a replacement or connected system

Until that approval exists, the MALFA platform should not claim to replace official SAFA/FIFA registration.

## Financial Governance

The recommended financial process is:

1. All registration income enters an approved MALFA-controlled account.
2. Each payment receives a receipt and registration reference.
3. Actual infrastructure and processing costs are recorded.
4. The emergency reserve is maintained separately.
5. The following season's approved operating requirement is retained.
6. The remaining surplus is allocated to approved football-development purposes.
7. Registration totals, operating costs and allocations are reported after every window or season.

If funds are to be transferred directly to SAFA, this must happen under a written agreement identifying the destination account, calculation method, reporting responsibilities and payment dates.

## Suggested Pilot

### Stage 1 - Demonstration

- Populate one complete competition.
- Demonstrate clubs, fixtures, results and tables.
- Show a registration application.
- Manually approve a sample player.
- Generate a clearly marked demonstration card.
- Demonstrate QR verification.
- Present the cost and ownership model.

### Stage 2 - Controlled MALFA Pilot

- Select one division or a small number of clubs.
- Run MALFA registration intake alongside the official process.
- Reconcile every approved player against the official record.
- Test duplicates, transfers, expiry, suspensions and corrections.
- Measure the time and cost per registration.
- Do not discontinue the existing official process during the pilot.

### Stage 3 - Authorised Rollout

- Obtain written SAFA approval.
- Complete any required integration.
- Migrate or reconcile official records.
- Train authorised MALFA and club administrators.
- Introduce recognised cards only after approval.
- Review finances and compliance after the first registration window.

## Information Still Required

Before a final business case can be approved, MALFA should provide:

- total registered junior players
- total registered senior players
- number of clubs
- number of team/division entries
- registrations per window and per season
- current Inqaku/MYSAFA fee schedule
- current invoices and contractual terms
- number of transfers and renewals
- current card-production process and cost
- responsible MALFA and SAFA decision-makers
- official requirements for retaining affiliation and accreditation

## Core Proposal Statement

> MALFA is not asking its football community to create a new source of registration money. The association is considering whether existing registration expenditure can be used more efficiently: first to satisfy all SAFA and FIFA obligations, then to operate MALFA-owned digital infrastructure, with any remaining operational surplus retained for transparent football-development purposes.

## Important Status

This document is a concept and planning proposal. It is not evidence of approval by MALFA, SAFA, FIFA or Inqaku. All registration fees, player totals, integration rights and accreditation requirements must be formally confirmed before implementation.

# CLAUDE.md — eDRMP Implementation Playbook

> **Read this entire file before writing a single line of code.**
> This file is the **only** source of truth for the build order and rules.
> The phase ordering in `docs/implementation_phases.md` is **rejected and superseded** by Section 8 of this file. If anything in the user's prompts conflicts with this file, ask — do not improvise.

---

## 0. How This Playbook Works

1. The project is delivered in **15 phases (0, 1, 1.5, 2–8, 9A, 9B, 9C, 9D, 10)**. One phase at a time. Period.
2. Claude Code may **not** start phase N+1 until the user explicitly says *"Begin Phase N+1."*
3. Every phase has a **Graphify pre-implementation read + post-implementation rebuild**, defined in Section 3. Skipping either step is a phase failure.
4. **Backend phases (9A–9D) additionally require a Migration Manifest** (Section 4). Every schema change, Supabase manual step, and Edge Function deployment must be documented before code runs.
5. After every phase, Claude Code writes an **Implementation Report** (template in Section 10) to `docs/reports/PHASE_NN_REPORT.md` and **stops**. No "while I'm here let me also fix X."
6. Reports go to a separate auditor (the planning Claude). The auditor returns either:
   - ✅ **Approve** → user authorises the next phase.
   - ✏️ **Change requests** → Claude Code applies them as a fix-up on the same phase, regenerates the report, stops.
7. **Designs are authoritative**, not the existing code. See Section 1.

---

## 1. Replacement Mandate

The `lib/features/**` tree contains placeholder/non-design-faithful screens. **Treat them as if they don't exist.** Every feature screen must match the Claude Design handoff.

- File exists with placeholder content → **overwrite completely**.
- File isn't needed → delete it (report the deletion).
- Folder structure preserved as-is. Only file *contents* are scorched.

The Claude Design handoff (Section 7) is the visual contract.

---

## 2. Zero-Lint Policy (NON-NEGOTIABLE)

Every phase ends with **`flutter analyze` printing exactly `No issues found!`**.

**Hard rules:**
- No unused imports, variables, parameters, or private fields.
- No `print()`. `debugPrint` only inside `kDebugMode` guards.
- No `// TODO:` for the current phase. Future-phase TODOs must cite the phase: `// TODO(Phase 9B): replace with real Supabase call`.
- No dead code, commented-out code, leftover scaffold widgets.
- No hardcoded strings — use `app_strings.dart`.
- No hardcoded `Color(0xFF…)` outside `theme/colors.dart`.
- No hardcoded `EdgeInsets`, `SizedBox`, `BorderRadius` literals — use `core/constants/*`.
- `const` on every widget that allows it.
- No `ignore_for_file:` or `// ignore:` directives.

**Mandatory pre-report sequence (paste verbatim into §10):**

```bash
dart fix --apply
dart format .
flutter analyze
flutter test  # Phase 10 onward only
```

---

## 3. Graphify Knowledge Graph Protocol

Graph artifacts live in `graphify-out/`. The `/graphify --watch` flag is recommended for the long backend phases (9A–9D).

### 3.1 Pre-implementation (MANDATORY every phase)

Before writing a single line:
1. Read `graphify-out/GRAPH_REPORT.md` end-to-end.
2. Run targeted queries: `/graphify query`, `/graphify path`, `/graphify explain` for every module in the phase's Touches scope.
3. Capture queries + findings in §9 of the report.
4. If the graph contradicts CLAUDE.md — pause and surface to the user.

### 3.2 Post-implementation (MANDATORY every phase)

After implementation, before the report:
1. Run `graphify update .`
2. Diff GRAPH_REPORT.md before/after.
3. Paste rebuild output + diff summary into §11.
4. Confirm `graphify-out/` is committed.

### 3.3 Cheat sheet

| Command | When |
|---|---|
| `graphify update .` | After every phase |
| `/graphify query "<text>"` | Before touching code |
| `/graphify path <A> <B>` | Trace dependency paths |
| `/graphify explain <node>` | Understand a node |
| `/graphify --watch` | Background sync during long phases (9A–9D) |
| `graphify hook install` | One-time git hook setup |

---

## 4. Migration & Manual Steps Protocol (BACKEND PHASES ONLY)

This section applies to Phases 9A, 9B, 9C, 9D. It does not apply to UI phases.

### 4.1 What a migration is

Any change to the Supabase database schema, storage buckets, RLS policies, Edge Functions, or Firebase config is a **migration**. Migrations must be:
- Written as SQL files in `supabase/migrations/` with timestamp-prefixed names.
- Documented as manual steps in `docs/migrations/PHASE_9X_MANUAL.md` if Supabase CLI cannot automate them.
- Applied to the database **before** the Flutter code that uses them is run.

### 4.2 Migration file naming

```
supabase/migrations/
  20260502_001_phase9a_initial_schema.sql
  20260502_002_phase9a_rls_policies.sql
  20260502_003_phase9b_block_requests.sql
  20260502_004_phase9b_unblock_requests.sql
  20260502_005_phase9c_device_qr_codes.sql
  20260502_006_phase9d_theft_zones_live.sql
  20260502_007_phase9d_notifications.sql
```

Format: `YYYYMMDD_NNN_phaseXX_description.sql`. Increment NNN per phase session.

### 4.3 Manual steps document format

Every backend phase produces `docs/migrations/PHASE_9X_MANUAL.md`:

```markdown
# Phase 9X — Manual Steps

## Steps Claude Code CANNOT automate
(things that require the Supabase dashboard or Firebase console)

### Step 1 — <title>
**Where:** Supabase Dashboard → Authentication → [exact menu path]
**What to do:** [exact instructions, including what to click and what to type]
**Why:** [one sentence]
**Verification:** [how to confirm it worked]

### Step 2 — ...

## Migration files to apply
Run in order from project root:
  supabase db push
  (or paste each .sql file into Supabase SQL Editor in order)

## Environment variables required
Add to your local .env file:
  VARIABLE_NAME=value  # description

## Verification checklist
□ [thing to verify in Supabase dashboard]
□ [thing to verify in Firebase console]
□ [thing to verify by running the app]
```

### 4.4 What requires a manual step vs what can be automated

| Action | Automated (SQL) | Manual (dashboard) |
|---|---|---|
| Create tables | ✅ | — |
| Add columns | ✅ | — |
| Create indexes | ✅ | — |
| RLS policies | ✅ | — |
| Create Storage bucket | ❌ | ✅ Dashboard: Storage → New bucket |
| Set bucket public/private | ❌ | ✅ Dashboard: bucket settings |
| Storage RLS policies | ✅ | — |
| Enable Email/Password auth | ❌ | ✅ Dashboard: Auth → Providers |
| Create demo user accounts | ❌ | ✅ Dashboard: Auth → Users → Add user |
| Deploy Edge Function | ❌ | ✅ `supabase functions deploy <name>` from terminal |
| Set Edge Function secrets | ❌ | ✅ `supabase secrets set KEY=value` from terminal |
| Firebase: add Android app | ❌ | ✅ Firebase Console |
| Firebase: enable FCM | ❌ | ✅ Firebase Console → Cloud Messaging |
| Firebase: download google-services.json | ❌ | ✅ Firebase Console → Project Settings |

### 4.5 Secrets rule

**Never commit secrets.** The following must be in `.env` (gitignored) or passed via `--dart-define`:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- FCM Server Key (Edge Function secret only — never in the Flutter app)
- Google Maps API key (in `AndroidManifest.xml` which is gitignored)

The `.env` file must be listed in `.gitignore`. Verify with `git status` before every commit.

### 4.6 Pre-flight checklist (complete before Phase 9A starts)

The user must confirm ALL of these before Claude Code writes Phase 9A code:

```
SUPABASE:
□ Supabase project created at supabase.com
□ Project URL noted (https://xxxx.supabase.co)
□ Anon/public key noted
□ Service role key noted (for Edge Functions ONLY — never in app)
□ Email/Password auth enabled: Auth → Providers → Email
□ Three demo users created: Auth → Users → Add user:
    demo.user@edrmp.pk   / Demo@1234  (role: user)
    demo.police@edrmp.pk / Demo@1234  (role: police)
    demo.pta@edrmp.pk    / Demo@1234  (role: pta)

FIREBASE:
□ Firebase project created at console.firebase.google.com
□ Android app added (package name matches app)
□ google-services.json downloaded → placed at android/app/google-services.json
□ Cloud Messaging enabled in Firebase Console
□ FCM Server Key noted (Project Settings → Cloud Messaging → Server key)

LOCAL ENVIRONMENT:
□ .env file created at project root with:
    SUPABASE_URL=https://xxxx.supabase.co
    SUPABASE_ANON_KEY=eyJh...
□ .env is in .gitignore (verify: git status shows .env as untracked/ignored)
□ AndroidManifest.xml is in .gitignore (done from Phase 7)
□ flutter pub get runs cleanly
□ flutter analyze → "No issues found!"
```

---

## 5. Project Snapshot

**Name:** eDRMP — Electronic Device Registration & Monitoring Portal
**Roles:** General User (citizen), Police Admin, PTA Admin
**Target:** Android-first MVP, demo-ready signed APK

**Full device lifecycle state machine:**
```
User registers device
  → PTA notified → Approves/Rejects → User notified

User files FIR (theft)
  → Police notified → Verifies/Rejects → User notified
    → if Verified: PTA notified → Blocks IMEI → User notified

User marks device Recovered
  → User files Unblock Request
    → Police notified → Approves unblock
      → PTA notified → Unblocks IMEI → User notified
```

**Push notification matrix:**

| Event | Notified party |
|---|---|
| User registers device | PTA admin |
| PTA approves/rejects device | Citizen |
| User files FIR | Police admin |
| Police verifies FIR | Citizen + PTA |
| Police rejects FIR | Citizen |
| PTA blocks device | Citizen |
| User files unblock request | Police admin |
| Police approves unblock | PTA admin |
| PTA unblocks device | Citizen |

**Out of scope (do not implement at any phase):** KYC/NADRA biometrics, in-app chat, super admin dashboard, PDF export, profile editing, multi-language, DIRBS API, biometric login. KYC was explicitly removed — do not bring it back.

---

## 6. Tech Stack (Locked)

| Layer | Choice | Phase added |
|---|---|---|
| Framework | Flutter 3.x (stable) | 0 |
| Language | Dart (sound null safety) | 0 |
| State | Riverpod (`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`) | 0 |
| Routing | `go_router` | 0 |
| Forms | `reactive_forms` or `Form` + `TextFormField` | 0 |
| Secure storage | `flutter_secure_storage` | 0 |
| Local cache | `hive` / `hive_flutter` | 0 |
| Backend | Supabase (`supabase_flutter`) | 9A |
| Push notifications | Firebase Cloud Messaging (`firebase_messaging`) | 9A |
| Maps | `google_maps_flutter` | 7 |
| Images | `cached_network_image` | 0 |
| Skeleton loading | `shimmer` | 8 |
| Codegen | `build_runner` + `freezed` + `json_serializable` + `riverpod_generator` | 0 |
| Lint | `flutter_lints` + strict overrides | 0 |
| Knowledge graph | Graphify | 0 |
| QR generation | `qr_flutter` | 9C |
| QR / barcode scan | `mobile_scanner` | 9C |
| Connectivity | `connectivity_plus` | 9D |

**No new dependency without listing it in §5 of the report and getting auditor approval.**

---

## 7. Document Hierarchy (Source of Truth)

1. **`CLAUDE.md`** — this file. Overrides everything.
2. **`design/handoff/README.md`** — coding-agent instructions.
3. **`design/handoff/chats/chat1.md`** — design intent.
4. **`design/handoff/project/eDRMP Design System.html`** + relevant `screens-*.jsx`.
5. **`graphify-out/GRAPH_REPORT.md`** — structural ground truth.
6. **`docs/Architecture.md`** — patterns and layers.
7. **`docs/PRD.md`** — UX intent.
8. **`docs/MVP Tech Doc.md`** — backend plan.
9. **`docs/System Design.md`** — sequence diagrams, schemas.
10. **`docs/Software_Requirement_and_Design_Specification_SRDS.pdf`** — academic SRDS (KYC sections are out of scope).

**`docs/implementation_phases.md` is REJECTED.** Use Section 8 of this file.

### 7.1 Design handoff — local files only (no WebFetch)

```
design/handoff/
├── README.md
├── chats/chat1.md
└── project/
    ├── eDRMP Design System.html
    ├── tokens.js
    ├── colors.dart          ← 94 tokens — lib/theme/colors.dart must mirror exactly
    ├── components.jsx
    ├── screens-citizen.jsx
    ├── screens-officer.jsx
    └── screens-admin.jsx
```

### 7.2 Screen → Phase → JSX mapping

| Phase | JSX file | Functions |
|---|---|---|
| 1 | — | Splash, Login, Register, Forgot Password ✅ |
| 1.5 | `screens-citizen.jsx` | `ScreenOnboarding` ✅ |
| 2–8 | Various | All citizen/police/PTA screens ✅ |
| 9A–9D | No new screens | Backend wiring only |
| 9C | New feature | `verify_imei_page.dart` (new, no JSX source) |

### 7.3 Color token rule

`lib/theme/colors.dart` must mirror `design/handoff/project/colors.dart` exactly. No new constants may be added to `lib/theme/colors.dart` unless the same constant exists in the handoff file first.

---

## 8. Phase Plan

| # | Phase | Status | Headline |
|---|---|---|---|
| 0 | Scorched Earth + Foundation | ✅ Done | Theme, widgets, routing, lint |
| 1 | Auth Suite | ✅ Done | Login, register, forgot password |
| 1.5 | Onboarding | ✅ Done | ScreenOnboarding + colors sync |
| 2 | Citizen Shell | ✅ Done | Dashboard hero, bottom nav, profile, settings |
| 3 | Devices Module | ✅ Done | My Devices, Add Device, Device Details |
| 4 | FIR + Case Tracking | ✅ Done | Submit FIR, FIR History, Case Timeline |
| 5 | Police Module | ✅ Done | Police dashboard, FIR queue, review |
| 6 | PTA Module | ✅ Done | Analytics, approvals, block requests |
| 7 | Theft Map | ✅ Done | Google Maps with mock zones |
| 8 | Polish | ✅ Done | Shimmer, transitions, pull-to-refresh, animations |
| **9A** | **Supabase Core** | 🔜 Next | Auth, schema, RLS, basic CRUD, FCM token |
| **9B** | **Lifecycle + FIR Workflow** | 🔜 | Full state machine, block/unblock, case log |
| **9C** | **QR + IMEI Verification** | 🔜 | QR generation, scan + keyboard verify screen |
| **9D** | **Live Map + Push Notifications** | 🔜 | Location picker, live FIR map, FCM push |
| **10** | **QA + Release** | 🔜 | Tests, signed APK, README |

---

### Phase 9A — Supabase Core Foundation

**Goal:** Replace mock auth and set up the full database schema with RLS. No workflow logic yet — only CRUD and auth.

**Touches:**
- `supabase/migrations/` (new migration files)
- `docs/migrations/PHASE_9A_MANUAL.md` (new manual steps doc)
- `lib/core/services/supabase_service.dart` (new)
- `lib/features/auth/data/auth_repository.dart` (replace mock)
- `lib/main.dart` (Supabase + Firebase init)
- `pubspec.yaml` (`supabase_flutter`, `firebase_core`, `firebase_messaging`)
- `android/app/google-services.json` (gitignored — manual step)

**Migration files to create:**

```sql
-- supabase/migrations/20260502_001_phase9a_initial_schema.sql
-- Tables: profiles, devices, firs, block_requests, unblock_requests,
--         case_status_log, theft_zones, notifications, device_qr_codes

-- supabase/migrations/20260502_002_phase9a_rls_policies.sql
-- RLS: row-level security for every table above
```

**Manual steps (must go in `docs/migrations/PHASE_9A_MANUAL.md`):**
1. Enable Email/Password auth in Supabase Dashboard → Auth → Providers.
2. Create three demo users in Auth → Users → Add user.
3. After running the schema migration, manually set `role` in `profiles` for each demo user (the trigger should do this automatically — verify it did).
4. Place `google-services.json` at `android/app/google-services.json` (gitignored).

**Deliverables:**
1. `supabase/migrations/` — two SQL files: schema + RLS. Both are idempotent (`CREATE TABLE IF NOT EXISTS`, `CREATE POLICY IF NOT EXISTS`).
2. `docs/migrations/PHASE_9A_MANUAL.md` — complete manual steps document per Section 4.3 format.
3. `lib/core/services/supabase_service.dart` — `SupabaseService.init()` called from `main.dart`. Reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `--dart-define`.
4. Real `AuthRepository` — same public interface as the mock:
   - `login(email, password)` → Supabase `signInWithPassword`
   - `register(...)` → Supabase `signUp` + insert into `profiles`
   - `forgotPassword(email)` → Supabase `resetPasswordForEmail`
   - `logout()` → Supabase `signOut`
   - `currentUser` → reads from `profiles` table including `role` and `fcm_token`
   - Session restore on cold start via `supabase.auth.currentSession`
5. FCM token saved to `profiles.fcm_token` on every login.
6. `main.dart` — Firebase initialised before `SupabaseService.init()`. `ProviderScope` wraps both.
7. Auth gate in `app_router.dart` reads from the real `currentUserProvider`. No mock.
8. All `// TODO(Phase 9):` markers in auth files removed.

**Schema (include in migration SQL):**

```sql
-- profiles
id uuid references auth.users primary key,
full_name text not null,
cnic text unique not null,
email text unique not null,
phone text,
role text not null check (role in ('user','police','pta')),
fcm_token text,
created_at timestamptz default now()

-- devices
id uuid primary key default gen_random_uuid(),
owner_id uuid references profiles(id) not null,
imei1 text unique not null,
imei2 text,
brand text,
model text,
operator text,
status text default 'pending'
  check (status in ('pending','approved','rejected','blocked','unblocked')),
purchase_invoice_url text,
registered_at timestamptz default now(),
updated_at timestamptz default now()

-- firs
id uuid primary key default gen_random_uuid(),
owner_id uuid references profiles(id) not null,
device_id uuid references devices(id) not null,
fir_number text not null,
police_station text not null,
incident_date date not null,
description text,
proof_url text,
incident_lat double precision,
incident_lng double precision,
incident_address text,
status text default 'pending_review'
  check (status in (
    'pending_review','under_review','verified',
    'rejected','block_pending','block_approved',
    'block_rejected','blocked','recovered',
    'unblock_pending','unblock_approved','unblocked'
  )),
rejection_reason text,
created_at timestamptz default now(),
updated_at timestamptz default now()

-- block_requests
id uuid primary key default gen_random_uuid(),
fir_id uuid references firs(id) not null,
device_id uuid references devices(id) not null,
requested_by uuid references profiles(id) not null,
status text default 'pending' check (status in ('pending','approved','rejected')),
rejection_reason text,
created_at timestamptz default now()

-- unblock_requests
id uuid primary key default gen_random_uuid(),
fir_id uuid references firs(id) not null,
device_id uuid references devices(id) not null,
requested_by uuid references profiles(id) not null,
police_approved_at timestamptz,
police_approved_by uuid references profiles(id),
status text default 'pending_police'
  check (status in ('pending_police','police_approved','pta_unblocked','rejected')),
rejection_reason text,
created_at timestamptz default now()

-- case_status_log
id uuid primary key default gen_random_uuid(),
entity_type text not null check (entity_type in ('device','fir','block','unblock')),
entity_id uuid not null,
old_status text,
new_status text not null,
changed_by uuid references profiles(id),
note text,
created_at timestamptz default now()

-- notifications
id uuid primary key default gen_random_uuid(),
recipient_id uuid references profiles(id) not null,
title text not null,
body text not null,
type text not null,
entity_id uuid,
is_read boolean default false,
created_at timestamptz default now()

-- theft_zones (populated from FIR locations)
id uuid primary key default gen_random_uuid(),
fir_id uuid references firs(id),
lat double precision not null,
lng double precision not null,
address text,
risk_level text default 'medium'
  check (risk_level in ('low','medium','high')),
fir_count integer default 1,
created_at timestamptz default now()

-- device_qr_codes
id uuid primary key default gen_random_uuid(),
device_id uuid references devices(id) unique not null,
qr_storage_path text not null,
created_at timestamptz default now()
```

**RLS rules (include in migration SQL):**
- `profiles`: users read own row; PTA/police can read all.
- `devices`: users read own; PTA reads all; police reads all.
- `firs`: users read own; police reads all; PTA reads all.
- `block_requests`: users read own; PTA reads all.
- `unblock_requests`: users read own; police reads all; PTA reads all.
- `case_status_log`: users read rows where `entity_id` matches their device/FIR; admins read all.
- `notifications`: users read own rows only.
- `theft_zones`: all authenticated users read; only service role inserts.
- `device_qr_codes`: device owner reads own; all authenticated users read (needed for verify screen).

**Acceptance criteria:**
- `flutter analyze` → `No issues found!`
- Migration SQL files are idempotent (run twice without error).
- `PHASE_9A_MANUAL.md` has a manual step for every non-automatable action.
- All three demo accounts log in successfully on the real backend.
- Auth gate routes each role to the correct shell.
- No `// TODO(Phase 9A):` markers remain.
- No secrets committed (`git status` confirms `.env` and `google-services.json` are untracked).

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0–8 are approved. Starting Phase 9A — Supabase Core Foundation.

PRE-FLIGHT: Confirm the user has completed the Section 4.6 checklist before
writing any code. If SUPABASE_URL or SUPABASE_ANON_KEY are not available as
--dart-define values, STOP and ask the user to provide them.

GRAPHIFY PRE-IMPLEMENTATION:
Read graphify-out/GRAPH_REPORT.md.
Run /graphify query "AuthRepository", /graphify query "mock",
/graphify query "supabase", /graphify explain AuthController.
Capture in §9.
Start /graphify --watch in background for this long phase.

MIGRATION FIRST (before any Flutter code):
1. Create supabase/migrations/ directory.
2. Write 20260502_001_phase9a_initial_schema.sql — full schema per
   CLAUDE.md §8 Phase 9A Schema section.
3. Write 20260502_002_phase9a_rls_policies.sql — RLS per CLAUDE.md.
4. Write docs/migrations/PHASE_9A_MANUAL.md — all manual steps per
   Section 4.3 format. Include step-by-step dashboard instructions.

THEN implement Flutter code per Phase 9A Deliverables in CLAUDE.md.

GATES: dart fix --apply, dart format ., flutter analyze → "No issues found!".
GRAPHIFY: graphify update ., diff, paste into §11.

REPORT: docs/reports/PHASE_9A_REPORT.md per Section 10.
Add §16 — Migration files created (list SQL files).
Add §17 — Manual steps document (confirm PHASE_9A_MANUAL.md written).
Stop.
```

---

### Phase 9B — Full Device Lifecycle + FIR Workflow

**Goal:** Wire the complete state machine. Every status transition writes to `case_status_log`. Block and unblock flows fully implemented.

**Touches:**
- `supabase/migrations/` (new migration files for triggers)
- `docs/migrations/PHASE_9B_MANUAL.md`
- `lib/features/devices/data/device_repository.dart`
- `lib/features/fir/data/fir_repository.dart`
- `lib/features/fir/logic/fir_provider.dart`
- `lib/features/police/` — data layer
- `lib/features/pta/` — data layer
- `lib/core/errors/` (new — `AppFailure` sealed class)
- `lib/core/network/` (new — connectivity middleware)

**Migration files to create:**

```sql
-- 20260502_003_phase9b_status_update_trigger.sql
-- DB trigger: after UPDATE on devices/firs/block_requests/unblock_requests
-- → auto-insert into case_status_log

-- 20260502_004_phase9b_storage_buckets_rls.sql
-- Storage RLS for fir-documents and device-qr-codes buckets
```

**Manual steps (in `docs/migrations/PHASE_9B_MANUAL.md`):**
1. Create Storage bucket `fir-documents` — Dashboard → Storage → New bucket → private.
2. Create Storage bucket `device-qr-codes` — Dashboard → Storage → New bucket → public.
3. Apply the RLS SQL for storage buckets after creating them.

**Deliverables:**
1. Two migration SQL files (trigger + storage RLS).
2. `docs/migrations/PHASE_9B_MANUAL.md`.
3. Real `DeviceRepository.updateStatus(deviceId, status)` — PTA approves/rejects.
4. Real `FirRepository` — submit (with proof file upload to `fir-documents` bucket, 3 retries exponential backoff), fetch by owner, fetch all (police/PTA), updateStatus (police verifies/rejects, PTA blocks).
5. Real `BlockRequestRepository` — create (after FIR verified), PTA approve/reject.
6. Real `UnblockRequestRepository` — create (user marks recovered), police approve, PTA unblock.
7. `CaseStatusRepository` — reads `case_status_log` for a given entity. Realtime subscription on the citizen's own rows.
8. `lib/core/errors/app_failure.dart` — sealed class: `NetworkFailure`, `AuthFailure`, `NotFoundFailure`, `ServerFailure`, `StorageFailure`. Every repository method returns `Either<AppFailure, T>` or throws typed exceptions.
9. `lib/core/network/connectivity_middleware.dart` — wraps repository calls. Surfaces `NetworkFailure` when offline.
10. All `// TODO(Phase 9B):` markers removed.
11. Every async UI action has loading + error states (already in UI — just ensure they handle `AppFailure`).

**Acceptance criteria:**
- Full flow on real backend: register device → PTA approves → submit FIR → police verifies → PTA blocks → user marks recovered → police approves unblock → PTA unblocks.
- `case_status_log` has one entry per transition.
- RLS verified: citizen cannot read another user's FIRs (test with two accounts).
- File upload to `fir-documents` with retry works.
- `flutter analyze` clean.
- Migration SQL is idempotent.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phase 9A is approved. Starting Phase 9B — Full Device
Lifecycle + FIR Workflow.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "DeviceRepository", /graphify query "FirRepository",
/graphify query "case_status_log", /graphify query "mock".
Verify all Mock* repositories are still present and list them.
Capture in §9.

MIGRATION FIRST:
1. Write 20260502_003_phase9b_status_update_trigger.sql
   (DB trigger: status changes → auto-insert case_status_log).
2. Write 20260502_004_phase9b_storage_buckets_rls.sql
   (Storage RLS for fir-documents and device-qr-codes buckets).
3. Write docs/migrations/PHASE_9B_MANUAL.md with manual steps for:
   - Creating fir-documents bucket (private)
   - Creating device-qr-codes bucket (public)

THEN implement Flutter code per Phase 9B Deliverables in CLAUDE.md.
Remove every // TODO(Phase 9B): marker.

GATES: dart fix --apply, dart format ., flutter analyze → "No issues found!".
GRAPHIFY: graphify update ., diff (confirm Mock* nodes gone), paste §11.

REPORT: docs/reports/PHASE_9B_REPORT.md per Section 10.
Add §16 — Migration files created.
Add §17 — Manual steps document confirmed.
Stop.
```

---

### Phase 9C — QR Code + IMEI Verification Module

**Goal:** Generate QR codes for approved devices. Build the Verify IMEI screen with scan + keyboard modes.

**Touches:**
- `supabase/migrations/` (QR storage path migration)
- `docs/migrations/PHASE_9C_MANUAL.md`
- `lib/features/verification/` (new feature folder)
- `lib/features/devices/presentation/device_details_page.dart` (add QR display)
- `lib/core/routes/` (new routes)
- `pubspec.yaml` (`qr_flutter`, `mobile_scanner`)

**Migration files to create:**

```sql
-- 20260502_005_phase9c_device_qr_codes.sql
-- Populate device_qr_codes for all approved devices
-- (or handle via trigger on device status → approved)
```

**Manual steps (in `docs/migrations/PHASE_9C_MANUAL.md`):**
1. Enable camera permission in `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   ```
   This file is gitignored — instruct the user to add it manually.
2. Verify `device-qr-codes` bucket is public (from Phase 9B).

**Deliverables:**
1. Migration SQL + `docs/migrations/PHASE_9C_MANUAL.md`.
2. **`lib/features/verification/`** new feature:
   - `data/verification_repository.dart` — `checkImei(imei)` → queries `devices` table, returns `VerificationResult` (model, owner masked CNIC, status, registration date, or "not found").
   - `logic/verification_provider.dart` — Riverpod `AsyncNotifier`.
   - `presentation/verify_imei_page.dart` — two tabs:
     - **Scan QR tab:** `mobile_scanner` camera view. On scan → extract IMEI from QR payload → auto-trigger lookup → show result card. Torch toggle button.
     - **Enter IMEI tab:** text field with Luhn validation. "Verify" button → lookup → result card.
   - Result card: device model, masked owner CNIC (`xxxxx-xxxxxxx-x`), status badge, registration date. If not found: "IMEI not registered" with call-to-action to register.
3. **QR code generation** — when a device's status changes to `approved` (via the Phase 9B trigger or a separate function):
   - Generate a QR code encoding `{"imei": "<imei1>", "deviceId": "<id>"}` using `qr_flutter`.
   - Upload the QR image to Supabase Storage `device-qr-codes` bucket.
   - Insert path into `device_qr_codes` table.
4. **Device Details page** — add a "Your device QR code" card below the timeline. Shows the QR image from storage. Tap → fullscreen bottom sheet. "Share" icon copies the QR image.
5. **Routing:** `RouteNames.verifyImei` wired. Accessible from:
   - Citizen Quick Actions "Verify IMEI" tile (replaces the "coming soon" toast).
   - Police dashboard AppBar action.
   - PTA dashboard AppBar action.

**Acceptance criteria:**
- Scan a QR code of a registered device → result shows correct model + status.
- Enter a valid registered IMEI → result correct.
- Enter an unregistered IMEI → "not found" result.
- Enter a blocked device IMEI → "blocked" status shown in red.
- QR code visible on Device Details for approved devices.
- Camera permission requested gracefully on first scan.
- `flutter analyze` clean.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phase 9B is approved. Starting Phase 9C — QR Code +
IMEI Verification Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "DeviceRepository", /graphify query "IMEI",
/graphify query "device_details", /graphify query "verify IMEI".
Capture in §9.

MIGRATION FIRST:
1. Write 20260502_005_phase9c_device_qr_codes.sql.
2. Write docs/migrations/PHASE_9C_MANUAL.md.
   Include the camera permission AndroidManifest.xml instruction
   as a manual step with the exact XML to add.

NEW DEPENDENCIES to add to pubspec.yaml:
  qr_flutter: ^4.x.x
  mobile_scanner: ^5.x.x
Declare both in §5 of the report.

THEN implement Flutter code per Phase 9C Deliverables in CLAUDE.md.

GATES: dart fix --apply, dart format ., flutter analyze → "No issues found!".
GRAPHIFY: graphify update ., diff, paste §11.

REPORT: docs/reports/PHASE_9C_REPORT.md per Section 10.
Add §16 — Migration files created.
Add §17 — Manual steps document (including AndroidManifest camera permission instruction).
Stop.
```

---

### Phase 9D — Live Map + Push Notifications

**Goal:** Location picker in FIR form. Live theft map from real FIR data. FCM push at every state transition. Real in-app notification inbox. Sentry error tracking.

**Touches:**
- `supabase/migrations/` (Edge Function scaffolding, theft_zones population trigger)
- `docs/migrations/PHASE_9D_MANUAL.md`
- `supabase/functions/` (new — Edge Functions for FCM push)
- `lib/features/fir/presentation/submit_fir_page.dart` (location picker)
- `lib/features/map/` (live data)
- `lib/features/notifications/` (real inbox)
- `lib/core/logic/connectivity_notifier.dart` (replace mock)
- `pubspec.yaml` (`connectivity_plus`, `sentry_flutter`)

**Migration files to create:**

```sql
-- 20260502_006_phase9d_theft_zones_trigger.sql
-- Trigger: after INSERT on firs → insert into theft_zones using incident_lat/lng

-- 20260502_007_phase9d_notifications_realtime.sql
-- Enable Realtime on notifications table
-- Enable Realtime on firs table (for live map subscription)
```

**Edge Functions to create (in `supabase/functions/`):**

```
supabase/functions/
  notify-device-approved/index.ts
  notify-device-rejected/index.ts
  notify-fir-received-police/index.ts
  notify-fir-verified/index.ts
  notify-fir-rejected/index.ts
  notify-device-blocked/index.ts
  notify-unblock-received-police/index.ts
  notify-unblock-received-pta/index.ts
  notify-device-unblocked/index.ts
```

Each Edge Function:
1. Reads trigger payload (entity_id, old_status, new_status).
2. Looks up recipient's `fcm_token` from `profiles`.
3. Calls FCM HTTP v1 API with `Authorization: Bearer <FCM_SERVER_KEY>`.
4. Inserts a row into `notifications` table.

**Manual steps (in `docs/migrations/PHASE_9D_MANUAL.md`):**
1. Deploy each Edge Function: `supabase functions deploy <name>` (one command per function — list all 9).
2. Set Edge Function secret: `supabase secrets set FCM_SERVER_KEY=<your_server_key>`.
3. Enable Realtime in Supabase Dashboard → Database → Replication — add `notifications` and `firs` tables to the replication set.
4. Link each DB trigger to the corresponding Edge Function (Supabase Dashboard → Database → Triggers, or via SQL in the migration).

**Deliverables:**
1. Two migration SQL files + `docs/migrations/PHASE_9D_MANUAL.md`.
2. Nine Edge Function files in `supabase/functions/`.
3. **Location picker in Submit FIR form:**
   - Tapping the Location field opens a full-screen `GoogleMap`.
   - Draggable red pin centred on Pakistan (default: Karachi `24.8607, 67.0011`).
   - "Confirm location" button at the bottom captures `lat`, `lng`, and reverse-geocoded address string (use Google Geocoding API via a simple `http.get` call, or omit geocoding and just store coordinates — document the decision in §6).
   - Confirmed location stores in `FirModel.incidentLat`, `incidentLng`, `incidentAddress`.
4. **Live theft map** — `TheftZoneRepository` now queries `theft_zones` table. Realtime subscription updates pins without manual refresh. Pin colours: `pending_review/under_review` = amber, `blocked` = red, `recovered/unblocked` = green.
5. **Real notifications inbox** — `notifications_page.dart` queries `notifications` table filtered by `recipient_id = currentUser.id`. Realtime subscription. Unread rows shown with a blue dot. Tapping marks as read (`is_read = true`). Bell icon badge shows unread count.
6. **ConnectivityNotifier** — replace mock with `connectivity_plus` package. `isOnline` reflects real network state. The banner in `AppShellPage` responds to real connectivity changes.
7. **Sentry** — initialise in `main.dart` with DSN from `--dart-define`. Wrap `runApp` in `SentryFlutter.init`.
8. All `// TODO(Phase 9D):` markers removed. No mock data remains anywhere.

**Acceptance criteria:**
- Submit FIR with location pin → location stored in Supabase.
- Theft map shows real FIR pins (test by submitting a FIR with a location).
- After PTA approves a device, citizen receives a push notification within 30 seconds.
- After police verifies a FIR, citizen and PTA both receive push notifications.
- After PTA blocks a device, citizen receives a push notification.
- Notifications inbox shows all received notifications. Unread count badge works.
- Toggling airplane mode → connectivity banner appears.
- `flutter analyze` clean. No `// MOCK` or `// TODO(Phase 9)` markers remain anywhere.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phase 9C is approved. Starting Phase 9D — Live Map +
Push Notifications.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "notifications", /graphify query "theft_zones",
/graphify query "ConnectivityNotifier", /graphify query "FirRepository",
/graphify path FirRepository TheftMapPage.
Capture in §9.
Run /graphify --watch in background.

MIGRATION FIRST:
1. Write 20260502_006_phase9d_theft_zones_trigger.sql.
2. Write 20260502_007_phase9d_notifications_realtime.sql.
3. Create all 9 Edge Functions in supabase/functions/.
4. Write docs/migrations/PHASE_9D_MANUAL.md with:
   - Deploy command for each Edge Function (list all 9 individually).
   - supabase secrets set command for FCM_SERVER_KEY.
   - Realtime replication setup steps (exact dashboard path).
   - How to link DB triggers to Edge Functions.

NEW DEPENDENCIES:
  connectivity_plus: ^6.x.x
  sentry_flutter: ^8.x.x
Declare in §5.

THEN implement Flutter code per Phase 9D Deliverables in CLAUDE.md.
Remove every // MOCK comment and every // TODO(Phase 9*) marker.
Run a final grep to confirm zero remain:
  grep -rn "// MOCK\|// TODO(Phase 9" lib/ --include="*.dart"
This must return zero lines. Paste the output in §6.

GATES: dart fix --apply, dart format ., flutter analyze → "No issues found!".
GRAPHIFY: graphify update ., diff, confirm no mock communities remain, paste §11.

REPORT: docs/reports/PHASE_9D_REPORT.md per Section 10.
Add §16 — Migration files created + Edge Functions deployed.
Add §17 — Manual steps document (all 4 categories of manual steps).
Add §18 — Zero-mock verification (grep output showing no // MOCK lines).
Stop.
```

---

### Phase 10 — QA, Lint Sweep, Release

**Touches:** test files, lint config, build config, `README.md`.

**Deliverables:**
- Unit tests: all use cases / validators (≥ 70% coverage).
- Widget tests: login, register, device add, FIR submit, case timeline, police review, PTA approval, verify IMEI.
- Integration test: full happy path against Supabase test project.
- Whole-tree lint sweep.
- App icon + splash finalised.
- Signed release APK; keystore in CI secrets, documented.
- `README.md` with setup, env vars, demo credentials, build command, screenshots, all migration files listed, "Knowledge graph" section pointing to `graphify-out/GRAPH_REPORT.md`.
- Demo seed-data script (inserts test devices, FIRs, and case log entries).

**Acceptance criteria:** CI green; zero crash-blocking bugs; tested on Android 8 + 14; all migration files applied cleanly on a fresh Supabase project; Graphify graph current and committed.

**Prompt:**

```
Read CLAUDE.md. Phases 9A–9D approved. Starting Phase 10 — QA, Lint Sweep, Release.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note all god nodes — referenced from README.md.
Run /graphify query "test", /graphify explain AuthRepository.
Capture in §9.

IMPLEMENTATION:
Hit coverage targets. Build signed release APK. Update README.md.
Include all migration files in README under "Database Setup".

Final zero-mock check:
  grep -rn "// MOCK\|MockDevice\|MockFir" lib/ --include="*.dart"
Must return zero lines.

GRAPHIFY: final graphify update ., diff, paste §11.
GATES: dart fix --apply, dart format ., flutter analyze, flutter test.
All must pass.
REPORT: docs/reports/PHASE_10_REPORT.md, stop.
```

---

## 9. What Claude Code MUST Refuse

Without explicit out-of-band instruction, refuse and point back here:

- Working on a phase not yet authorised.
- Touching files outside the current phase's *Touches* scope.
- Skipping Graphify pre-implementation read/queries (Section 3.1).
- Skipping Graphify post-implementation rebuild (Section 3.2).
- **Starting any 9A–9D Flutter code before writing migration files and the manual steps document.**
- **Committing `supabase/functions/` without the corresponding manual deploy instructions in the MANUAL.md.**
- Skipping the design read order (Section 7.2) on any UI phase.
- Calling `WebFetch` on the design URL (handoff is local).
- Implementing `ScreenKYC` or any KYC/NADRA flow.
- Adding a dependency not in Section 6.
- Making real backend calls before Phase 9A.
- Hardcoded colors, paddings, durations, or strings outside constants/theme files.
- Adding a color constant to `lib/theme/colors.dart` not present in the handoff.
- `// ignore:` or `ignore_for_file:` directives.
- Skipping `dart fix --apply` / `dart format .` / `flutter analyze` before declaring done.
- Skipping the Implementation Report.
- **Committing `.env`, `google-services.json`, API keys, or any secrets.**
- Declaring a phase complete when `flutter analyze` shows anything other than `No issues found!`.
- Declaring a phase complete when `graphify-out/` is stale or uncommitted.
- Declaring a 9A–9D phase complete without §16 (migration files) and §17 (manual steps doc) in the report.

---

## 10. Implementation Report Format

```markdown
# Phase NN — <Phase Name> — Implementation Report

## 1. Status
- [x] Complete  /  [ ] Partial  /  [ ] Blocked
- Date completed:
- Branch / commit:

## 2. Files created
## 3. Files modified
## 4. Files deleted (or fully overwritten from stub)
## 5. New dependencies
## 6. Deviations from CLAUDE.md
## 7. Mock data introduced (or "None — all mock data removed this phase")
## 8. Design fidelity check
- Screen → matches JSX? (yes / partial / N/A for backend phases)
- Light + dark verified? (yes / no / N/A)

## 9. Graphify pre-implementation queries
(If zero queries → phase status is Blocked.)

## 10. Lint / format / analyze output (paste verbatim)
    $ dart fix --apply
    $ dart format .
    $ flutter analyze
    No issues found! (ran in X.Xs)

## 11. Graphify post-implementation update
    $ graphify update .
    <output>
- New nodes added:
- New community formed:
- God nodes changed?
- Mock* nodes removed? (backend phases)
- Cross-feature edge leaks?

## 12. Manual test log
(flutter run not executed → code-walk only, OR emulator results)

## 13. Known issues / debt
## 14. What I touched outside Touches scope (should be empty)

## 15. Ready for auditor?
- [ ] Yes — please review.

--- BACKEND PHASES ONLY (9A, 9B, 9C, 9D) ---

## 16. Migration files created
- supabase/migrations/YYYYMMDD_NNN_description.sql — purpose
(If missing → phase status is Blocked.)

## 17. Manual steps document
- docs/migrations/PHASE_9X_MANUAL.md — confirmed written
- Number of manual steps documented: N
- Step titles: [list them]
(If missing → phase status is Blocked.)

## 18. Zero-mock verification (Phase 9D and 10 only)
    $ grep -rn "// MOCK\|MockDevice\|MockFir" lib/ --include="*.dart"
    (must return zero lines)
```

---

## 11. Audit Loop

```
USER ↦ Claude Code:  "Begin Phase N." (copy Prompt from Section 8)
Claude Code:         §3.1 queries → migration files + MANUAL.md
                     → Flutter code → §3.2 rebuild
                     → writes PHASE_NN_REPORT.md → stops.
USER ↦ Auditor:      pastes report + any concerning code.
Auditor:             ✅ Approve  OR  ✏️ Change list.
  Approve  →  USER ↦ Claude Code: "Begin Phase N+1."
  Changes  →  USER ↦ Claude Code: "Apply changes. Update report. Stop."
Repeat.
```

**Auditor additionally rejects 9A–9D phases on:** missing migration SQL files, missing MANUAL.md, secrets committed, schema deviates from CLAUDE.md spec, mock repositories not removed when expected, `grep -rn "// MOCK"` returns lines when it shouldn't, Edge Functions not scaffolded, §16 or §17 missing from report.

---

## 12. Quick Reference Card

- **Phases 0–8 done.** Next: Phase 9A.
- **Before 9A:** user must complete Section 4.6 pre-flight checklist.
- **Migration-first rule:** for 9A–9D, write SQL + MANUAL.md *before* any Flutter code.
- **Section 4.3 format:** every MANUAL.md follows the exact template.
- **No secrets committed.** `.env`, `google-services.json`, FCM keys — all gitignored.
- **Section 3 every phase:** read GRAPH_REPORT.md → query → code → rebuild.
- **Section 6 color rule:** `theme/colors.dart` mirrors handoff `colors.dart` exactly.
- **`core/widgets/` for anything reused on more than one screen.**
- **`flutter analyze` must say `No issues found!` before claiming done.**
- **`graphify-out/` must be current and committed before claiming done.**
- **§16 + §17 required in every 9A–9D report.**
- **KYC is OUT. Forever.**

---

*End of CLAUDE.md*

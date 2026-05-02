# CLAUDE.md — eDRMP Implementation Playbook

> **Read this entire file before writing a single line of code.**
> This file is the **only** source of truth for the build order and rules.
> The phase ordering in `docs/implementation_phases.md` is **rejected and superseded** by Section 8 of this file. If anything in the user's prompts conflicts with this file, ask — do not improvise.

---

## 0. How This Playbook Works

1. The project is delivered in **11 phases (Phase 0 through Phase 10)**. One phase at a time. Period.
2. Claude Code may **not** start phase N+1 until the user explicitly says *"Begin Phase N+1."*
3. Every phase has a **Graphify pre-implementation read + post-implementation rebuild**, defined in Section 3. Skipping either step is a phase failure.
4. After every phase, Claude Code writes an **Implementation Report** (template in Section 10) to `docs/reports/PHASE_NN_REPORT.md` and **stops**. No "while I'm here let me also fix X."
5. Reports go to a separate auditor (the planning Claude). The auditor returns either:
   - ✅ **Approve** → user authorises the next phase.
   - ✏️ **Change requests** → Claude Code applies them as a fix-up on the *same phase*, regenerates the report, stops.
6. **Designs are authoritative**, not the existing code. See Section 1 below.

---

## 1. Replacement Mandate (READ TWICE)

The current `lib/features/**` tree contains placeholder / non-design-faithful screens. **Treat them as if they don't exist.** Every feature screen must be **rebuilt from scratch** to match the Claude Design handoff.

**Per-phase rule for any file inside that phase's scope:**
- If the file exists with placeholder content → **overwrite it completely**. Don't preserve the old layout, don't keep the old widgets, don't leave commented-out code.
- If the file exists with a useful name but wrong content → keep the filename, replace the body 100%.
- If a file isn't needed → delete it (and report the deletion).

Folder structure is **preserved as-is** (`lib/theme/`, `lib/core/`, `lib/features/<feature>/data|logic|presentation/`). Only file *contents* are scorched.

The Claude Design handoff URL (Section 7) is the visual contract. If a screen Claude Code produces doesn't visually match what's in that handoff, it is wrong and must be redone.

---

## 2. Zero-Lint Policy (NON-NEGOTIABLE)

Every phase ends with **`flutter analyze` printing exactly `No issues found!`**. Anything else — info, warning, hint, error — is a phase failure.

**Hard rules:**
- No unused imports. No unused variables. No unused parameters. No unused private fields.
- No `print()`. Use `debugPrint` only when truly necessary, and only inside `kDebugMode` guards.
- No `// TODO:` comments referencing the **current** phase. TODOs for future phases are allowed only if they reference the future phase number explicitly: `// TODO(Phase 9): swap mock for Supabase call`.
- No dead code, no commented-out code, no leftover scaffold widgets.
- No hardcoded strings in UI — everything routes through `app_strings.dart`.
- No hardcoded `Color(0xFF…)` outside `theme/colors.dart`.
- No hardcoded `EdgeInsets`, `SizedBox`, or `BorderRadius` literals — use `core/constants/*`.
- `const` on every widget that allows it.
- No `ignore_for_file:` directives. No `// ignore:` lines. If a lint fires, fix the cause.

**`analysis_options.yaml` (Claude Code created / verified in Phase 0):**

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    unused_import: error
    unused_local_variable: error
    unused_field: error
    unused_element: error
    dead_code: error
    avoid_print: error
    prefer_const_constructors: error
    prefer_const_literals_to_create_immutables: error
    prefer_const_declarations: error

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_key_in_widget_constructors
    - require_trailing_commas
    - sort_child_properties_last
    - use_super_parameters
    - unnecessary_lambdas
    - unnecessary_late
    - unnecessary_parenthesis
    - unnecessary_string_interpolations
    - avoid_redundant_argument_values
```

**Mandatory pre-report sequence** (Claude Code runs all of these and pastes the unedited output into Section 10 of the report):

```bash
dart fix --apply
dart format .
flutter analyze
flutter test  # only from Phase 10 onward
```

If any of those produces output that isn't clean, the phase is **not done** and the report status is `Partial` or `Blocked` — never `Complete`.

---

## 3. Graphify Knowledge Graph Protocol

This project has a **Graphify** knowledge graph already built. Graphify (https://graphify.net, `safishamsi/graphify`) indexes the codebase with Tree-sitter AST + Leiden clustering. The graph artifacts live in `graphify-out/`:

| File | What it is |
|---|---|
| `graphify-out/GRAPH_REPORT.md` | One-page audit: god nodes, communities, surprising connections. **Read first.** |
| `graphify-out/graph.json` | Persistent graph — nodes (functions/classes/concepts) and edges (calls/imports/rationale). Queryable. |
| `graphify-out/graph.html` | Interactive vis.js visualisation. Open in a browser for orientation. |
| `graphify-out/wiki/` | Wikipedia-style markdown per community (only if `--wiki` was run). |

**Why this exists:** every phase adds new nodes and edges. The graph is how Claude Code orients itself in a growing codebase without grep-walking the whole tree on every prompt — and how the auditor verifies the build hasn't drifted from the architecture. Graphify reportedly cuts query tokens by ~71×; for this repo the bigger win is structural awareness across phases.

### 3.1 Pre-implementation protocol (MANDATORY for every phase)

Before writing or modifying a single line of code, Claude Code MUST:

1. **Read `graphify-out/GRAPH_REPORT.md` end-to-end.** Note the god nodes, the communities relevant to the current phase, and any surprising connections that touch the phase's *Touches* scope.
2. **Run targeted queries** for every module the phase will touch. At minimum one of each below:
   - `/graphify query "<feature or concept>"` — find relevant nodes by meaning (e.g. `/graphify query "auth flow"`).
   - `/graphify path <node-A> <node-B>` — see how two areas already connect.
   - `/graphify explain <node>` — plain-English summary of a node and its neighbours.
3. **Capture the queries and findings** into the phase report under §10 of the report (the new "Graphify pre-implementation queries" heading). Each query gets one line: command run + one-sentence finding.
4. **If the graph contradicts CLAUDE.md** (reveals an existing helper the phase plan ignored, an undocumented dependency, etc.), pause, surface it to the user, and wait. Do not silently work around it.

### 3.2 Post-implementation protocol (MANDATORY for every phase)

After implementation but **before** writing the phase report, Claude Code MUST:

1. **Rebuild the graph** from the project root:
   ```
   /graphify .
   ```
   (or `graphify .` from a terminal). This rewrites `graphify-out/graph.json`, `GRAPH_REPORT.md`, and `graph.html`.
2. **Diff the GRAPH_REPORT.md** before/after the phase. Confirm:
   - New nodes match the Deliverables list for the phase.
   - No unexpected new god nodes (signals a shared widget Claude Code didn't extract).
   - No new community emerged that crosses feature boundaries (signals a leak through `core/`).
3. **Paste the rebuild output and a short diff summary** into the phase report under §11 of the report ("Graphify post-implementation update").
4. **Confirm `graphify-out/` is committed** alongside the phase changes so the next phase starts from a current graph.

If `graphify hook install` is active, the post-commit hook will rebuild automatically — but the explicit step above is still required because Claude Code stops *before* the commit.

### 3.3 Slash command cheat sheet

| Command | When to use |
|---|---|
| `/graphify .` | Full rebuild after a phase. Always run before writing the report. |
| `/graphify query "<text>"` | Search the graph by meaning before touching code. |
| `/graphify path <A> <B>` | Trace the dependency path between two nodes. |
| `/graphify explain <node>` | Plain-English summary of a node + its edges. |
| `/graphify --update` | Re-extract docs/images only (faster than full rebuild). Use only if Phase 0 docs change. |
| `/graphify --watch` | Background auto-sync. Reserved for Phase 9 (long backend integration). |
| `graphify hook install` | Git post-commit / post-checkout hooks (one-time setup). |

### 3.4 When the graph might be wrong

- **After major file deletions** (e.g. Phase 0's scorched earth): rebuild before querying. The graph may still reference removed nodes for one cycle.
- **After a rename**: the old node may persist for one rebuild cycle; re-run `/graphify .` to flush.
- **If `GRAPH_REPORT.md` god nodes disagree with this CLAUDE.md's architecture** (Section 6) — **the architecture wins**. Surface the discrepancy in §11 of the phase report; do not refactor to match the graph's view without auditor approval.

---

## 4. Project Snapshot

**Name:** eDRMP — Electronic Device Registration & Monitoring Portal
**Type:** Final Year Project, government-grade citizen + admin app (Pakistan / PTA context)
**Roles:** General User (citizen), Police Admin, PTA Admin
**Core loop:** Register device → Submit FIR → Request block → Track status
**Target:** Android-first MVP, demo-ready signed APK

The build is **UI-first**. Phases 0–8 build the entire app shell with mock/in-memory data. Phase 9 wires Supabase + FCM. Phase 10 hardens and ships. **No backend calls before Phase 9.**

---

## 5. Tech Stack (Locked)

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x (stable channel) |
| Language | Dart (sound null safety) |
| State | Riverpod (`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`) |
| Routing | `go_router` |
| Forms | `reactive_forms` (preferred) or `Form` + `TextFormField` |
| Secure storage | `flutter_secure_storage` |
| Local cache | `hive` / `hive_flutter` |
| Backend (Phase 9) | Supabase (`supabase_flutter`) |
| Push (Phase 9) | Firebase Cloud Messaging (`firebase_messaging`) |
| Maps (Phase 7) | `google_maps_flutter` |
| Images | `cached_network_image` |
| Codegen | `build_runner` + `freezed` + `json_serializable` + `riverpod_generator` |
| Lint | `flutter_lints` + the strict overrides in Section 2 |
| Knowledge graph | Graphify (Section 3) — already installed |

**No new dependency without listing it in the report and getting auditor approval.**

---

## 6. Document Hierarchy (Source of Truth)

When in doubt, resolve in this order:

1. **`CLAUDE.md`** (this file) — operational rules and phase plan. Overrides everything else.
2. **Claude Design handoff** (Section 7) — visual contract.
3. **`graphify-out/GRAPH_REPORT.md`** — current structural ground truth of the codebase. Read before every phase per Section 3.
4. **`docs/Architecture.md`** — patterns and layers.
5. **`docs/PRD.md`** — UX intent.
6. **`docs/MVP Tech Doc.md`** — backend plan (active in Phase 9).
7. **`docs/System Design.md`** — sequence diagrams, schemas.
8. **`docs/eDRMP — Design System & Screens.pdf`** — local mirror of the design.
9. **`docs/Software_Requirement_and_Design_Specification_SRDS.pdf`** — academic SRDS, full feature scope.

**`docs/implementation_phases.md` is REJECTED.** Use Section 8 of this file instead.

If `graphify-out/GRAPH_REPORT.md` and `docs/Architecture.md` disagree, the **architecture wins** (per Section 3.4). Surface the disagreement in the phase report.

---

## 7. Design Handoff Protocol

**Authoritative design (visual contract):**

```
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

The standard prompt to fetch it (use this in every phase that touches UI):

> *Fetch this design file, read its readme, and implement the relevant aspects of the design.*
> *https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html*

**Color tokens — every value below must appear in `theme/colors.dart` exactly once:**

| Group | Token | Hex |
|---|---|---|
| Brand | primary | `#0B2A5B` |
| Brand | primaryDark | `#071C40` |
| Brand | primaryLight | `#2A4A7F` |
| Brand | primarySoft | `#E6ECF6` |
| Brand | secondary | `#0E7C5A` |
| Brand | secondaryDark | `#0A5C43` |
| Brand | accent | `#C9A227` |
| Brand | tertiary | `#1F6FEB` |
| Light | scaffoldBackground | `#F4F6FA` |
| Light | surface | `#FFFFFF` |
| Light | card | `#FFFFFF` |
| Light | inputFill | `#F1F4F9` |
| Light | border | `#E1E6EF` |
| Light | divider | `#EDF0F5` |
| Dark | darkBackground | `#0A1428` |
| Dark | darkSurface | `#0F1B33` |
| Dark | darkCard | `#152544` |
| Dark | darkInput | `#0F1B33` |
| Dark | darkBorder | `#22335A` |
| Dark | darkDivider | `#1B2A4A` |
| Status | success | `#0E7C5A` |
| Status | successLight | `#E6F4EE` |
| Status | warning | `#B7791F` |
| Status | warningLight | `#FBF1D7` |
| Status | error | `#B42318` |
| Status | errorLight | `#FDECEA` |
| Status | info | `#1F6FEB` |
| Status | infoLight | `#E4EEFD` |
| Domain | pending | `#B7791F` |
| Domain | approved | `#0E7C5A` |
| Domain | rejected | `#B42318` |

**Typography:** Inter (UI) + JetBrains Mono (IMEI / monospace).
**Type scale:** display 28/800, title 20/800, heading 17/700, bodyStrong 14/600, body 13/500, caption 11/600 uppercase, mono 12/500.
**Radii:** 6, 9, 11, 14, ∞ (pill).
**Both light and dark themes are required from Phase 0 onward.**

---

## 8. Phase Plan (the only one that matters)

**Why this order beats the rejected plan in `implementation_phases.md`:**
- Phase 0 added: scorch the placeholder UI and lock the foundation (theme + shared widgets + lint config + Graphify baseline) **before** any feature screen is touched.
- Profile / Settings / Notifications-shell folded into the Citizen Shell phase — they're the same surface area.
- Maps split out of "Polish" into its own phase (Google Maps API + real coords ≠ skeleton shimmer).
- Polish runs **before** Backend Integration so polish lands on stable mock data, not a flaky backend.
- Backend swap is invisible — presentation layer is frozen during Phase 9.

| # | Phase | Headline |
|---|---|---|
| 0 | Scorched Earth + Foundation | Wipe wrong UI, lock theme, ship shared widgets, strict lints, Graphify baseline |
| 1 | Authentication Suite | Splash, login, register, forgot password (mock auth) |
| 2 | Citizen Shell + Profile/Settings/Notifications | App shell, dashboard hero, profile, settings, notifications shell |
| 3 | Citizen Devices Module | My Devices, Add Device flow, Device Details |
| 4 | Citizen FIR + Case Tracking | Submit FIR, FIR History, Case Timeline |
| 5 | Police Admin Module | Police dashboard, FIR queue, review/approve/reject |
| 6 | PTA Admin Module | Analytics dashboard, device approvals, block requests, audit log |
| 7 | Theft Hotspot Map | Google Maps with mock zones, risk legend |
| 8 | Polish Pass | Skeletons, transitions, pull-to-refresh, error/empty uniformity |
| 9 | Supabase + FCM Backend | Replace every mock; UI must not visibly change |
| 10 | QA, Lint Sweep, Release | Tests, signed APK, README, demo seed |

---

### Phase 0 — Scorched Earth + Foundation

*Already complete and approved. Graphify baseline rebuilt at end of phase.*

---

### Phase 1 — Authentication Suite

**Goal:** Build all auth screens pixel-faithful to the design. Mock auth controller, no backend.

**Touches:**
- `lib/features/auth/**`
- `lib/core/routes/app_router.dart` — auth-gate redirect logic
- `lib/core/widgets/**` — only to add a genuinely shared widget that emerged in Phase 0 review

**Replacement note:** the existing auth pages are Phase 0 stubs. Overwrite their bodies completely.

**Deliverables:**
1. **Splash** → already exists (Phase 0). Update only to use the real `currentUser` provider once mock auth is wired.
2. **Login page** — email + password, "Forgot password?" link, "Don't have an account? Register" link. Light + dark.
3. **Register page** — full name, CNIC (`xxxxx-xxxxxxx-x` mask), email, phone (`+92 3xx xxxxxxx` mask), password, confirm password, terms checkbox.
4. **Forgot password page** — email entry, "Send reset link" CTA, success state.
5. **Mock `AuthController` (Riverpod `AsyncNotifier`)** — `login`, `register`, `forgotPassword`, `logout`, `currentUser`. All async ops use `Future.delayed(const Duration(milliseconds: 400))`. Hard-coded demo accounts:
   ```
   demo.user@edrmp.pk    / Demo@1234  → role: user
   demo.police@edrmp.pk  / Demo@1234  → role: police
   demo.pta@edrmp.pk     / Demo@1234  → role: pta
   ```
6. **Validators** in `core/utils/app_validators.dart`: email, CNIC, Pakistani phone, password strength (most already present from Phase 0; verify and complete).
7. **Auth-gate redirect** in `go_router` — unauthenticated → `/login`; authenticated → role-based home.

**Acceptance criteria:**
- All screens visually match the design system handoff (Citizen — light + dark).
- Validation triggers on submit, errors render under the relevant field with humanised text.
- Each demo account routes to its correct shell stub.
- Logout returns to login.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt and committed; new auth nodes/community visible in `GRAPH_REPORT.md`.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phase 0 is approved. You are starting Phase 1 — Authentication Suite.

GRAPHIFY PRE-IMPLEMENTATION (per CLAUDE.md §3.1):
1. Read graphify-out/GRAPH_REPORT.md end-to-end.
2. Run /graphify query "auth", /graphify query "AuthController", and
   /graphify explain <auth feature node> for the auth-related nodes.
3. Capture queries + findings into the report under "Graphify
   pre-implementation queries".

IMPLEMENTATION:
The auth stub files from Phase 0 must be fully replaced with design-faithful
UI matching the Claude Design handoff. Mock data only. No Supabase calls.
Follow the AuthController spec in CLAUDE.md exactly.

GRAPHIFY POST-IMPLEMENTATION (per CLAUDE.md §3.2):
After code is done, before writing the report:
1. Run /graphify .
2. Diff GRAPH_REPORT.md vs the pre-phase version.
3. Paste rebuild output + diff summary into the report under "Graphify
   post-implementation update".

GATES:
Run dart fix --apply, dart format ., flutter analyze. Must end at "No issues found!".

REPORT:
Write docs/reports/PHASE_01_REPORT.md per CLAUDE.md §10 and stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 2 — Citizen Shell + Profile / Settings / Notifications

**Goal:** Citizen home shell with bottom nav + FAB, the dashboard hero from the design, plus profile / settings / notifications-shell pages.

**Touches:**
- `lib/features/dashboard/**`
- `lib/features/profile/**`
- `lib/features/settings/**`
- `lib/features/notifications/**`

**Replacement note:** existing files in these features are Phase 0 stubs. Replace fully.

**Deliverables:**
1. `app_shell_page.dart` — bottom nav: Home / Devices / [+ FAB] / FIR / Profile (matches dark+light hero). FAB opens a quick-action bottom sheet.
2. `dashboard_page.dart` — greeting (`"Assalam-o-Alaikum, {firstName}"`), notifications icon, profile icon, summary card (REGISTERED DEVICES count + ALL ACTIVE chip + APPROVED / PENDING / FIRS sub-stats), Quick Actions grid (Register device, Report FIR, Transfer, Verify IMEI), "My devices" preview list (max 2, "See all" link).
3. `profile_page.dart` — read-only profile (name, masked CNIC, email, phone, role badge, member-since), Sign out button.
4. `settings_page.dart` — language (English locked for MVP), theme (System/Light/Dark), notifications toggle (UI only), about, version.
5. `notifications_page.dart` — empty-state shell ("You're all caught up").
6. `dashboardMockProvider` (Riverpod) — 3 devices, 2 approved, 1 pending, 0 FIRs.

**Acceptance criteria:**
- Bottom nav navigates correctly; selected tab visually distinct.
- Light + dark both match the design.
- Greeting reads from `currentUser`.
- "See all" navigates to the Phase 3 stub.
- Theme switcher in settings actually flips themes.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; new dashboard/profile/settings/notifications communities visible.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-1 approved. Starting Phase 2 — Citizen Shell +
Profile/Settings/Notifications.

GRAPHIFY PRE-IMPLEMENTATION:
Read graphify-out/GRAPH_REPORT.md.
Run /graphify query "dashboard", /graphify query "profile",
/graphify query "AuthController" (to know what currentUser exposes),
and /graphify path <auth node> <dashboard node>.
Capture into the report.

IMPLEMENTATION:
Replace all stub files in these features fully. Mock data only.
Match Citizen — dark home hero and the light variant.

GRAPHIFY POST-IMPLEMENTATION:
Run /graphify ., diff GRAPH_REPORT.md, paste into the report.

GATES:
dart fix --apply, dart format ., flutter analyze → "No issues found!".

REPORT:
docs/reports/PHASE_02_REPORT.md per §10. Stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 3 — Citizen Devices Module

**Goal:** Full device-registration UX with real client-side IMEI Luhn validation.

**Touches:**
- `lib/features/devices/**`
- `lib/core/utils/app_validators.dart` (final IMEI Luhn)

**Deliverables:**
1. `my_devices_page.dart` — list of devices, each card: device icon, brand+model, masked IMEI (`356938 09 *** 7`), registration date, network operator, status badge. Filter chips (All / Active / Pending / Blocked). Empty state.
2. `add_device_page.dart` — multi-step form: Step 1 IMEI entry + auto-fill brand/model (mock dictionary lookup), Step 2 confirm, Step 3 success. Inline Luhn validation. "Continue" disabled until valid.
3. `device_details_page.dart` — full device record, IMEI in mono, status timeline, "Report FIR" CTA (enabled only when status `approved`).
4. Real Luhn validator in `app_validators.dart`.
5. Mock `DeviceRepository` — in-memory list + 400 ms delays.
6. Auto-fill dictionary covering at least: Apple iPhone 15 Pro, Samsung Galaxy S24, Xiaomi Redmi Note 13.

**Acceptance criteria:**
- Duplicate IMEI shows duplicate-error dialog.
- Valid IMEI walks through 3 steps, lands on `my_devices` with new card on top.
- Status badges colored from domain-status tokens.
- All async ops have loading + error states.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; device community visible.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-2 approved. Starting Phase 3 — Citizen Devices Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "device", /graphify query "IMEI",
/graphify query "validator", /graphify explain <app_validators node>.
Capture into report.

IMPLEMENTATION:
Replace all stub device files. Mock data only. Real Luhn validation now.
Match device-related screens in the design.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_03_REPORT.md, stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 4 — Citizen FIR + Case Tracking

**Goal:** Citizen FIR submission, history, and case tracking timeline.

**Touches:**
- `lib/features/fir/**`
- `lib/core/widgets/**` — only if a generic timeline widget emerges

**Deliverables:**
1. `submit_fir_page.dart` — form: select device (only `approved` devices), FIR number, police station, FIR date (date picker), description (multiline), proof upload (placeholder picker — real upload Phase 9), location capture (map picker placeholder — real map Phase 7). Sticky bottom Submit.
2. `fir_history_page.dart` — list of FIRs with status badges. Tappable → case tracking.
3. `case_tracking_page.dart` — vertical stepper using the State Dynamics diagram (SRDS PDF §5.5) as canonical: Device Registered → FIR Submitted → FIR Under Review → FIR Verified/Rejected → Block Pending → Block Approved/Rejected → Device Blocked / Recovered. Each step: icon, title, timestamp, optional note. Past = solid, current = highlighted, future = muted.
4. Mock `FirRepository` + `CaseStatusRepository` — 2 seeded FIRs across statuses.

**Acceptance criteria:**
- Submitting a FIR adds it to history with `Pending`.
- Timeline correctly renders past / current / future.
- Empty state when no FIRs.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; FIR community visible, links to device community.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-3 approved. Starting Phase 4 — Citizen FIR + Case Tracking.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "FIR", /graphify query "case status",
/graphify path <DeviceRepository node> <FirRepository node would-be>,
/graphify explain <DeviceRepository node>.
Capture into report.

IMPLEMENTATION:
Replace all stub FIR files. Mock data only. Use the State Dynamics diagram in
docs/Software_Requirement_and_Design_Specification_SRDS.pdf as the canonical state list.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_04_REPORT.md, stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 5 — Police Admin Module

**Goal:** Police admin dashboard + FIR queue + verify/reject action.

**Touches:**
- `lib/features/police/**`

**Deliverables:**
1. `police_dashboard_page.dart` — summary tiles (Pending / Verified Today / Rejected Today), CTA "Open Pending Queue".
2. `pending_fir_queue_page.dart` — list of FIRs needing verification, sorted desc, filter chips.
3. `fir_review_page.dart` — full FIR detail, citizen info, attached proof (placeholder viewer), Verify / Reject sticky bottom CTA pair. Reject captures non-empty reason. Both actions show `confirm_dialog`.
4. Police-side mock data: 5 FIRs (3 pending, 1 verified, 1 rejected), shared store with Phase 4.

**Acceptance criteria:**
- Verifying updates status, removes from pending queue.
- Reject reason persists in case timeline (shared mock store).
- Lists use `Approval queue` typography spec.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; police community visible, edges into FIR community.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-4 approved. Starting Phase 5 — Police Admin Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "FirRepository", /graphify query "case status",
/graphify path <FirRepository> <case_tracking node>.
Confirm the shared mock store is reachable. Capture into report.

IMPLEMENTATION:
Replace police stub. Mock data only. Match police screens. confirm_dialog for both verify and reject.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_05_REPORT.md, stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 6 — PTA Admin Module

**Goal:** PTA admin dashboard + device approvals + block-request approvals + audit log.

**Touches:**
- `lib/features/pta/**`

**Deliverables:**
1. `pta_dashboard_page.dart` — analytics tiles (Total devices, Approvals, Active FIRs, Blocked) per the Analytics screen. Static placeholder numbers/charts.
2. `device_approvals_page.dart` — pending registrations list, approve/reject with confirmation.
3. `block_requests_page.dart` — pending block requests, approve/reject with confirmation. Reject captures reason.
4. `pta_history_page.dart` — audit log of all PTA decisions with timestamps.
5. Mock data covering all four lists; shared store with citizen + police sides.

**Acceptance criteria:**
- Analytics tiles match design (light + dark).
- Approving a device flips its status in the shared store; citizen `my_devices` reflects.
- All admin actions create case_tracking audit entries.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; PTA community visible, edges into device + block-request communities.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-5 approved. Starting Phase 6 — PTA Admin Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "DeviceRepository", /graphify query "block request",
/graphify path <DeviceRepository> <device_details_page>,
/graphify explain <case_status_log-equivalent node>.
Capture into report.

IMPLEMENTATION:
Replace pta stub. Mock data only. Match Analytics light + dark for the dashboard.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_06_REPORT.md, stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 7 — Theft Hotspot Map

**Goal:** UI-only map with mock theft zones.

**Touches:**
- `lib/features/map/**`

**Deliverables:**
1. `theft_map_page.dart` — `google_maps_flutter` with 5–10 mock zones (markers + colored circles by risk: low/medium/high).
2. Tap marker → bottom sheet with FIR count + risk level.
3. Legend + recenter button.
4. Map style tuned for both light + dark.

**Acceptance criteria:**
- Map renders on emulator with placeholder API key (key not committed; setup documented).
- Markers semantically labelled.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; map community visible.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-6 approved. Starting Phase 7 — Theft Hotspot Map.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "map", /graphify query "FIR location",
/graphify explain <FirRepository node>.
Capture into report.

IMPLEMENTATION:
Document Google Maps API key setup in the report without committing the key.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_07_REPORT.md, stop.

Design reference:
https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 8 — Polish Pass

**Goal:** Apply animation, skeleton, and interaction polish across every existing screen. Visual lift only.

**Touches:** widgets and effects across all features. **No** changes to repositories, providers, or routing logic. **No** new screens.

**Deliverables:**
1. Skeleton shimmer for all async lists (`shimmer` package — declare in §5 of report).
2. Hero animation device card → device details.
3. Page transitions consistent (slide + fade).
4. Pull-to-refresh on every list.
5. Connectivity banner widget (offline indicator, mocked toggle).
6. Empty / error states uniform across features.
7. Subtle micro-animations (status badge pulse on `pending`, button press scale).

**Acceptance criteria:**
- 60 fps scroll on a mid-tier Android emulator.
- All lists show skeleton on load → empty state on no data.
- No regression in earlier phases.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; god nodes should NOT shift dramatically (polish ≠ structural change).

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-7 approved. Starting Phase 8 — Polish Pass.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note current god nodes — they should NOT change.
Run /graphify query "shared widget", /graphify query "AppCard",
/graphify query "ListView".
Capture into report.

IMPLEMENTATION:
No new screens. No repository or routing changes. Only animation, skeleton,
transition, refresh, and uniform empty/error states.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report. Confirm god nodes are unchanged.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_08_REPORT.md, stop.
```

---

### Phase 9 — Supabase + FCM Backend Integration

**Goal:** Replace every mock with real Supabase + FCM. Presentation layer is **frozen** — UI must not visibly change.

**Touches:** all `data/` layers in every feature, `core/network/`, `core/errors/`, new `core/services/supabase_service.dart`, `core/services/fcm_service.dart`, `main.dart`. Provider signatures stay identical.

**Deliverables:** see `docs/MVP Tech Doc.md` and `docs/System Design.md`. Schema, RLS, Edge Functions, FCM token, Realtime subscription, connectivity middleware, Sentry — all per spec.

**Acceptance criteria:**
- All three demo accounts work end-to-end on real backend.
- Full flow: register device → PTA approves → submit FIR → police verifies → request block → PTA approves → device blocked. Push fires at each transition.
- RLS verified.
- No `// MOCK` comments remain.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; communities should remain stable, but new data-layer nodes appear under each feature's `data/`.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-8 approved. Starting Phase 9 — Supabase + FCM Backend Integration.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note that every Mock<X>Repository node will be replaced.
Run /graphify query "MockDeviceRepository", /graphify query "MockFirRepository",
/graphify query "AuthController", and for each, /graphify explain <node>
to surface every caller.
Optionally start /graphify --watch in a separate terminal for the duration of this phase.
Capture queries into the report.

IMPLEMENTATION:
Replace every mock with real Supabase. Presentation layer must not change.
Follow docs/MVP Tech Doc.md and docs/System Design.md for schema, RLS, Edge Functions.
Document Supabase project URL and bucket setup in the report. No secrets committed.

GRAPHIFY POST-IMPLEMENTATION:
/graphify . — diff — paste into report. Confirm presentation-layer god nodes unchanged.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_09_REPORT.md, stop.
```

---

### Phase 10 — QA, Lint Sweep, Release

**Goal:** Production-ready signed APK.

**Touches:** test files, lint config, build config, `README.md`.

**Deliverables:**
1. Unit tests: all use cases / validators (≥ 70 % coverage).
2. Widget tests: login, register, device add, FIR submit, case timeline, police review, PTA approval.
3. One integration test running happy path against a Supabase test project.
4. Whole-tree lint sweep — `flutter analyze` clean, `dart format .` applied, `dart fix --apply` no-op.
5. App icon + splash screen finalised.
6. Signed release APK; keystore in CI secrets, documented.
7. `README.md` with setup, env vars, demo credentials, build command, screenshots, **and a "Knowledge graph" section pointing to `graphify-out/GRAPH_REPORT.md`**.
8. Demo seed-data script committed.

**Acceptance criteria:**
- CI green.
- Zero crash-blocking bugs in happy path.
- Tested on Android 8 + Android 14.
- Graphify graph committed and current.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-9 approved. Starting Phase 10 — QA, Lint Sweep, Release.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note all god nodes — they will be referenced from README.md.
Run /graphify query "test", /graphify explain <build_runner node if any>.
Capture into report.

IMPLEMENTATION:
Hit coverage targets. Build signed release APK. Update README.md with the
"Knowledge graph" section pointing to graphify-out/GRAPH_REPORT.md.

GRAPHIFY POST-IMPLEMENTATION:
Final /graphify . — diff — paste into report.

GATES: → "No issues found!".
REPORT: docs/reports/PHASE_10_REPORT.md, stop.
```

---

## 9. What Claude Code MUST Refuse

Without explicit out-of-band instruction, refuse and point back here:

- Working on a phase not yet authorised.
- Touching files outside the current phase's *Touches* scope.
- **Skipping the Graphify pre-implementation read or queries (Section 3.1).**
- **Skipping the Graphify post-implementation rebuild (Section 3.2).**
- Adding a dependency not in Section 5.
- Real backend calls before Phase 9.
- Hardcoded colors, paddings, durations, or strings outside the constants/theme files.
- Suppressing a lint with `// ignore:` or `ignore_for_file:`.
- Skipping `dart fix --apply` / `dart format .` / `flutter analyze` before declaring done.
- Skipping the Implementation Report.
- Committing secrets, API keys, or `.env` files.
- Declaring a phase complete when `flutter analyze` shows anything other than `No issues found!`.
- Declaring a phase complete when `graphify-out/` is stale or uncommitted.

---

## 10. Implementation Report Format

Claude Code writes one of these to `docs/reports/PHASE_NN_REPORT.md` at the end of every phase. Do not skip any heading.

```markdown
# Phase NN — <Phase Name> — Implementation Report

## 1. Status
- [x] Complete  /  [ ] Partial  /  [ ] Blocked
- Date completed:
- Branch / commit:

## 2. Files created
- path/to/file.dart — purpose

## 3. Files modified
- path/to/file.dart — what changed and why

## 4. Files deleted (or fully overwritten from stub)
- path/to/file.dart — Phase 0 stub fully replaced  /  deleted because <reason>

## 5. New dependencies
- pkg_name ^x.y.z — reason  (or "none")

## 6. Deviations from CLAUDE.md
- "<exact rule deviated from>" — reason — proposed permanent change  (or "none")

## 7. Mock data introduced
- Where it lives, the future-phase TODO marker, example payload.

## 8. Design fidelity check
- Screen → matches design? (yes / partial — explain)
- Light + dark both verified? (yes / no)

## 9. Graphify pre-implementation queries
List every Graphify command run before writing code, with one-sentence findings:
- `/graphify query "auth"` → found AuthController node in `lib/features/auth/logic/`,
  3 callers, no current edges to dashboard.
- `/graphify path AuthController DashboardPage` → no path; will create one this phase.
- `/graphify explain AppButton` → reused by 4 stub pages already, safe to rely on.

(If zero queries — phase status is **Blocked**, not Complete.)

## 10. Lint / format / analyze output (paste verbatim)

    $ dart fix --apply
    (no changes)

    $ dart format .
    Formatted N files (0 changed).

    $ flutter analyze
    Analyzing project...
    No issues found! (ran in X.Xs)

If anything other than "No issues found!" appears here, status above MUST be Partial or Blocked.

## 11. Graphify post-implementation update
Paste verbatim:

    $ /graphify .
    <output>

Then summarise the diff vs the previous GRAPH_REPORT.md:
- New nodes added: …
- New community formed: …  (or: no new community)
- God nodes changed? (yes / no — if yes, explain)
- Cross-feature edges leaked through `core/`? (yes / no)

(If `graphify .` was not run — phase status is **Blocked**.)

## 12. Manual test log
- Step-by-step what you ran and what happened. Screenshots if possible.

## 13. Known issues / debt
- List anything intentionally deferred. Each item references a future phase.

## 14. What I touched outside Touches scope (should be empty)
- If non-empty, explain why and ask the auditor to bless it.

## 15. Ready for auditor?
- [ ] Yes — please review.
```

---

## 11. Audit Loop

```
USER ↦ Claude Code:  "Begin Phase N." (copy the Prompt block from Section 8)
Claude Code:         §3.1 reads + queries → implements → §3.2 rebuild
                     → writes PHASE_NN_REPORT.md → stops.
USER ↦ Auditor:      pastes the report (and any concerning code).
Auditor:             returns ✅ Approve  OR  ✏️ Change list.
  Approve   →  USER ↦ Claude Code: "Begin Phase N+1."
  Changes   →  USER ↦ Claude Code: "Apply these changes to Phase N: <list>.
                                     Re-run §3.2 if code changed.
                                     Update PHASE_NN_REPORT.md and stop."
Repeat.
```

**Auditor rejects on:** scope creep, theme/constants violations, hardcoded literals, dead code, unused imports, missing loading/empty states, design drift from the handoff, missing report sections, **missing Graphify §9 or §11 of the report**, **stale `graphify-out/`**, new deps without justification, untested validators, `flutter analyze` showing anything other than `No issues found!`, or any rule in Sections 1, 2, 3, or 9 broken.

---

## 12. Quick Reference Card

- **Section 1 first:** existing UI is wrong → rebuild from the design handoff.
- **Section 2 always:** zero analyzer issues, zero unused imports, zero suppressions.
- **Section 3 every phase:** read GRAPH_REPORT.md and query before coding; rebuild after.
- **One phase at a time.** Stop at the report.
- **`theme/colors.dart` + `core/constants/*` are the only sources of style atoms.**
- **`core/widgets/` for anything reused on more than one screen.**
- **Mock until Phase 9. Real from Phase 9.**
- **`flutter analyze` must say `No issues found!` before claiming done.**
- **`graphify-out/` must be current and committed before claiming done.**

---

*End of CLAUDE.md*

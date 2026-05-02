# CLAUDE.md — eDRMP Implementation Playbook

> **Read this entire file before writing a single line of code.**
> This file is the **only** source of truth for the build order and rules.
> The phase ordering in `docs/implementation_phases.md` is **rejected and superseded** by Section 8 of this file. If anything in the user's prompts conflicts with this file, ask — do not improvise.

---

## 0. How This Playbook Works

1. The project is delivered in **12 phases (Phase 0, 1, 1.5, 2 … 10)**. One phase at a time. Period.
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

The Claude Design handoff (Section 7) is the visual contract. If a screen Claude Code produces doesn't visually match the corresponding `Screen<X>` function in the handoff JSX, it is wrong and must be redone.

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

**`analysis_options.yaml`** as configured in Phase 0 stays in force. **Mandatory pre-report sequence** (Claude Code runs all and pastes verbatim into §10 of the report):

```bash
dart fix --apply
dart format .
flutter analyze
flutter test  # only from Phase 10 onward
```

If any output is not clean, the phase is **not done** and the report status is `Partial` or `Blocked` — never `Complete`.

---

## 3. Graphify Knowledge Graph Protocol

This project has a **Graphify** knowledge graph already built. Graphify (https://graphify.net, `safishamsi/graphify`) indexes the codebase with Tree-sitter AST + Leiden clustering. The graph artifacts live in `graphify-out/`:

| File | What it is |
|---|---|
| `graphify-out/GRAPH_REPORT.md` | One-page audit: god nodes, communities, surprising connections. **Read first.** |
| `graphify-out/graph.json` | Persistent graph — nodes (functions/classes/concepts) and edges. Queryable. |
| `graphify-out/graph.html` | Interactive vis.js visualisation. |
| `graphify-out/wiki/` | Wikipedia-style markdown per community (only if `--wiki` was run). |

After the handoff bundle is committed at `design/handoff/`, `graphify .` indexes those JSX/HTML/Markdown files too — so `/graphify query "ScreenCitizenHome"` returns the design node and its connections. **Always rebuild the graph after extracting the handoff.**

### 3.1 Pre-implementation protocol (MANDATORY)

Before writing or modifying a single line of code, Claude Code MUST:

1. **Read `graphify-out/GRAPH_REPORT.md` end-to-end.** Note the god nodes, the communities relevant to the current phase, and any surprising connections that touch the phase's *Touches* scope.
2. **Run targeted queries** for every module the phase will touch. At minimum one of each:
   - `/graphify query "<feature or concept>"`
   - `/graphify path <node-A> <node-B>`
   - `/graphify explain <node>`
3. **Capture queries + findings** into the phase report under §9.
4. **If the graph contradicts CLAUDE.md** (existing helper the plan ignored, undocumented dependency, etc.), pause and surface to the user.

### 3.2 Post-implementation protocol (MANDATORY)

After implementation but **before** writing the report, Claude Code MUST:

1. **Rebuild the graph:** `/graphify .` (or `graphify .` from a terminal).
2. **Diff the GRAPH_REPORT.md** before/after. Confirm new nodes match Deliverables; no unexpected new god nodes; no new community crosses feature boundaries.
3. **Paste the rebuild output and diff summary** into §11 of the report.
4. **Confirm `graphify-out/` is committed** alongside the phase changes.

### 3.3 Slash command cheat sheet

| Command | When to use |
|---|---|
| `/graphify .` | Full rebuild after a phase. Always run before writing the report. |
| `/graphify query "<text>"` | Search the graph by meaning. |
| `/graphify path <A> <B>` | Trace dependency path between two nodes. |
| `/graphify explain <node>` | Plain-English summary of a node + its edges. |
| `/graphify --update` | Re-extract docs/images only. Use after editing CLAUDE.md or design files. |
| `/graphify --watch` | Background auto-sync. Reserved for Phase 9. |
| `graphify hook install` | Git post-commit / post-checkout hooks (one-time). |

### 3.4 When the graph might be wrong

- After major file deletions: rebuild before querying.
- After a rename: re-run `/graphify .` to flush.
- If `GRAPH_REPORT.md` god nodes disagree with CLAUDE.md's architecture (Section 6) — **the architecture wins**. Surface in §11 of the phase report.

---

## 4. Project Snapshot

**Name:** eDRMP — Electronic Device Registration & Monitoring Portal
**Type:** Final Year Project, government-grade citizen + admin app (Pakistan / PTA context)
**Roles:** General User (citizen), Police Admin, PTA Admin
**Core loop:** Register device → Submit FIR → Request block → Track status
**Target:** Android-first MVP, demo-ready signed APK

The build is **UI-first**. Phases 0–8 build the entire app shell with mock/in-memory data. Phase 9 wires Supabase + FCM. Phase 10 hardens and ships. **No backend calls before Phase 9.**

**Out of scope (do not implement at any phase):** KYC / NADRA biometric verification, theft hotspot real-time geofencing, in-app chat, super admin dashboard, PDF report export, profile editing, multi-language, DIRBS API, biometric login. KYC was explicitly removed by the user — do not bring it back.

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
| Lint | `flutter_lints` + the strict overrides locked in Phase 0 |
| Knowledge graph | Graphify (Section 3) — installed |

**No new dependency without listing it in the report and getting auditor approval.**

---

## 6. Document Hierarchy (Source of Truth)

When in doubt, resolve in this order:

1. **`CLAUDE.md`** (this file) — operational rules and phase plan. Overrides everything else.
2. **`design/handoff/README.md`** — coding-agent instructions from Claude Design.
3. **`design/handoff/chats/chat1.md`** — full design conversation. *"This is where the intent lives"* (per the handoff README). Read before any UI phase.
4. **`design/handoff/project/eDRMP Design System.html`** + the relevant `screens-*.jsx` for the current phase — the visual contract.
5. **`graphify-out/GRAPH_REPORT.md`** — current structural ground truth of the codebase.
6. **`docs/Architecture.md`** — patterns and layers.
7. **`docs/PRD.md`** — UX intent.
8. **`docs/MVP Tech Doc.md`** — backend plan (active in Phase 9).
9. **`docs/System Design.md`** — sequence diagrams, schemas.
10. **`docs/Software_Requirement_and_Design_Specification_SRDS.pdf`** — academic SRDS (note: KYC requirements there are out of scope per Section 4).

**`docs/implementation_phases.md` is REJECTED.** Use Section 8 of this file instead.

If `design/handoff/` and `docs/Architecture.md` disagree on a structural point, the **architecture wins** (graph is descriptive; the handoff is visual; CLAUDE.md is prescriptive). Surface disagreements in the phase report.

---

## 7. Design Handoff Protocol (LOCAL FILES — NO WEBFETCH)

The Claude Design handoff is shipped as a **downloadable bundle**, extracted at `design/handoff/`. The hosted URL on `api.anthropic.com/v1/design/h/...` returns a tarball as an HTTP attachment, not a browsable page. **Do not call `WebFetch` on it.** Read the local files directly.

**Per the bundle's own README (`design/handoff/README.md`):**
> *Don't render these files in a browser or take screenshots unless the user asks you to. Everything you need — dimensions, colors, layout rules — is spelled out in the source. Read the HTML and CSS directly; a screenshot won't tell you anything they don't.*

### 7.1 Bundle layout (authoritative path)

```
design/handoff/
├── README.md                              ← coding-agent instructions
├── chats/
│   └── chat1.md                          ← design conversation; read before any UI phase
└── project/
    ├── eDRMP Design System.html          ← primary design document
    ├── eDRMP Design System-print.html
    ├── tokens.js                          ← design tokens source
    ├── colors.dart                        ← Flutter-ready palette (94 tokens, AppColors class)
    ├── components.jsx                     ← shared component contracts
    ├── screens-citizen.jsx                ← Onboarding, KYC, Home, Device Register, DeviceDetail, FIR
    ├── screens-officer.jsx                ← OfficerScan, OfficerResult
    ├── screens-admin.jsx                  ← AdminQueue, AdminAnalytics, Chart, RiskMap, AdminReview
    ├── design-canvas.jsx
    ├── edrmp-tweaks.jsx
    └── tweaks-panel.jsx
```

### 7.2 Read order for any UI phase

1. `design/handoff/README.md` — coding-agent instructions.
2. `design/handoff/chats/chat1.md` — design conversation. *Where the intent lives.*
3. `design/handoff/project/eDRMP Design System.html` — primary design document (skim, don't render).
4. The screen JSX function relevant to the current phase (see §7.4 mapping below).
5. `design/handoff/project/components.jsx` — every helper component the screen references (e.g. `Card`, `Btn`, `BottomNav`, `AppHeader`, `DeviceCard`, `Timeline`, `Stat`, `Field`, `Illustration`, `PhoneGlyph`, `Row`).
6. `design/handoff/project/tokens.js` — for any token not already in `colors.dart`.

### 7.3 Color tokens — single contract

The full palette is **`design/handoff/project/colors.dart`** (94 tokens, already namespaced as `class AppColors`). **`lib/theme/colors.dart` MUST mirror it exactly** — same constants, same hex values, same private constructor pattern.

A Phase 1 closeout sync was applied at the start of Phase 1.5 (Section 8). Future phases must not introduce new color constants in `lib/theme/colors.dart` unless the same constant exists in the handoff `colors.dart` first. If a phase needs a token the handoff doesn't define, surface it in the report and propose adding it to *both* files in lockstep.

### 7.4 Screen → Phase → JSX function mapping

| Phase | JSX file | Functions to implement |
|---|---|---|
| 1 | *(no handoff source)* | Splash, Login, Register, Forgot Password — built |
| 1.5 | `screens-citizen.jsx` | `ScreenOnboarding` (lines ~7–46) |
| 2 | `screens-citizen.jsx` | `ScreenCitizenHome` variants `'a'` (hero) and `'b'` (stats grid); `IconBtn`, `Mini`, `QuickAction` helpers |
| 3 | `screens-citizen.jsx` | `ScreenRegister` (DEVICE registration, not account), `ScreenDeviceDetail` |
| 4 | `screens-citizen.jsx` | `ScreenFIR`; case-tracking timeline composed from `Timeline` component in `components.jsx` |
| 5 | `screens-officer.jsx` | `ScreenOfficerScan`, `ScreenOfficerResult` (use these for the Police Admin module) |
| 6 | `screens-admin.jsx` | `ScreenAdminQueue`, `ScreenAdminAnalytics`, `Chart`, `ScreenAdminReview` |
| 7 | `screens-admin.jsx` | `RiskMap` (extract into the theft_map_page) |
| 8 | *(polish, no new screens)* | — |
| 9 | *(backend swap, no UI changes)* | — |
| 10 | *(QA + release)* | — |

**Important note on `ScreenKYC`:** It appears in `screens-citizen.jsx` (lines ~48–96) but is **out of scope** per the user's decision in Section 4. Do not implement it at any phase. If a future iteration brings it back, it'll be added explicitly to this table.

### 7.5 Reading JSX as a Flutter contract

The handoff is React JSX, not Flutter. Read it as a *contract for visual output*, not a structural template. Specifically:

- A `<Card dark={dark}>...</Card>` in JSX → Flutter `AppCard` from `lib/core/widgets/app_card.dart`.
- `<Btn kind="primary" full size="lg">` → `AppButton(variant: AppButtonVariant.primary, size: AppButtonSize.large, fullWidth: true)`.
- `<StatusPill kind="verified" dark={dark}>` → `StatusBadge(kind: StatusBadgeKind.verified)`.
- `<Field dark={dark} label="..." value="..." mono>` → `AppInput(label: ..., initialValue: ..., monospace: true)`.
- Hex literals in `style={{ background: '#5DD3A8', ... }}` → look up the closest token in `AppColors`. If none exists, flag it in the report.
- `dark` prop branching → `Theme.of(context).brightness == Brightness.dark` (or read the theme directly).
- `gridTemplateColumns:'1fr 1fr'` → `GridView.count(crossAxisCount: 2, ...)`.

Do not translate React state, refs, or hooks — only the **rendered structure, spacing, typography, and colors**.

---

## 8. Phase Plan

| # | Phase | Headline |
|---|---|---|
| 0 | Scorched Earth + Foundation | Wipe wrong UI, lock theme, ship shared widgets, strict lints, Graphify baseline ✅ DONE |
| 1 | Authentication Suite | Splash, login, register, forgot password (mock auth) ✅ DONE |
| 1.5 | Onboarding | Single new screen + first-launch routing |
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

### Phases 0 & 1 — DONE

Already complete and approved. Phase 1 fix-ups (rename `sendPasswordReset` → `forgotPassword`, add `TODO(Phase 9)` marker, restructure report to §1–§15) sealed.

---

### Phase 1.5 — Onboarding

**Goal:** Insert the handoff's `ScreenOnboarding` between Splash and Login. First-launch users see onboarding; returning users skip directly to login. Also: synchronise `lib/theme/colors.dart` with the handoff's `colors.dart` as a Phase 1 closeout step (bundled into this phase).

**Touches:**
- `lib/theme/colors.dart` — sync to handoff (closeout from Phase 1)
- `lib/features/onboarding/**` (new feature folder)
- `lib/core/routes/route_names.dart` — add `onboarding`
- `lib/core/routes/app_routes.dart` — add route
- `lib/core/routes/app_router.dart` — first-launch redirect logic
- `lib/features/auth/presentation/splash_page.dart` — first-launch routing
- `lib/core/constants/app_strings.dart` — add Onboarding strings group

**Deliverables:**

1. **`lib/theme/colors.dart` token sync.** Replace the file contents with `design/handoff/project/colors.dart` verbatim. Re-run `flutter analyze` to confirm no existing references break (the handoff is a superset of what we had). Existing token names that already match — no rename. Net effect: ~64 new constants added, 0 removed.

2. **`lib/features/onboarding/presentation/onboarding_page.dart`** — pixel-faithful match to `ScreenOnboarding` in `design/handoff/project/screens-citizen.jsx` (lines ~7–46). Single screen with: brand chip top-left, "Skip" top-right, central shield illustration (placeholder OK; real asset Phase 8), title "Register your phone with PTA", body text, 3-dot page indicator (first dot wide), "Get started" primary CTA full-width, "Already registered? Sign in" link below. Light + dark variants.

   The JSX shows a 3-dot indicator suggesting a multi-slide carousel, but only one slide is rendered. **Decision: build it as a single slide for Phase 1.5.** The indicator is decorative for now (3 dots, only the first wide). If `chat1.md` reveals intent for additional slides, surface that in §6 of the report and propose Phase 1.5 fix-up.

3. **`lib/features/onboarding/logic/onboarding_controller.dart`** — Riverpod `Notifier<bool>` exposing `hasSeenOnboarding`. Backed by an in-memory flag with:
   ```dart
   // TODO(Phase 9): persist via flutter_secure_storage so onboarding-seen
   // survives cold restarts.
   ```

4. **CTAs:**
   - "Get started" → `markSeen()` then `context.go(RouteNames.login)`.
   - "Skip" → `markSeen()` then `context.go(RouteNames.login)`.
   - "Already registered? Sign in" → `context.go(RouteNames.login)` **without** marking seen (the user is returning; leave the flag alone for the next fresh install).

5. **Splash redirect** in `splash_page.dart` — after the existing 1.2 s brand pause:
   - If `!hasSeenOnboarding` → `/onboarding`
   - Else fall through to existing logic (auth state → role-based home or `/login`).

6. **`route_names.dart` + `app_routes.dart`** — add `onboarding = '/onboarding'`. Wire `OnboardingPage` into `appRoutes`.

7. **`app_router.dart` redirect** — leave the existing auth gate alone; the splash handles first-launch routing because the onboarding decision needs to happen *after* the brand pause, not at app boot.

8. **`app_strings.dart`** — add an `Onboarding` group: title, body, skip, get-started, sign-in-link. No literals in widgets.

**Acceptance criteria:**
- First launch (cold): splash → onboarding → login.
- Re-launch within session (in-memory flag persists): splash → login directly.
- Each CTA navigates correctly.
- Light + dark match the JSX.
- `lib/theme/colors.dart` byte-for-byte (modulo whitespace) equivalent to `design/handoff/project/colors.dart`.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; new `Onboarding` community visible; `colors.dart` god-node edge count rises (more constants).

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0 and 1 (with fix-ups) are approved. You are starting
Phase 1.5 — Onboarding.

GRAPHIFY PRE-IMPLEMENTATION (per CLAUDE.md §3.1):
1. Read graphify-out/GRAPH_REPORT.md end-to-end.
2. Run /graphify query "ScreenOnboarding", /graphify query "splash",
   /graphify query "AuthController", and /graphify path SplashPage LoginPage.
3. Capture queries + findings in §9 of the report.

DESIGN READ ORDER (per CLAUDE.md §7.2) — do this BEFORE coding:
1. design/handoff/README.md (coding-agent instructions)
2. design/handoff/chats/chat1.md (design intent — read in full)
3. design/handoff/project/eDRMP Design System.html (skim, don't render)
4. design/handoff/project/screens-citizen.jsx — function ScreenOnboarding
   (~lines 7–46)
5. design/handoff/project/components.jsx — Logo, Btn, Illustration

IMPLEMENTATION:
Bundle the colors.dart sync (Phase 1 closeout) with the onboarding feature
per CLAUDE.md §8 Phase 1.5 Deliverables. Follow each Deliverable item in order.
Single-slide onboarding; 3-dot indicator is decorative.

GRAPHIFY POST-IMPLEMENTATION (per CLAUDE.md §3.2):
1. /graphify .
2. Diff GRAPH_REPORT.md vs the pre-phase version.
3. Paste rebuild output + diff summary in §11 of the report.

GATES:
dart fix --apply, dart format ., flutter analyze. Must end at "No issues found!".

REPORT:
Write docs/reports/PHASE_01_5_REPORT.md per CLAUDE.md §10 and stop.
```

---

### Phase 2 — Citizen Shell + Profile / Settings / Notifications

**Goal:** Citizen home shell with bottom nav + FAB, the dashboard hero from the handoff, plus profile / settings / notifications-shell pages.

**Touches:** `lib/features/dashboard/**`, `lib/features/profile/**`, `lib/features/settings/**`, `lib/features/notifications/**`.

**Replacement note:** existing files in these features are Phase 0 stubs. Replace fully.

**Deliverables:**
1. `app_shell_page.dart` — bottom nav per `BottomNav` in `components.jsx`. FAB opens a quick-action bottom sheet.
2. `dashboard_page.dart` — pixel match to `ScreenCitizenHome` variant `'a'` (hero with navy gradient + REGISTERED DEVICES card + Approved/Pending/FIRs mini-stats + Quick Actions grid + My devices preview). Reuse `IconBtn`, `Mini`, `QuickAction` helper patterns from the JSX.
3. `profile_page.dart` — read-only profile (name, masked CNIC, email, phone, role badge, member-since), Sign out button.
4. `settings_page.dart` — language (English locked), theme (System/Light/Dark), notifications toggle, about, version.
5. `notifications_page.dart` — empty-state shell ("You're all caught up").
6. `dashboardMockProvider` (Riverpod) — 3 devices, 2 approved, 1 pending, 0 FIRs.

**Acceptance criteria:**
- Bottom nav matches `BottomNav` JSX exactly.
- Hero gradient and REGISTERED DEVICES card visually faithful (the rgba whites and the `'#5DD3A8'` chip green map to the handoff `colors.dart`).
- Light + dark both pass.
- "See all" navigates to Phase 3 stub.
- Theme switcher actually flips themes.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; dashboard / profile / settings / notifications communities visible.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0–1.5 approved. Starting Phase 2 — Citizen Shell.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "ScreenCitizenHome", /graphify query "BottomNav",
/graphify query "currentUser", /graphify path ScreenOnboarding ScreenCitizenHome.
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/README.md
2. design/handoff/chats/chat1.md
3. design/handoff/project/screens-citizen.jsx — ScreenCitizenHome (variants 'a' and 'b'),
   IconBtn, Mini, QuickAction helpers
4. design/handoff/project/components.jsx — BottomNav, Card, DeviceCard, Stat

IMPLEMENTATION:
Replace all stub files in the four features. Mock data only.
Pixel-match ScreenCitizenHome variant 'a' for the home hero.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_02_REPORT.md per §10. Stop.
```

---

### Phase 3 — Citizen Devices Module

**Goal:** Full device-registration UX with real client-side IMEI Luhn validation.

**Touches:** `lib/features/devices/**`, `lib/core/utils/app_validators.dart` (final IMEI Luhn).

**Deliverables:**
1. `my_devices_page.dart` — devices list per `DeviceCard` in `components.jsx`. Filter chips (All / Active / Pending / Blocked). Empty state.
2. `add_device_page.dart` — multi-step form per `ScreenRegister` in `screens-citizen.jsx` (lines ~237–276). Step 1 IMEI entry + auto-fill (mock dictionary), Step 2 confirm, Step 3 success. Inline Luhn validation. "Continue" disabled until valid.
3. `device_details_page.dart` — pixel match to `ScreenDeviceDetail` (lines ~281–310). IMEI in mono, status timeline, "Report FIR" CTA enabled only when status `approved`.
4. Real Luhn validator in `app_validators.dart`.
5. Mock `DeviceRepository` — in-memory list + 400 ms delays.
6. Auto-fill dictionary covering: Apple iPhone 15 Pro, Samsung Galaxy S24, Xiaomi Redmi Note 13.

**Acceptance criteria:**
- Duplicate IMEI shows duplicate-error dialog.
- Valid IMEI walks 3 steps; new card lands on top of `my_devices`.
- Status badges colored from domain-status tokens.
- All async ops have loading + error states.
- `flutter analyze` → `No issues found!`
- Graphify rebuilt; device community visible.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0–2 approved. Starting Phase 3 — Citizen Devices Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "device", /graphify query "IMEI",
/graphify query "ScreenRegister", /graphify explain AppValidators.
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/chats/chat1.md
2. design/handoff/project/screens-citizen.jsx — ScreenRegister (DEVICE — lines ~237–276),
   ScreenDeviceDetail (lines ~281–310)
3. design/handoff/project/components.jsx — DeviceCard, Field, PhoneGlyph

IMPLEMENTATION:
Replace all stub device files. Mock data. Real Luhn validation.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_03_REPORT.md, stop.
```

---

### Phase 4 — Citizen FIR + Case Tracking

**Touches:** `lib/features/fir/**`, optionally `lib/core/widgets/**` (timeline if generic).

**Deliverables:**
1. `submit_fir_page.dart` — pixel match to `ScreenFIR` (lines ~315 to end of file in `screens-citizen.jsx`). Form: select device (only `approved` devices), FIR number, police station, FIR date, description, proof upload (placeholder picker — real upload Phase 9), location capture (map picker placeholder — real map Phase 7). Sticky bottom Submit.
2. `fir_history_page.dart` — list of FIRs with status badges. Tappable → case tracking.
3. `case_tracking_page.dart` — vertical stepper composed from `Timeline` in `components.jsx`. Canonical state list from SRDS §5.5: Device Registered → FIR Submitted → FIR Under Review → FIR Verified/Rejected → Block Pending → Block Approved/Rejected → Device Blocked / Recovered. Past = solid, current = highlighted, future = muted.
4. Mock `FirRepository` + `CaseStatusRepository` — 2 seeded FIRs across statuses.

**Acceptance criteria:** FIR submit adds Pending entry; timeline renders past/current/future correctly; empty state when no FIRs; `flutter analyze` clean; Graphify rebuilt.

**Prompt:**

```
Read CLAUDE.md. Phases 0–3 approved. Starting Phase 4 — Citizen FIR + Case Tracking.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "ScreenFIR", /graphify query "Timeline",
/graphify query "DeviceRepository", /graphify path DeviceRepository ScreenFIR.
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/chats/chat1.md
2. design/handoff/project/screens-citizen.jsx — ScreenFIR
3. design/handoff/project/components.jsx — Timeline, Field, Card

IMPLEMENTATION:
Replace stub FIR files. Mock data. Use the State Dynamics diagram in
docs/Software_Requirement_and_Design_Specification_SRDS.pdf §5.5 as the canonical state list.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_04_REPORT.md, stop.
```

---

### Phase 5 — Police Admin Module

**Touches:** `lib/features/police/**`.

**Deliverables:**
1. `police_dashboard_page.dart` — derived from `ScreenOfficerScan` (lines ~6–88 in `screens-officer.jsx`). Summary tiles + CTA "Open Pending Queue".
2. `pending_fir_queue_page.dart` — FIR list with filter chips.
3. `fir_review_page.dart` — pixel match to `ScreenOfficerResult` (lines ~89–end). Verify / Reject sticky bottom CTAs. Reject captures non-empty reason. `confirm_dialog` for both actions.
4. Mock data: 5 FIRs (3 pending, 1 verified, 1 rejected), shared store with Phase 4.

**Acceptance criteria:** Verify updates status + drops from queue; reject reason persists in case timeline; lists use `Approval queue` typography; clean analyze; Graphify rebuilt.

**Prompt:**

```
Read CLAUDE.md. Phases 0–4 approved. Starting Phase 5 — Police Admin Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "FirRepository", /graphify query "ScreenOfficerScan",
/graphify query "ScreenOfficerResult", /graphify path FirRepository case_tracking_page.
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/chats/chat1.md
2. design/handoff/project/screens-officer.jsx — ScreenOfficerScan, ScreenOfficerResult
3. design/handoff/project/components.jsx — StatusPill, Card, Btn

IMPLEMENTATION:
Replace police stub. Mock data. Use confirm_dialog for both verify and reject.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_05_REPORT.md, stop.
```

---

### Phase 6 — PTA Admin Module

**Touches:** `lib/features/pta/**`.

**Deliverables:**
1. `pta_dashboard_page.dart` — pixel match to `ScreenAdminAnalytics` (lines ~110–211 in `screens-admin.jsx`). Use the static `Chart` component (lines ~212–244) as the visual reference; static chart placeholders OK for Phase 6.
2. `device_approvals_page.dart` — pixel match to `ScreenAdminQueue` (lines ~6–109).
3. `block_requests_page.dart` — variant of approvals queue, separate filter scope.
4. `pta_history_page.dart` — pixel match to `ScreenAdminReview` (lines ~269–end). Audit log of decisions + timestamps.
5. Mock data covering all four lists; shared store with citizen + police.

**Acceptance criteria:** Analytics tiles match design (light + dark); approving a device flips status in shared store; admin actions create case_tracking entries; clean analyze; Graphify rebuilt.

**Prompt:**

```
Read CLAUDE.md. Phases 0–5 approved. Starting Phase 6 — PTA Admin Module.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "DeviceRepository", /graphify query "ScreenAdminQueue",
/graphify query "ScreenAdminAnalytics", /graphify query "ScreenAdminReview".
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/chats/chat1.md
2. design/handoff/project/screens-admin.jsx — ScreenAdminQueue, ScreenAdminAnalytics,
   Chart, ScreenAdminReview
3. design/handoff/project/components.jsx — Card, Stat, StatusPill

IMPLEMENTATION:
Replace pta stub. Mock data. Static chart placeholders are fine for Phase 6.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_06_REPORT.md, stop.
```

---

### Phase 7 — Theft Hotspot Map

**Touches:** `lib/features/map/**`.

**Deliverables:**
1. `theft_map_page.dart` — Google Maps with 5–10 mock zones; use `RiskMap` (lines ~245–268 in `screens-admin.jsx`) for the marker/legend visual contract. Risk colors from `AppColors` (`risk.low/medium/high` equivalents).
2. Tap marker → bottom sheet with FIR count + risk level.
3. Legend + recenter button.
4. Map style tuned for both light + dark.

**Acceptance criteria:** Map renders on emulator with placeholder API key (key not committed; setup documented). Markers semantically labelled. Clean analyze. Graphify rebuilt.

**Prompt:**

```
Read CLAUDE.md. Phases 0–6 approved. Starting Phase 7 — Theft Hotspot Map.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md.
Run /graphify query "RiskMap", /graphify query "FIR location",
/graphify explain FirRepository.
Capture in §9.

DESIGN READ ORDER:
1. design/handoff/chats/chat1.md
2. design/handoff/project/screens-admin.jsx — RiskMap

IMPLEMENTATION:
Document Google Maps API key setup in the report; do not commit the key.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_07_REPORT.md, stop.
```

---

### Phase 8 — Polish Pass

**Touches:** widgets and effects across all features. **No** changes to repositories, providers, or routing logic. **No** new screens.

**Deliverables:** skeleton shimmer for all async lists (`shimmer` package — declare in §5 of report); hero animation device card → device details; consistent page transitions (slide + fade); pull-to-refresh on every list; connectivity banner widget (mocked toggle); uniform empty / error states; subtle micro-animations (status badge pulse on `pending`, button press scale).

**Acceptance criteria:** 60 fps scroll on a mid-tier Android emulator; all lists show skeleton on load → empty state on no data; no regression in earlier phases; clean analyze; Graphify post-rebuild shows god nodes unchanged (polish ≠ structural change).

**Prompt:**

```
Read CLAUDE.md. Phases 0–7 approved. Starting Phase 8 — Polish Pass.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note current god nodes — they should NOT change.
Run /graphify query "shared widget", /graphify query "AppCard",
/graphify query "ListView".
Capture in §9.

IMPLEMENTATION:
No new screens. No repository or routing changes. Only animation, skeleton,
transition, refresh, and uniform empty/error states.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste. Confirm god nodes stable.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_08_REPORT.md, stop.
```

---

### Phase 9 — Supabase + FCM Backend Integration

**Touches:** all `data/` layers, `core/network/`, `core/errors/`, new `core/services/supabase_service.dart`, `core/services/fcm_service.dart`, `main.dart`. Provider signatures stay identical.

**Deliverables:** see `docs/MVP Tech Doc.md` and `docs/System Design.md`. Schema, RLS, Edge Functions, FCM token, Realtime subscription, connectivity middleware, Sentry — all per spec.

**Acceptance criteria:** all three demo accounts work end-to-end on real backend; full flow (register device → PTA approve → submit FIR → police verify → block request → PTA approve → device blocked) with push at each transition; RLS verified; no `// MOCK` comments remain; clean analyze; Graphify rebuilt with stable presentation god nodes.

**Prompt:**

```
Read CLAUDE.md. Phases 0–8 approved. Starting Phase 9 — Supabase + FCM Backend.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Every Mock<X>Repository node will be replaced.
Run /graphify query "MockDeviceRepository", "MockFirRepository", "AuthController",
and for each, /graphify explain to surface every caller.
Optionally start /graphify --watch in a separate terminal.
Capture in §9.

IMPLEMENTATION:
Replace every mock with real Supabase. Presentation must not change.
Follow docs/MVP Tech Doc.md and docs/System Design.md exactly.
No secrets committed.

GRAPHIFY POST-IMPLEMENTATION: /graphify ., diff, paste.
Confirm presentation god nodes unchanged.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_09_REPORT.md, stop.
```

---

### Phase 10 — QA, Lint Sweep, Release

**Touches:** test files, lint config, build config, `README.md`.

**Deliverables:** unit tests for use cases / validators (≥ 70 % coverage); widget tests (login, register, device add, FIR submit, case timeline, police review, PTA approval); one integration test (happy path against a Supabase test project); whole-tree lint sweep; app icon + splash final; signed release APK with keystore in CI secrets (documented); `README.md` with setup, env vars, demo credentials, build command, screenshots, **and a "Knowledge graph" section pointing to `graphify-out/GRAPH_REPORT.md`**; demo seed-data script.

**Acceptance criteria:** CI green; zero crash-blockers in happy path; tested on Android 8 + 14; Graphify graph current and committed.

**Prompt:**

```
Read CLAUDE.md. Phases 0–9 approved. Starting Phase 10 — QA, Lint Sweep, Release.

GRAPHIFY PRE-IMPLEMENTATION:
Read GRAPH_REPORT.md. Note all god nodes — referenced from README.md.
Run /graphify query "test", /graphify explain build_runner.
Capture in §9.

IMPLEMENTATION:
Hit coverage. Build signed APK. Update README.md with the "Knowledge graph"
section pointing to graphify-out/GRAPH_REPORT.md.

GRAPHIFY POST-IMPLEMENTATION: final /graphify ., diff, paste.
GATES: → "No issues found!".
REPORT: docs/reports/PHASE_10_REPORT.md, stop.
```

---

## 9. What Claude Code MUST Refuse

Without explicit out-of-band instruction, refuse and point back here:

- Working on a phase not yet authorised.
- Touching files outside the current phase's *Touches* scope.
- Skipping the Graphify pre-implementation read or queries (Section 3.1).
- Skipping the Graphify post-implementation rebuild (Section 3.2).
- Skipping the design read order (Section 7.2) on any UI phase.
- **Calling `WebFetch` on the design URL.** The handoff is local — read `design/handoff/`.
- **Implementing `ScreenKYC` or any KYC/NADRA flow.** Out of scope per Section 4.
- Adding a dependency not in Section 5.
- Real backend calls before Phase 9.
- Hardcoded colors, paddings, durations, or strings outside the constants/theme files.
- Adding a color constant to `lib/theme/colors.dart` that doesn't exist in `design/handoff/project/colors.dart` (Section 7.3).
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
## 3. Files modified
## 4. Files deleted (or fully overwritten from stub)
## 5. New dependencies
## 6. Deviations from CLAUDE.md
## 7. Mock data introduced
## 8. Design fidelity check
- Screen → matches the JSX function in the handoff? (yes / partial — explain)
- Specific JSX file + function referenced
- Light + dark both verified? (yes / no)

## 9. Graphify pre-implementation queries
List every Graphify command run before writing code, with one-sentence findings.
(If zero queries — phase status is **Blocked**.)

## 10. Lint / format / analyze output (paste verbatim)

    $ dart fix --apply
    (no changes)
    $ dart format .
    Formatted N files (0 changed).
    $ flutter analyze
    No issues found! (ran in X.Xs)

If anything other than "No issues found!" — status MUST be Partial or Blocked.

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
## 13. Known issues / debt
## 14. What I touched outside Touches scope (should be empty)
## 15. Ready for auditor?
- [ ] Yes — please review.
```

---

## 11. Audit Loop

```
USER ↦ Claude Code:  "Begin Phase N." (copy the Prompt block from Section 8)
Claude Code:         §3.1 reads + queries → §7.2 design read → implements
                     → §3.2 rebuild → writes PHASE_NN_REPORT.md → stops.
USER ↦ Auditor:      pastes the report (and any concerning code).
Auditor:             ✅ Approve  OR  ✏️ Change list.
  Approve   →  USER ↦ Claude Code: "Begin Phase N+1."
  Changes   →  USER ↦ Claude Code: "Apply these changes to Phase N: <list>.
                                     Re-run §3.2 if code changed.
                                     Update PHASE_NN_REPORT.md and stop."
Repeat.
```

**Auditor rejects on:** scope creep, theme/constants violations, hardcoded literals, dead code, unused imports, missing loading/empty states, design drift from the handoff JSX, missing report sections, missing Graphify §9 or §11, stale `graphify-out/`, new deps without justification, untested validators, KYC code reintroduced, color constants in `lib/theme/colors.dart` not present in the handoff, `flutter analyze` showing anything other than `No issues found!`, or any rule in Sections 1, 2, 3, or 9 broken.

---

## 12. Quick Reference Card

- **Section 1 first:** existing UI is wrong → rebuild from the handoff JSX.
- **Section 2 always:** zero analyzer issues, zero unused imports, zero suppressions.
- **Section 3 every phase:** read GRAPH_REPORT.md and query before coding; rebuild after.
- **Section 7 every UI phase:** read `design/handoff/README.md` + `chats/chat1.md` first; design source is local, not a URL; mirror `colors.dart` exactly.
- **KYC is OUT.** Don't implement `ScreenKYC` at any phase.
- **One phase at a time.** Stop at the report.
- **`theme/colors.dart` mirrors `design/handoff/project/colors.dart`.**
- **`core/widgets/` for anything reused on more than one screen.**
- **Mock until Phase 9. Real from Phase 9.**
- **`flutter analyze` must say `No issues found!` before claiming done.**
- **`graphify-out/` must be current and committed before claiming done.**

---

*End of CLAUDE.md*

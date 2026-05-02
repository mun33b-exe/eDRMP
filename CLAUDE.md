# CLAUDE.md — eDRMP Implementation Playbook

> **Read this entire file before writing a single line of code.**
> This file is the **only** source of truth for the build order and rules.
> The phase ordering in `docs/implementation_phases.md` is **rejected and superseded** by Section 7 of this file. If anything in the user's prompts conflicts with this file, ask — do not improvise.

---

## 0. How This Playbook Works

1. The project is delivered in **11 phases (Phase 0 through Phase 10)**. One phase at a time. Period.
2. Claude Code may **not** start phase N+1 until the user explicitly says *"Begin Phase N+1."*
3. After every phase, Claude Code writes an **Implementation Report** (template in Section 9) to `docs/reports/PHASE_NN_REPORT.md` and **stops**. No "while I'm here let me also fix X."
4. Reports go to a separate auditor (the planning Claude). The auditor returns either:
   - ✅ **Approve** → user authorises the next phase.
   - ✏️ **Change requests** → Claude Code applies them as a fix-up on the *same phase*, regenerates the report, stops.
5. **Designs are authoritative**, not the existing code. See Section 1 below.

---

## 1. Replacement Mandate (READ TWICE)

The current `lib/features/**` tree contains placeholder / non-design-faithful screens. **Treat them as if they don't exist.** Every feature screen must be **rebuilt from scratch** to match the Claude Design handoff.

**Per-phase rule for any file inside that phase's scope:**
- If the file exists with placeholder content → **overwrite it completely**. Don't preserve the old layout, don't keep the old widgets, don't leave commented-out code.
- If the file exists with a useful name but wrong content → keep the filename, replace the body 100%.
- If a file isn't needed → delete it (and report the deletion).

Folder structure is **preserved as-is** (`lib/theme/`, `lib/core/`, `lib/features/<feature>/data|logic|presentation/`). Only file *contents* are scorched.

The Claude Design handoff URL (Section 6) is the visual contract. If a screen Claude Code produces doesn't visually match what's in that handoff, it is wrong and must be redone.

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

**`analysis_options.yaml` (Claude Code creates / verifies in Phase 0):**

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

**Mandatory pre-report sequence** (Claude Code runs all of these and pastes the unedited output into Section 9 of the report):

```bash
dart fix --apply
dart format .
flutter analyze
flutter test  # only from Phase 10 onward
```

If any of those produces output that isn't clean, the phase is **not done** and the report status is `Partial` or `Blocked` — never `Complete`.

---

## 3. Project Snapshot

**Name:** eDRMP — Electronic Device Registration & Monitoring Portal
**Type:** Final Year Project, government-grade citizen + admin app (Pakistan / PTA context)
**Roles:** General User (citizen), Police Admin, PTA Admin
**Core loop:** Register device → Submit FIR → Request block → Track status
**Target:** Android-first MVP, demo-ready signed APK

The build is **UI-first**. Phases 0–8 build the entire app shell with mock/in-memory data. Phase 9 wires Supabase + FCM. Phase 10 hardens and ships. **No backend calls before Phase 9.**

---

## 4. Tech Stack (Locked)

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

**No new dependency without listing it in the report and getting auditor approval.**

---

## 5. Document Hierarchy (Source of Truth)

When in doubt, resolve in this order:

1. **`CLAUDE.md`** (this file) — operational rules and phase plan. Overrides everything else.
2. **Claude Design handoff** (Section 6) — visual contract.
3. **`docs/Architecture.md`** — patterns and layers.
4. **`docs/PRD.md`** — UX intent.
5. **`docs/MVP Tech Doc.md`** — backend plan (active in Phase 9).
6. **`docs/System Design.md`** — sequence diagrams, schemas.
7. **`docs/eDRMP — Design System & Screens.pdf`** — local mirror of the design.
8. **`docs/Software_Requirement_and_Design_Specification_SRDS.pdf`** — academic SRDS, full feature scope.

**`docs/implementation_phases.md` is REJECTED.** Use Section 7 of this file instead.

---

## 6. Design Handoff Protocol

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

## 7. Phase Plan (the only one that matters)

**Why this order beats the rejected plan in `implementation_phases.md`:**
- Phase 0 added: scorch the placeholder UI and lock the foundation (theme + shared widgets + lint config) **before** any feature screen is touched.
- Profile / Settings / Notifications-shell folded into the Citizen Shell phase — they're the same surface area.
- Maps split out of "Polish" into its own phase (Google Maps API + real coords ≠ skeleton shimmer).
- Polish runs **before** Backend Integration so polish lands on stable mock data, not a flaky backend.
- Backend swap is invisible — presentation layer is frozen during Phase 9.

| # | Phase | Headline |
|---|---|---|
| 0 | Scorched Earth + Foundation | Wipe wrong UI, lock theme, ship shared widgets, strict lints |
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

**Goal:** Erase the placeholder UI in `lib/features/**`. Lock the design tokens, lint config, routing skeleton, and shared widget kit. After this phase the app must compile, launch, navigate to placeholder feature pages (each just a centered title), and toggle light/dark.

**Touches (allowed paths):**
- `analysis_options.yaml`
- `pubspec.yaml`
- `lib/main.dart`
- `lib/theme/colors.dart`, `lib/theme/theme.dart`
- `lib/core/constants/*`
- `lib/core/routes/*`
- `lib/core/utils/*`
- `lib/core/widgets/*` (create files here)
- `lib/features/**` — **only** to replace existing screen file contents with a stub `<FeatureName>Page` widget that renders a centered title (so routing works). Real content comes in later phases.

**Deliverables:**
1. `analysis_options.yaml` exactly as specified in Section 2.
2. `theme/colors.dart` — every token from Section 6 declared as `static const Color`. Light + dark groups separated. Comment each group.
3. `theme/theme.dart` — `ThemeData lightTheme` and `ThemeData darkTheme` built from the tokens. Full `TextTheme` covering the 7 type roles. `InputDecorationTheme`, `ElevatedButtonTheme`, `OutlinedButtonTheme`, `TextButtonTheme`, `CardTheme`, `AppBarTheme` all themed for both modes.
4. `core/constants/`:
   - `app_durations.dart` — `static const Duration short = Duration(milliseconds: 200);` etc.
   - `app_padding.dart` — `static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24;`
   - `app_radius.dart` — 6, 9, 11, 14, pill.
   - `app_spacing.dart` — `SizedBox` helpers.
   - `app_strings.dart` — every UI string lives here. No literals in widgets.
5. `core/routes/`:
   - `route_names.dart` — every route as a `static const String`.
   - `app_routes.dart` — `GoRoute` definitions.
   - `app_router.dart` — `GoRouter` with auth-gate redirect (returns `null` for now; Phase 1 fills it in).
6. `core/widgets/` — full shared kit, every widget production-quality:
   - `app_button.dart` — variants: primary, success, reject, ghost, disabled. Loading state.
   - `app_input.dart` — labelled text field, validator, prefix/suffix, error text.
   - `app_password_input.dart` — toggle visibility.
   - `status_badge.dart` — variants: pending, approved, rejected, verified, blocked, active, info.
   - `app_card.dart` — surface card with consistent padding/radius/shadow.
   - `app_loading.dart` — inline + full-screen.
   - `empty_state.dart` — icon + title + body + optional action.
   - `app_app_bar.dart` — themed app bar with back button + actions slot.
   - `app_bottom_sheet.dart` — themed modal bottom sheet.
   - `confirm_dialog.dart` — destructive action confirmation.
7. `lib/features/**/presentation/**.dart` — every existing screen file overwritten with a minimal placeholder:
   ```dart
   class <Name>Page extends StatelessWidget {
     const <Name>Page({super.key});
     @override
     Widget build(BuildContext context) => Scaffold(
       appBar: const AppAppBar(title: '<Name>'),
       body: const Center(child: Text('<Name> — Phase X')),
     );
   }
   ```
   This is intentional — every feature page is just a stub until its phase arrives.
8. `main.dart` — `ProviderScope`, `MaterialApp.router`, `themeMode: ThemeMode.system`, locale `en_US`, `go_router` wired.
9. Splash placeholder that auto-routes to `/login` after 1.2 s.

**Acceptance criteria:**
- `dart fix --apply` produces no changes.
- `dart format .` produces no changes.
- `flutter analyze` → exactly `No issues found!`
- `flutter run` launches without errors on Android emulator.
- Toggling system dark mode flips the theme instantly with no jank.
- Every route name in `route_names.dart` navigates to its stub page.
- No feature page contains real UI — they are all stubs.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md in the repo root. Execute Phase 0 — Scorched Earth + Foundation
exactly as specified in Section 7. The existing UI in lib/features/** is wrong
and must be replaced with stubs as described in Phase 0 Deliverable #7. Do not
preserve any existing widget bodies. Stay strictly inside the Touches scope.
Run dart fix --apply, dart format ., and flutter analyze before declaring done.
flutter analyze must say exactly "No issues found!" — anything else is a fail.
When done, write docs/reports/PHASE_00_REPORT.md per Section 9 and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 1 — Authentication Suite

**Goal:** Build all auth screens pixel-faithful to the design. Mock auth controller, no backend.

**Touches:**
- `lib/features/auth/**`
- `lib/core/routes/app_router.dart` — auth-gate redirect logic
- `lib/core/widgets/**` — only to add a genuinely shared widget that emerged in Phase 0 review

**Replacement note:** the existing `auth/presentation/login_page.dart`, `register_page.dart`, `forgot_password_page.dart`, `splash_page.dart` are stubs from Phase 0. **Overwrite their bodies completely** with the new design-faithful UI.

**Deliverables:**
1. **Splash page** — eDRMP wordmark, 1.2 s artificial delay, redirects based on mock auth state.
2. **Login page** — email + password, "Forgot password?" link, "Don't have an account? Register" link. Light + dark.
3. **Register page** — full name, CNIC (`xxxxx-xxxxxxx-x` format with input mask), email, phone (`+92 3xx xxxxxxx` mask), password, confirm password, terms checkbox.
4. **Forgot password page** — email entry, "Send reset link" CTA, success state.
5. **Mock `AuthController` (Riverpod `AsyncNotifier`)** — `login`, `register`, `forgotPassword`, `logout`, `currentUser`. All async ops use `Future.delayed(const Duration(milliseconds: 400))`. Hard-coded demo accounts:
   ```
   demo.user@edrmp.pk    / Demo@1234  → role: user
   demo.police@edrmp.pk  / Demo@1234  → role: police
   demo.pta@edrmp.pk     / Demo@1234  → role: pta
   ```
6. **Validators** in `core/utils/app_validators.dart`: email, CNIC, Pakistani phone, password strength.
7. **Auth-gate redirect** in `go_router` — unauthenticated → `/login`; authenticated → role-based home.

**Acceptance criteria:**
- All four screens visually match the design system handoff (Citizen — light + dark sections).
- Validation triggers on submit, errors render under the relevant field with humanised text.
- Each demo account routes to its correct shell (user/police/PTA — destinations are still stubs from Phase 0).
- Logout returns to login.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phase 0 is approved. Execute Phase 1 — Authentication Suite.
The auth stub files from Phase 0 must be fully replaced with design-faithful
UI matching the Claude Design handoff. Mock data only. No Supabase calls.
Follow the AuthController spec in CLAUDE.md exactly.
Run dart fix --apply, dart format ., flutter analyze. Must end at "No issues found!".
Write docs/reports/PHASE_01_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 2 — Citizen Shell + Profile / Settings / Notifications

**Goal:** Citizen home shell with bottom nav + FAB, the dashboard hero from the design, plus the profile / settings / notifications-shell pages.

**Touches:**
- `lib/features/dashboard/**`
- `lib/features/profile/**`
- `lib/features/settings/**`
- `lib/features/notifications/**`

**Replacement note:** all existing files in these features are Phase 0 stubs. Replace fully.

**Deliverables:**
1. `app_shell_page.dart` — bottom nav: Home / Devices / [+ FAB] / FIR / Profile (matches the dark+light hero screens). FAB opens a quick-action bottom sheet.
2. `dashboard_page.dart` — greeting (`"Assalam-o-Alaikum, {firstName}"`), notifications icon, profile icon, summary card (REGISTERED DEVICES count + ALL ACTIVE chip + APPROVED / PENDING / FIRS sub-stats), Quick Actions grid (Register device, Report FIR, Transfer, Verify IMEI), "My devices" preview list (max 2, "See all" link).
3. `profile_page.dart` — read-only profile (name, masked CNIC, email, phone, role badge, member-since), Sign out button.
4. `settings_page.dart` — language (English locked for MVP), theme (System/Light/Dark with proper UI), notifications toggle (UI only), about, version.
5. `notifications_page.dart` — empty-state shell ("You're all caught up").
6. `dashboardMockProvider` (Riverpod) — 3 devices, 2 approved, 1 pending, 0 FIRs.

**Acceptance criteria:**
- Bottom nav navigates correctly; selected tab visually distinct per the design.
- Light + dark both match the design.
- Greeting reads from `currentUser` provider.
- "See all" navigates to the Phase 3 stub.
- Theme switcher in settings actually flips themes.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-1 approved. Execute Phase 2 — Citizen Shell +
Profile/Settings/Notifications. Replace all stub files in these features
fully. Mock data only. Match the Citizen — dark home hero and the light variant.
Run dart fix --apply, dart format ., flutter analyze. End at "No issues found!".
Write docs/reports/PHASE_02_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 3 — Citizen Devices Module

**Goal:** Full device-registration UX with real client-side IMEI Luhn validation.

**Touches:**
- `lib/features/devices/**`
- `lib/core/utils/app_validators.dart` (final IMEI Luhn)

**Deliverables:**
1. `my_devices_page.dart` — list of devices, each card: device icon, brand+model, masked IMEI (`356938 09 *** 7`), registration date, network operator, status badge. Filter chips (All / Active / Pending / Blocked). Empty state.
2. `add_device_page.dart` — multi-step form: Step 1 IMEI entry + auto-fill brand/model (mock dictionary lookup), Step 2 confirm details, Step 3 success. Inline Luhn validation. "Continue" disabled until valid.
3. `device_details_page.dart` — full device record, IMEI in mono font, status timeline (registered → pending → approved), action button "Report FIR" (only enabled when status `approved`).
4. Real Luhn validator in `app_validators.dart`.
5. Mock `DeviceRepository` with in-memory list + 400 ms delays.
6. Auto-fill brand/model dictionary covering at least: Apple iPhone 15 Pro, Samsung Galaxy S24, Xiaomi Redmi Note 13.

**Acceptance criteria:**
- Adding a duplicate IMEI shows a duplicate-error dialog.
- Adding a valid IMEI walks through 3 steps and lands on `my_devices` with the new card on top.
- Status badges colored from the domain-status tokens.
- All async ops have loading + error states.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-2 approved. Execute Phase 3 — Citizen Devices Module.
Replace all stub device files. Mock data only. Real Luhn validation now.
Match the device-related screens in the design.
End at "No issues found!". Write docs/reports/PHASE_03_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 4 — Citizen FIR + Case Tracking

**Goal:** Citizen FIR submission, history, and case tracking timeline.

**Touches:**
- `lib/features/fir/**`
- `lib/core/widgets/**` — only if a generic timeline widget emerges

**Deliverables:**
1. `submit_fir_page.dart` — form: select device (only `approved` devices), FIR number, police station, FIR date (date picker), description (multiline), proof upload (placeholder picker — real upload Phase 9), location capture (map picker placeholder — real map Phase 7). Sticky bottom Submit.
2. `fir_history_page.dart` — list of FIRs with status badges (Pending / Verified / Rejected). Tappable → case tracking.
3. `case_tracking_page.dart` — vertical stepper timeline using the State Dynamics diagram (Section 5.5 of the SRDS PDF) as the canonical state list: Device Registered → FIR Submitted → FIR Under Review → FIR Verified/Rejected → Block Pending → Block Approved/Rejected → Device Blocked / Recovered. Each step: icon, title, timestamp, optional note. Past = solid, current = highlighted, future = muted.
4. Mock `FirRepository` + `CaseStatusRepository` with 2 seeded FIRs across statuses to demonstrate the timeline.

**Acceptance criteria:**
- Submitting a FIR adds it to history with `Pending` status.
- Timeline correctly renders past / current / future states.
- Empty state when no FIRs.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-3 approved. Execute Phase 4 — Citizen FIR +
Case Tracking. Replace all stub FIR files. Mock data only. Use the State
Dynamics diagram in the SRDS PDF as the canonical state list.
End at "No issues found!". Write docs/reports/PHASE_04_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 5 — Police Admin Module

**Goal:** Police admin dashboard + FIR queue + verify/reject action.

**Touches:**
- `lib/features/police/**`

**Deliverables:**
1. `police_dashboard_page.dart` — summary tiles (Pending / Verified Today / Rejected Today), CTA "Open Pending Queue".
2. `pending_fir_queue_page.dart` — list of FIRs needing verification, sorted desc, filter chips (All / Pending / Verified / Rejected).
3. `fir_review_page.dart` — full FIR detail, citizen info, attached proof (placeholder viewer), Verify / Reject sticky bottom CTA pair. Reject must capture a reason. Both actions show a confirmation dialog (`confirm_dialog.dart` from Phase 0).
4. Police-side mock data: 5 FIRs (3 pending, 1 verified, 1 rejected).

**Acceptance criteria:**
- Verifying a FIR updates its status and removes it from the pending queue.
- Rejecting requires a non-empty reason; reason persists in the case timeline (shared mock store with Phase 4).
- Lists use the `Approval queue` typography spec.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-4 approved. Execute Phase 5 — Police Admin Module.
Replace police stub. Mock data only. Match police screens. Confirmation
dialog required for both verify and reject.
End at "No issues found!". Write docs/reports/PHASE_05_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 6 — PTA Admin Module

**Goal:** PTA admin dashboard + device approvals + block-request approvals + audit log.

**Touches:**
- `lib/features/pta/**`

**Deliverables:**
1. `pta_dashboard_page.dart` — analytics tiles (Total devices, Approvals, Active FIRs, Blocked) per the Analytics screen in the design. Static placeholder numbers/charts.
2. `device_approvals_page.dart` — list of pending device registrations, approve/reject with confirmation.
3. `block_requests_page.dart` — list of pending block requests, approve/reject with confirmation. Reject captures reason.
4. `pta_history_page.dart` — audit log of all PTA decisions with timestamps.
5. Mock data covering all four lists; shared store with citizen-side so approvals reflect there.

**Acceptance criteria:**
- Analytics tiles match the design (light + dark).
- Approving a device flips its status in the shared mock store; citizen `my_devices` reflects it.
- All admin actions create case_tracking audit entries.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-5 approved. Execute Phase 6 — PTA Admin Module.
Replace pta stub. Mock data only. Match the Analytics light + dark
screens for the dashboard.
End at "No issues found!". Write docs/reports/PHASE_06_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 7 — Theft Hotspot Map

**Goal:** UI-only map with mock theft zones.

**Touches:**
- `lib/features/map/**`

**Deliverables:**
1. `theft_map_page.dart` — `google_maps_flutter` with 5–10 mock theft zones (markers + colored circles by risk: low/medium/high).
2. Tap marker → bottom sheet with FIR count + risk level.
3. Legend + recenter button.
4. Map style tuned for both light + dark mode.

**Acceptance criteria:**
- Map renders on a real device / emulator with the placeholder API key configuration documented in the report (key not committed).
- Markers are accessible (semantic labels).
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-6 approved. Execute Phase 7 — Theft Hotspot Map.
Document the Google Maps API key setup in the report without committing the key.
End at "No issues found!". Write docs/reports/PHASE_07_REPORT.md and stop.

Design reference: https://api.anthropic.com/v1/design/h/JJg-PlJiNm5iCJzi5GqmjA?open_file=eDRMP+Design+System.html
```

---

### Phase 8 — Polish Pass

**Goal:** Apply animation, skeleton, and interaction polish across every existing screen. Visual lift only — no new features.

**Touches:** widgets and effects across all features. **No** changes to repositories, providers, or routing logic. **No** new screens.

**Deliverables:**
1. Skeleton shimmer for all async lists (use `shimmer` package, document if added).
2. Hero animation on device cards → device details.
3. Page transitions consistent across the app (slide + fade).
4. Pull-to-refresh on every list view.
5. Connectivity banner widget (offline indicator, mocked toggle for now).
6. Empty / error states uniform across features.
7. Subtle micro-animations (status badge pulse on `pending`, button press scale).

**Acceptance criteria:**
- 60 fps scroll on a mid-tier Android emulator.
- All lists show skeleton on load → empty state on no data.
- No regression in earlier phases — every prior screen still passes its own acceptance criteria.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-7 approved. Execute Phase 8 — Polish Pass.
No new screens. No repository or routing changes. Only animation, skeleton,
transition, refresh, and uniform empty/error state work.
End at "No issues found!". Write docs/reports/PHASE_08_REPORT.md and stop.
```

---

### Phase 9 — Supabase + FCM Backend Integration

**Goal:** Replace every mock with real Supabase + FCM. Presentation layer is **frozen** — UI must not visibly change.

**Touches:** all `data/` layers in every feature, `core/network/`, `core/errors/`, new `core/services/supabase_service.dart`, `core/services/fcm_service.dart`, `main.dart`. Provider signatures stay identical so widgets don't change.

**Deliverables (per `docs/MVP Tech Doc.md` and `docs/System Design.md`):**
1. Supabase project initialised (dev + prod), env via `--dart-define`.
2. Schema deployed: `profiles`, `devices`, `firs`, `block_requests`, `case_status_log`, `notifications`, `theft_zones`. RLS for each.
3. `supabase_flutter` initialised in `main.dart`.
4. Real `AuthRepository` replacing mock — signup, login, logout, session restore, role from `profiles`.
5. Real `DeviceRepository`, `FirRepository`, `BlockRepository`, `CaseStatusRepository`, `NotificationRepository` — same public interfaces as mocks.
6. Supabase Storage bucket `fir-documents` configured. Real upload with retry (3 attempts, exponential backoff).
7. Firebase initialised. FCM token saved to `profiles.fcm_token` on login. Foreground + background handlers.
8. Edge Function (or DB trigger) pushing notifications on FIR status change and block status change.
9. Realtime subscription on `case_status_log` filtered by current user — pushes into the existing `caseStatusProvider`.
10. Connectivity middleware around all repositories — surfaces `NoConnectionFailure` properly.
11. Sentry initialised.

**Acceptance criteria:**
- All three demo accounts work end-to-end on real backend.
- Full flow: register device → PTA approves → submit FIR → police verifies → request block → PTA approves → device shows blocked. Push notifications fire at each transition.
- RLS verified: a user cannot read another user's devices/FIRs.
- No `// MOCK` comments remain.
- `flutter analyze` → `No issues found!`

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-8 approved. Execute Phase 9 — Supabase + FCM
Backend Integration. Replace every mock with real Supabase implementations.
Presentation layer must not change. Follow docs/MVP Tech Doc.md and
docs/System Design.md exactly for schema, RLS, and Edge Functions.
Document Supabase project URL and bucket setup in the report. No secrets
committed. End at "No issues found!".
Write docs/reports/PHASE_09_REPORT.md and stop.
```

---

### Phase 10 — QA, Lint Sweep, Release

**Goal:** Production-ready signed APK.

**Touches:** test files, lint config, build config, `README.md`.

**Deliverables:**
1. Unit tests for all use cases / validators (≥ 70 % coverage).
2. Widget tests: login, register, device add, FIR submit, case timeline, police review, PTA approval.
3. One integration test running the happy path end-to-end against a Supabase test project.
4. Whole-tree lint sweep — `flutter analyze` clean, `dart format .` applied, `dart fix --apply` no-op.
5. App icon + splash screen finalised.
6. Signed release APK built; keystore in CI secrets, documented.
7. `README.md` with setup, env vars, demo credentials, build command, screenshots.
8. Demo seed-data script committed.

**Acceptance criteria:**
- CI pipeline (GitHub Actions) green.
- Zero crash-blocking bugs in the happy path.
- Tested on Android 8 + Android 14.

**Prompt to send to Claude Code:**

```
Read CLAUDE.md. Phases 0-9 approved. Execute Phase 10 — QA, Lint Sweep, Release.
Hit coverage targets. Build signed release APK. Update README.md.
End at "No issues found!". Write docs/reports/PHASE_10_REPORT.md and stop.
```

---

## 8. What Claude Code MUST Refuse

Without explicit out-of-band instruction, refuse and point back here:

- Working on a phase not yet authorised.
- Touching files outside the current phase's *Touches* scope.
- Adding a dependency not in Section 4.
- Real backend calls before Phase 9.
- Hardcoded colors, paddings, durations, or strings outside the constants/theme files.
- Suppressing a lint with `// ignore:` or `ignore_for_file:`.
- Skipping `dart fix --apply` / `dart format .` / `flutter analyze` before declaring done.
- Skipping the Implementation Report.
- Committing secrets, API keys, or `.env` files.
- Declaring a phase complete when `flutter analyze` shows anything other than `No issues found!`.

---

## 9. Implementation Report Format

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

## 9. Lint / format / analyze output (paste verbatim)

    $ dart fix --apply
    (no changes)

    $ dart format .
    Formatted N files (0 changed).

    $ flutter analyze
    Analyzing project...
    No issues found! (ran in X.Xs)

If anything other than "No issues found!" appears here, status above MUST be Partial or Blocked.

## 10. Manual test log
- Step-by-step what you ran and what happened. Screenshots if possible.

## 11. Known issues / debt
- List anything intentionally deferred. Each item references a future phase.

## 12. What I touched outside Touches scope (should be empty)
- If non-empty, explain why and ask the auditor to bless it.

## 13. Ready for auditor?
- [ ] Yes — please review.
```

---

## 10. Audit Loop

```
USER ↦ Claude Code:  "Begin Phase N." (copy the Prompt block from Section 7)
Claude Code:         implements + writes PHASE_NN_REPORT.md, stops.
USER ↦ Auditor:      pastes the report (and any concerning code).
Auditor:             returns ✅ Approve  OR  ✏️ Change list.
  Approve   →  USER ↦ Claude Code: "Begin Phase N+1."
  Changes   →  USER ↦ Claude Code: "Apply these changes to Phase N: <list>.
                                     Update PHASE_NN_REPORT.md and stop."
Repeat.
```

**Auditor rejects on:** scope creep, theme/constants violations, hardcoded literals, dead code, unused imports, missing loading/empty states, design drift from the handoff, missing report sections, new deps without justification, untested validators, `flutter analyze` showing anything other than `No issues found!`, or any rule in Sections 1, 2, or 8 broken.

---

## 11. Quick Reference Card

- **Section 1 first:** existing UI is wrong → rebuild from the design handoff.
- **Section 2 always:** zero analyzer issues, zero unused imports, zero suppressions.
- **One phase at a time.** Stop at the report.
- **`theme/colors.dart` + `core/constants/*` are the only sources of style atoms.**
- **`core/widgets/` for anything reused on more than one screen.**
- **Mock until Phase 9. Real from Phase 9.**
- **`flutter analyze` must say `No issues found!` before claiming done.**

---

*End of CLAUDE.md*

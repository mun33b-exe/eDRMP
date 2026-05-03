# Design.md — eDRMP Flutter App Design Optimization Playbook
## For Claude Opus 4.7 — Frontend Design Visualization Guide

> **Read this ENTIRE file before visualizing a single screen.**  
> This document is the **authoritative design contract** for all eDRMP UI phases (0–8).  
> Design decisions in this file SUPERSEDE any existing placeholder code in `lib/features/`.  
> If a prompt conflicts with this guide, ask for clarification — do NOT improvise.

---

## 1. Project Context & Design Philosophy

### 1.1 Project Overview: eDRMP
**eDRMP** (e-Device Registration & Management Platform) is a sophisticated Flutter application designed for critical infrastructure device management across three distinct user roles:

- **Users**: Register their devices, submit First Information Reports (FIRs) for theft/loss, and track device status.
- **Police Officers**: Review FIR submissions, verify device information, and update case status.
- **PTA Officials**: Approve finalized cases and manage system-level device data.

**Target Audience**: Pakistani citizens, law enforcement, telecommunications authority officials.

**Device Target**: Android 8 → 14 (primary), responsive typography and layouts.

**Core User Flows**:
1. Device Registration → Device verification → IMEI validation
2. FIR Submission → Police review → PTA approval → Case closure
3. Device tracking dashboard with real-time status updates
4. Role-based access with permission gates

### 1.2 Design Philosophy: Clarity + Authority + Trustworthiness

eDRMP is **NOT a consumer app**. It is a **regulated, mission-critical system** used in a legal/governmental context. Design must reflect:

- **Clarity**: Every screen must communicate its purpose in < 2 seconds. No ambiguity.
- **Authority**: Professional, formal, confident. Users trust this with their device registration and legal filings.
- **Accessibility**: High contrast, readable fonts at small sizes, clear CTAs (call-to-action buttons).
- **Efficiency**: Users are under time pressure (filing FIRs, processing approvals). Minimize cognitive load.
- **Legitimacy**: Government workflows require documented audit trails. Design must hint at this seriousness.

**Aesthetic Direction**: 
- **NOT playful**, **NOT trendy**, **NOT minimalist-to-the-point-of-confusion**.
- **IS professional**, **IS functional**, **IS reassuring**, **IS modern but grounded**.
- Think: **Modern Government Digital Service** (UK GOV.UK aesthetic meets contemporary app design) OR **Insurance/Banking App** (clean, secure, trustworthy).

---

## 2. Core Design System

### 2.1 Color Palette

Your app MUST adhere to this color system. Every color used in `lib/theme/colors.dart` must be derived from or justified against this palette.

#### Primary Colors
```
Primary Brand Blue (Trust & Authority):
  Light: #0066CC (AppBar, primary buttons, active states)
  Dark: #004BA3 (Pressed state, darker mode primary)
  Accent: #1D7FD6 (Slightly softer for secondary highlights)

Secondary Green (Success & Verification):
  Light: #10B981 (Approval states, checkmarks, "verified" badges)
  Darker: #059669 (Pressed state, darker backgrounds)

Alert Red (Warnings & Rejections):
  Light: #EF4444 (Errors, warnings, rejection states)
  Darker: #DC2626 (Pressed state)

Warning Orange (Pending & In-Progress):
  Light: #F97316 (Pending status, in-progress indicators)
  Darker: #EA580C (Pressed state)

Neutral Gray (UI Foundation):
  Light Background: #F9FAFB (Page backgrounds, light surfaces)
  Card Background: #FFFFFF (Cards, elevated surfaces)
  Text Primary: #111827 (Body text, primary labels)
  Text Secondary: #6B7280 (Secondary labels, hints, timestamps)
  Text Tertiary: #9CA3AF (Disabled states, very light labels)
  Border: #E5E7EB (Subtle dividers, input borders)
  Border Strong: #D1D5DB (More prominent borders, focused inputs)
```

#### Dark Mode Palette
```
Dark Background Primary: #0F172A (Page background)
Dark Surface: #1E293B (Cards, elevated surfaces)
Dark Surface Elevated: #334155 (Higher elevation)
Text on Dark Primary: #F1F5F9 (Primary text)
Text on Dark Secondary: #CBD5E1 (Secondary text)
Border on Dark: #475569 (Subtle dividers)
```

**Rule**: Every `Color(0xFF...)` in your Flutter code is a RED FLAG. Use `AppColors.primary`, `AppColors.success`, etc. from `lib/theme/colors.dart`.

### 2.2 Typography System

#### Font Families
- **Display Font (Headlines)**: `Poppins` (Bold, confident, modern, used for H1/H2)
- **Body Font (Copy)**: `Roboto` (Professional, highly legible, used for body text, labels)
- **Monospace (Data)**: `RobotoMono` (For IMEI display, case IDs, timestamps)

#### Type Scale
```
H1 (32px, Poppins Bold, line-height 1.25):
  Used: Page titles (Dashboard, Device Registration)
  Example: "My Devices" | "Submit First Information Report"

H2 (24px, Poppins SemiBold, line-height 1.35):
  Used: Section headers, dialog titles
  Example: "Device Information" | "Verify IMEI"

H3 (20px, Poppins SemiBold, line-height 1.4):
  Used: Card titles, form section headers
  Example: "Device Details" | "Your Case Status"

Body Large (16px, Roboto Regular, line-height 1.5):
  Used: Primary body text, CTAs
  Example: Button text, form labels

Body Regular (14px, Roboto Regular, line-height 1.5):
  Used: Secondary body text, descriptions
  Example: Help text, timestamps, status labels

Body Small (12px, Roboto Regular, line-height 1.4):
  Used: Tertiary labels, badges, very small UI text
  Example: "Verified on Mar 15, 2025" | Error hints

Label (13px, Poppins SemiBold, line-height 1.4):
  Used: Button text (when caps are needed)
  Example: "SUBMIT REPORT" | "VERIFY IMEI"

Monospace Data (14px, RobotoMono Regular, line-height 1.5):
  Used: IMEI, case IDs, reference numbers
  Example: "35 989300 000000 0" (IMEI display)
```

**Rule**: All text must be defined in `lib/theme/text_styles.dart`. No `TextStyle()` literals in widget code.

### 2.3 Spacing & Layout System

**Base Unit**: 4px

```
xs:  4px   (tight spacing, small padding)
sm:  8px   (button padding, small gaps)
md:  16px  (standard padding, form spacing)
lg:  24px  (section spacing, large gaps)
xl:  32px  (page-level spacing, major sections)
xxl: 48px  (very large gaps, rarely used)
```

**Container Padding**:
- Pages: 16px (md) left/right, 24px (lg) top/bottom
- Cards: 16px (md) all sides
- Forms: 16px (md) between fields

**Border Radius**:
- Default (cards, inputs, small elements): 8px
- Large (dialog backgrounds, large cards): 16px
- Buttons: 8px (rectangular buttons), 12px (larger buttons)
- Chips/Badges: 16px (fully rounded)

### 2.4 Shadows & Elevation

```
Elevation 1 (Cards, light lift):
  shadowColor: Colors.black.withOpacity(0.12)
  blurRadius: 2
  offset: Offset(0, 1)
  spreadRadius: 0

Elevation 2 (Modal surfaces, medium lift):
  shadowColor: Colors.black.withOpacity(0.15)
  blurRadius: 8
  offset: Offset(0, 4)
  spreadRadius: 0

Elevation 3 (Modals, dialogs, strong lift):
  shadowColor: Colors.black.withOpacity(0.2)
  blurRadius: 16
  offset: Offset(0, 8)
  spreadRadius: 0
```

### 2.5 Component Library (Reusable Widgets)

All components must be built in `lib/core/widgets/` and follow this structure:

#### Button Component Spec
```
Standard Button (Primary CTA):
  - Height: 48px
  - Padding: 16px (sm) horizontal
  - Text: Body Large, Poppins SemiBold, #FFFFFF on #0066CC
  - Border Radius: 8px
  - Pressed State: background → #004BA3, slight scale down (95%)
  - Disabled State: opacity 0.5, cursor disabled
  - Elevation: none (flat), shadow on press

Secondary Button:
  - Height: 48px
  - Border: 1.5px #D1D5DB
  - Text: Body Large, #111827
  - Pressed: Border → #0066CC, text → #0066CC
  - No fill

Small Button:
  - Height: 36px
  - Padding: 8px (sm) horizontal
  - Text: Body Regular (14px)
  - Used: form resets, small CTAs
```

#### Input Field Component Spec
```
Text Input:
  - Height: 48px
  - Padding: 12px horizontal, 16px vertical
  - Border: 1px #E5E7EB (unfocused), #0066CC (focused)
  - Border Radius: 8px
  - Placeholder: Body Regular, #9CA3AF
  - Focus: outline none, border → #0066CC, shadow subtle
  - Error State: border → #EF4444, error text below (Body Small, red)

Dropdown/Selector:
  - Height: 48px
  - Icon: 20x20px on right side
  - Focused border like text input
  - Chevron points down (unfocused), up (focused)
```

#### Card Component Spec
```
Default Card:
  - Background: #FFFFFF (light mode), #1E293B (dark mode)
  - Padding: 16px
  - Border Radius: 8px
  - Shadow: Elevation 1
  - Divider (if multi-section): 1px #E5E7EB

Status Card (Device, Case Status):
  - Card base + status badge (top-right or inline)
  - Badge colors: green (#10B981) for verified, orange (#F97316) for pending, red (#EF4444) for rejected
```

#### Badge/Tag Component Spec
```
Status Badge:
  - Padding: 4px horizontal, 6px vertical
  - Font: Body Small, SemiBold, white text
  - Border Radius: 12px
  - Background: color per status
    - Verified: #10B981
    - Pending: #F97316
    - Rejected: #EF4444
    - Neutral: #6B7280
```

#### Dialog Component Spec
```
Modal Dialog:
  - Background: #FFFFFF (light), #1E293B (dark)
  - Border Radius: 16px
  - Padding: 24px (lg)
  - Shadow: Elevation 3
  - Backdrop: semi-transparent black (0.5 opacity)
  - Close button: top-right, X icon (20x20px)
  - Title: H2, 24px
  - Content: Body Regular, 16px
  - Actions (buttons): stacked or side-by-side (if space allows)
```

---

## 3. Screen-by-Screen Design Spec

### 3.1 Onboarding & Authentication Flow

#### Screen: Splash Screen (0–2 seconds)
**Purpose**: App launch, brand acknowledgment, very brief.

**Design**:
- Full-screen background: Brand blue (#0066CC) gradient to navy (#004BA3), diagonal (top-left to bottom-right).
- Center: eDRMP logo (if available) OR large text "eDRMP" (Poppins Bold, 48px, white).
- Bottom: "Device Registration & Management Platform" (Body Small, white, opacity 0.8).
- No buttons, no interaction. Auto-transitions to Welcome screen after 2s.

**Dark Mode**: Same, but background is slate-to-dark-blue.

---

#### Screen: Welcome / Sign In Screen
**Purpose**: Entry point. Communicate the app's purpose and offer sign-in/register options.

**Design**:
- Top section (40% height): Hero image or gradient (Brand blue to accent, diagonal).
- Top overlay: eDRMP logo (40x40px), white.
- Center section: 
  - H1: "Welcome to eDRMP" (Poppins Bold, 32px, #111827 light / #F1F5F9 dark).
  - Body Regular: "Manage your device registration and report theft or loss securely." (14px, #6B7280 light / #CBD5E1 dark).
- Bottom section (buttons & links):
  - Primary CTA Button: "Sign In" (48px height, blue background, white text).
  - Secondary CTA Button: "Create Account" (48px height, outlined, blue border/text).
  - Forgot password link: "Forgot password?" (Body Small, blue, underline on hover).

**Interactions**:
- Buttons: slight scale on press (95%), smooth color transition.
- Links: underline appears on hover.

**Dark Mode**: Backgrounds invert, text colors adapt (white → light gray).

---

#### Screen: Sign In / Register Forms
**Purpose**: Credential entry. Must feel secure and clear.

**Design**:
- AppBar: "Sign In" (H2) / "Create Account" (H2), center-aligned.
- Back button (if not first screen): chevron left, top-left, 24x24px.
- Form fields (stacked, 16px gap):
  - Email input (placeholder: "you@example.com").
  - Password input (placeholder: "••••••••", toggle show/hide icon on right).
  - For register: name, phone, password confirmation, terms checkbox.
- Labels: "Email" (Body Small, SemiBold, #111827 light / #F1F5F9 dark), directly above input.
- Error states: red border (#EF4444) + error message below (Body Small, red).
- Validation feedback: green checkmark (Body Small, green) on valid fields (optional).
- Primary CTA: "Sign In" / "Create Account" (48px button, full width).
- Footer: "Don't have an account?" (Body Small) + "Sign Up" (blue link).

**Accessibility**:
- All inputs labeled (label text, not placeholder-only).
- Clear focus indicators (border + shadow).
- Error messages linked to inputs via accessibility.

**Dark Mode**: Invert backgrounds, text colors. Same structure.

---

### 3.2 Main Navigation & Dashboard

#### Screen: Bottom Navigation / App Structure
**Purpose**: Primary navigation for all authenticated users.

**Design**:
- Bottom Navigation Bar (height: 56px, safe area bottom padding):
  - Background: #FFFFFF (light) / #1E293B (dark).
  - Divider: 1px #E5E7EB (light) / #475569 (dark) at top.
  - 4 tabs (User role-dependent visibility):
    1. **Dashboard** (home icon): default active on app launch.
    2. **Devices** (device icon): device list/management.
    3. **Cases** (briefcase icon): FIRs and case tracking.
    4. **Account** (user icon): profile, settings, logout.
  - Icon size: 24x24px.
  - Label: Body Small (12px) below icon.
  - Active tab: icon + label → brand blue (#0066CC), background white/translucent.
  - Inactive: icon + label → gray (#6B7280).
  - Transitions: smooth color changes on tab switch.

**AppBar** (consistent across all screens):
- Height: 56px (standard).
- Background: #FFFFFF (light) / #1E293B (dark).
- Content: Title (H2 or H3, left-aligned) + optional right action (icon button, notifications, menu).
- Divider: 1px #E5E7EB (light) / #475569 (dark) at bottom.
- Status bar: Light icons on blue for light theme, light icons on dark for dark theme.

---

#### Screen: User Dashboard
**Purpose**: Overview of user's device status, recent activities, quick actions.

**Design**:

**Header Section** (24px padding, lg):
- H1: "Dashboard" (Poppins Bold, 32px).
- Subheader: "Hi, [User Name]" (Body Regular, #6B7280).
- Date/time: Optional, light gray.

**Quick Stats Cards** (horizontal scroll, 3 cards, 16px gap, md padding each card):
- Card 1: "Active Devices" with count (e.g., "3"), small bar chart icon.
- Card 2: "Pending Cases" with count (e.g., "1"), briefcase icon.
- Card 3: "Verified Devices" with count (e.g., "2"), checkmark icon.
- Card styling: 80x100px, center-aligned content, light blue background (#EBF5FF), blue text (#0066CC).

**Recent Activity Section** (16px padding):
- H3: "Recent Activity" (Poppins SemiBold, 20px).
- List of 5 recent events (reverse chronological):
  - Each item: 48px height, card-like with small left border (brand blue, 4px).
  - Content: Activity description (Body Regular, 14px) + timestamp (Body Small, gray) + status badge (green/orange/red).
  - Example: "Device XYZ verified" (Mar 15, 2025, 10:30 AM) [Verified].
  - Clickable: navigates to device detail or case detail.

**Call-to-Action Section** (16px padding):
- Primary CTA: "Register New Device" (full-width button, 48px).
- Secondary CTA: "Submit Device Report" (full-width button, outlined).

**Spacing**: 24px (lg) between sections.

---

#### Screen: Police Officer Dashboard
**Purpose**: Overview of FIRs to review, cases in progress, action items.

**Design**:

**Header**:
- H1: "Incoming Reports" (Poppins Bold, 32px).
- Subheader: "Review and verify device registrations" (Body Regular, 14px, gray).

**Filter/Search Bar** (16px padding, md gap):
- Search input: "Search by IMEI, case ID, or user name" (placeholder).
- Filter button: Dropdown for status (All / Pending / Verified / Rejected).
- Sort button: By date (newest first), priority, or user name.

**FIR List** (16px padding, md gap between items):
- Each FIR card (16px padding, md):
  - Header: Case ID (MonoSpace, 13px, blue, clickable), status badge (orange/green/red), timestamp (Body Small, gray).
  - Content: Device IMEI (MonoSpace, 14px), user name (Body Regular, 14px), reason for FIR (theft/loss, Body Small, gray).
  - Footer: "Review" button (small secondary button, 36px height) on right.
  - Divider: 1px #E5E7EB between cards (or card elevation shadows instead).
  - Hover state: slight background color change, pointer cursor.

**Empty state** (if no FIRs):
- Illustration (optional, 100x100px) or icon (briefcase, 48px, gray).
- Text: "No pending reports" (H3, gray).
- Subtext: "All reports have been reviewed." (Body Regular, gray).

---

#### Screen: PTA Dashboard
**Purpose**: Overview of finalized cases ready for approval, approval history.

**Design**:

**Header**:
- H1: "Approval Queue" (Poppins Bold, 32px).
- Subheader: "Review and approve device registrations" (Body Regular, 14px, gray).
- Chip: Badge showing count ("5 Pending Approval").

**Approval Cards** (16px padding, md gap):
- Large cards (similar to FIR cards but slightly expanded):
  - Status: "PENDING APPROVAL" badge (orange, #F97316).
  - Case ID (MonoSpace, blue, clickable).
  - User info: Name, district/region (Body Regular, 14px).
  - Device info: IMEI (MonoSpace), model, make (Body Small, gray).
  - Police notes: Brief summary (Body Regular, 12px, light gray, italic).
  - Action buttons: "Approve" (green button, 36px height) + "Reject" (red outlined button, 36px height).

**Approval History Section** (if space allows):
- H3: "Recent Approvals" (Poppins SemiBold, 20px).
- Timeline-like list showing approved cases (date, case ID, user, approve timestamp).

**Dark Mode**: Same structure, invert colors.

---

### 3.3 Device Management Flow

#### Screen: Device List
**Purpose**: User's list of registered devices.

**Design**:

**Header**:
- H1: "My Devices" (Poppins Bold, 32px).
- Subheader: "Manage and track your registered devices" (Body Regular, 14px, gray).

**Devices Grid/List** (16px padding, md gap):
- List view (default) or grid toggle (optional button, top-right):
  - Card layout (per device): 160px height, 16px padding, md:
    - Top: Device icon (phone/tablet, 32x32px, brand blue).
    - Model: "iPhone 13 Pro" (Body Large, 16px, SemiBold).
    - IMEI: "359893..." (MonoSpace, 12px, gray, truncated or expandable).
    - Status badge: Green (Verified), Orange (Pending), Red (Blocked).
    - Metadata: Last verified date, registration date (Body Small, gray).
    - Tap/click: expands to detail view or navigates to device detail screen.

**Add Device Button**:
- Floating Action Button (FAB) OR full-width button below list.
- "Add New Device" (48px height, primary blue).

**Empty State**:
- Illustration or icon (phone, 64x64px, light gray).
- "No devices registered yet" (H3, gray).
- CTA: "Register Your First Device" (button).

---

#### Screen: Device Registration Form
**Purpose**: Multi-step form for registering a new device.

**Design**:

**Step Indicator** (top, optional but recommended):
- Horizontal progress bar or numbered steps (1/3, 2/3, 3/3).
- Step 1: Device Information, Step 2: IMEI Verification, Step 3: Confirmation.

**Step 1: Device Information**:
- H2: "Device Information" (Poppins SemiBold, 24px).
- Form fields (16px gap):
  - Device type: Dropdown (smartphone, tablet).
  - Brand: Dropdown (Apple, Samsung, etc.).
  - Model: Text input (auto-complete optional).
  - Color: Dropdown (black, white, blue, etc.).
  - Purchase date: Date picker.
  - Serial number: Text input (optional).
- CTA: "Next" (primary button, 48px, full-width).

**Step 2: IMEI Verification**:
- H2: "IMEI Verification" (Poppins SemiBold, 24px).
- Instructions: "Enter your device's IMEI to verify ownership." (Body Regular, light gray).
- IMEI input: Large text input, monospace font, allows hyphenation formatting (e.g., "35-989300-000000-0").
- Verification button: "Verify IMEI" (primary button, 48px, full-width).
- Verification result (post-submit):
  - Success: Green checkmark + "IMEI verified successfully" (Body Regular, green).
  - Failure: Red X + error message (Body Regular, red) + retry link.

**Step 3: Confirmation**:
- H2: "Review & Confirm" (Poppins SemiBold, 24px).
- Summary card: Display device info collected (read-only, light gray background).
- Checkbox: "I confirm the information is accurate" (required).
- Terms link: "Terms of Service" (blue link, opens modal).
- CTA: "Register Device" (primary button, 48px, full-width).
- Fallback: "Back" (secondary button, full-width).

**Success Screen** (post-registration):
- Large green checkmark icon (64x64px).
- H2: "Device Registered Successfully" (Poppins SemiBold, 24px).
- Body: "Your device is now registered and will be verified within 24 hours." (Body Regular, 14px).
- CTA: "Back to My Devices" (primary button, 48px, full-width).

---

#### Screen: Device Detail
**Purpose**: View full device information, status, history, actions.

**Design**:

**Header**:
- AppBar: Device model (H2), back button (left), more menu (right, 3-dot icon).

**Device Info Card** (top, 16px padding, md):
- Device icon (48x48px, brand blue).
- Model: "iPhone 13 Pro" (H3, SemiBold).
- IMEI: "35-989300-000000-0" (MonoSpace, Body Regular, 14px, selectable).
- Status badge: Green/Orange/Red (inline, top-right of card).
- Verification date: "Verified on Mar 15, 2025" (Body Small, gray).

**Device Details Section** (16px padding, md):
- H3: "Details" (Poppins SemiBold, 20px).
- Rows (dividers between):
  - Brand: "Apple" (Body Regular, gray on right).
  - Color: "Space Black" (Body Regular, gray on right).
  - Purchase Date: "Jan 2023" (Body Regular, gray on right).
  - Serial Number: "XXXX...YYYY" (Body Regular, gray on right, copy button).

**History Section** (16px padding, md):
- H3: "Verification History" (Poppins SemiBold, 20px).
- Timeline (vertical list):
  - Each event: Timestamp (Body Small, gray, left), event description (Body Regular, 14px), status dot (green/orange/red, 8px).
  - Example: "Mar 15, 2025 10:30 AM" → "Device verified" (green dot).

**Actions Section** (16px padding, md):
- If status is "pending":
  - Button: "Cancel Registration" (secondary, red text, 48px, full-width).
- If status is "verified":
  - Button: "Report Theft/Loss" (primary, 48px, full-width).
- If status is "blocked":
  - Button: "Appeal Block" (secondary, 48px, full-width).

**Dark Mode**: Invert colors, same structure.

---

### 3.4 FIR (First Information Report) Flow

#### Screen: Submit FIR
**Purpose**: User reports device theft or loss.

**Design**:

**Header**:
- H1: "Report Theft or Loss" (Poppins Bold, 32px).
- Subheader: "Provide details about your device" (Body Regular, 14px, gray).

**Device Selection** (16px padding, md):
- H3: "Select Device" (Poppins SemiBold, 20px).
- Device selector: Dropdown showing user's verified devices, formatted as "iPhone 13 Pro (IMEI: 35...)".
- Required field indicator: Red asterisk.

**Incident Type** (16px padding, md):
- H3: "Incident Type" (Poppins SemiBold, 20px).
- Radio buttons (vertical):
  - "Theft" (Body Large, 16px).
  - "Loss" (Body Large, 16px).
- Selected: blue dot + blue text.

**Incident Details** (16px padding, md):
- H3: "Incident Details" (Poppins SemiBold, 20px).
- Date picker: "Date of Incident" (label above, input below).
- Time picker: "Time of Incident" (optional).
- Location input: "Where did it happen?" (text input, geocoding optional).
- Description text area: "Describe what happened" (multi-line, 120px min-height, placeholder).

**Supporting Info** (16px padding, md):
- H3: "Additional Information" (Poppins SemiBold, 20px).
- Checkboxes:
  - "I have filed a police report (FIR) separately" (Body Regular, 14px).
  - "Device contains sensitive personal data" (Body Regular, 14px).
- File upload: "Attach supporting documents (optional, PDF/JPG)" (upload button, Body Small).

**CTA**:
- "Submit Report" (primary button, 48px, full-width).
- "Save Draft" (secondary button, 48px, full-width, below primary).

---

#### Screen: FIR Review (Police Officer View)
**Purpose**: Officer reviews FIR, verifies information, approves or rejects.

**Design**:

**Header**:
- H1: Case ID (MonoSpace, blue, 20px) (left-aligned).
- Status: Large badge (orange "PENDING REVIEW", right-aligned).
- Timestamp: "Submitted on Mar 15, 2025 10:30 AM" (Body Small, gray).

**User Information Card** (16px padding, md, light blue background #EBF5FF):
- Name: "Ahmed Ali" (Body Large, SemiBold).
- Contact: Phone + Email (Body Regular, 14px, blue links).
- Device: iPhone 13 Pro, IMEI: 35-989300-000000-0 (MonoSpace, 13px).

**FIR Details Section** (16px padding, md):
- H3: "Incident Details" (Poppins SemiBold, 20px).
- Type: "Theft" (Body Regular, 14px).
- Date/Time: "Mar 15, 2025 at 3:00 PM" (Body Regular, 14px).
- Location: "Karachi, Sindh" (Body Regular, 14px).
- Description: "My device was stolen while I was at a cafe..." (Body Regular, 14px, light gray background, 16px padding, border-left 4px blue).

**Verification Checklist** (16px padding, md):
- H3: "Verification" (Poppins SemiBold, 20px).
- Checkboxes (interactive, officer can toggle):
  - "IMEI matches registered device" (checked/unchecked).
  - "User has active registration" (checked/unchecked).
  - "Device was previously verified" (checked/unchecked).
  - "User account is in good standing" (checked/unchecked).

**Officer Notes** (16px padding, md):
- Text area: "Add notes for PTA review" (multi-line, 100px min-height, placeholder).

**Action Buttons** (16px padding, md):
- Primary: "Approve & Forward to PTA" (green button, 48px, full-width).
- Secondary: "Reject Report" (red outlined button, 48px, full-width).
- Tertiary: "Request Additional Info" (outlined button, 48px, full-width, below).

**Supporting Documents** (if uploaded):
- H3: "Attached Documents" (Poppins SemiBold, 20px).
- List: Each doc as a card with icon (PDF/image), filename, size, download link.

---

#### Screen: Case Status / Timeline (User View)
**Purpose**: User tracks their FIR status in real-time.

**Design**:

**Header**:
- H1: Case ID (MonoSpace, blue, 20px).
- Current status badge: Prominent, large (green "Approved", orange "Pending", red "Rejected").

**Status Timeline** (16px padding, lg):
- Vertical timeline (left divider, 4px, brand blue):
  - Step 1 (completed): Submitted (checkmark icon, green dot).
    - Date/time (Body Small, gray).
    - Description: "You submitted the FIR" (Body Regular, 14px).
  - Step 2 (in progress): Police Review (clock icon, orange dot, color highlight).
    - Date/time: "In progress" (Body Small, orange).
    - Description: "Your report is being reviewed" (Body Regular, 14px).
  - Step 3 (pending): PTA Approval (empty circle, gray dot).
    - Description: "Awaiting approval" (Body Regular, 14px, gray).

**Current Status Card** (16px padding, md):
- H3: "Next Step" (Poppins SemiBold, 20px).
- Large badge: "Pending Police Review" (orange).
- Estimated time: "Usually takes 2-3 business days" (Body Regular, 14px, gray).
- Contact info: "If you have questions, contact support" (Body Small, blue link).

**Action** (if applicable):
- Button: "Contact Police" OR "View Police Feedback" (secondary, 48px, full-width).

---

### 3.5 Settings & Account

#### Screen: Account / Profile
**Purpose**: View and edit user profile, contact information, preferences.

**Design**:

**Header**:
- H1: "Account" (Poppins Bold, 32px).

**Profile Card** (16px padding, md):
- Avatar: Circular, 64x64px, initials or image.
- Name: "Ahmed Ali" (H2, SemiBold).
- Email: "ahmed@example.com" (Body Regular, gray).
- Phone: "+92 300 1234567" (Body Regular, gray).
- Role badge: "Regular User" (Body Small, light gray background).

**Edit Profile Section** (16px padding, md):
- Button: "Edit Profile" (secondary, 48px, full-width).

**Contact Information** (16px padding, md):
- H3: "Contact Information" (Poppins SemiBold, 20px).
- Email (editable): Field + edit button.
- Phone (editable): Field + edit button.
- Address (editable): Field + edit button.

**Preferences** (16px padding, md):
- H3: "Preferences" (Poppins SemiBold, 20px).
- Toggle: "Email notifications" (on/off switch).
- Toggle: "SMS notifications" (on/off switch).
- Dropdown: "Theme" (Light, Dark, System).
- Dropdown: "Language" (English, Urdu).

**Security** (16px padding, md):
- H3: "Security" (Poppins SemiBold, 20px).
- Button: "Change Password" (secondary, 48px, full-width).
- Button: "Two-Factor Authentication" (secondary, 48px, full-width).
- Last sign-in: "Mar 15, 2025 at 10:30 AM" (Body Small, gray).

**Danger Zone** (16px padding, md, red-tinted background):
- H3: "Danger Zone" (Poppins SemiBold, 20px, red text).
- Button: "Delete Account" (red outlined button, 48px, full-width).
  - Confirmation dialog: "Are you sure? This cannot be undone."

**Logout** (16px padding, md):
- Button: "Sign Out" (primary, 48px, full-width).

---

#### Screen: Settings
**Purpose**: App-level settings, preferences, about.

**Design**:

**Header**:
- H1: "Settings" (Poppins Bold, 32px).

**App Settings** (16px padding, md):
- H3: "App" (Poppins SemiBold, 20px).
- Toggle: "Dark Mode" (if not system-based).
- Dropdown: "Font Size" (Small, Normal, Large).
- Dropdown: "Language" (English, Urdu).

**Notification Settings** (16px padding, md):
- H3: "Notifications" (Poppins SemiBold, 20px).
- Toggle: "Case updates" (on/off).
- Toggle: "Device alerts" (on/off).
- Toggle: "Security alerts" (on/off).

**Privacy & Legal** (16px padding, md):
- H3: "Privacy & Legal" (Poppins SemiBold, 20px).
- Button: "Privacy Policy" (full-width, outlined, 36px height).
- Button: "Terms of Service" (full-width, outlined, 36px height).
- Button: "About eDRMP" (full-width, outlined, 36px height).

**About** (16px padding, md):
- App version: "v1.0.0" (Body Small, gray).
- Build number: "Build 123" (Body Small, gray).
- Last updated: "Mar 15, 2025" (Body Small, gray).

---

## 4. Global UI Patterns & Rules

### 4.1 Forms & Input Validation

**Form Structure**:
- Labels above inputs (not floating, not placeholder-only).
- 16px (md) gap between fields.
- Error messages displayed below field (Body Small, red, #EF4444).
- Success messages displayed below field (Body Small, green, #10B981).
- Required field indicator: Red asterisk (*) in label.
- Disabled fields: 0.5 opacity, cursor not-allowed.

**Input Field States**:
- **Unfocused**: Border #E5E7EB (1px), placeholder #9CA3AF.
- **Focused**: Border #0066CC (1.5px), shadow subtle blue, placeholder hidden.
- **Error**: Border #EF4444 (1.5px), background tint light red (#FEE2E2), error message below.
- **Success**: Border #10B981 (1.5px), checkmark icon on right.
- **Disabled**: Border #E5E7EB, opacity 0.5.

**Form Submission**:
- Button disabled until required fields are valid.
- Loading state: Button shows spinner, text "Submitting..." (16px height spinner).
- Success: Confirmation message OR auto-navigate to next screen.
- Error: Error banner (top of form) with message + retry button.

---

### 4.2 Modals & Dialogs

**Modal Structure**:
- Backdrop: Semi-transparent black, opacity 0.5 (tappable to dismiss optional).
- Dialog: Center-aligned, 16px margin on mobile, max-width 400px on larger screens.
- Border radius: 16px.
- Padding: 24px (lg).
- Shadow: Elevation 3.

**Content**:
- Close button: X icon (24x24px) on top-right (or optional per flow).
- Title: H2, SemiBold, 24px.
- Body: Body Regular, 16px, up to 3 sentences per message.
- Actions: Buttons below content (primary + secondary).

**Examples**:
- Confirmation: "Are you sure you want to delete this?" → "Cancel" + "Delete".
- Info: "Device verified successfully!" → "OK".
- Error: "Network error. Please try again." → "Retry" + "Cancel".

---

### 4.3 Loading & Empty States

**Loading Indicator**:
- Spinner: Circular progress, brand blue (#0066CC), 48x48px.
- Text (optional): "Loading..." (Body Small, gray, below spinner, 8px gap).
- Backdrop: Optional (semi-transparent, prevents interaction).

**Empty State** (when no data to display):
- Icon: 64x64px, light gray (#D1D5DB).
- Heading: H3, 24px, gray.
- Subheading: Body Regular, 14px, lighter gray.
- CTA (optional): Button to create/add the missing item.

**Error State** (when data load fails):
- Icon: 64x64px, red (#EF4444).
- Heading: H3, "Something went wrong" or "Connection lost".
- Error message: Body Regular, 14px, gray.
- CTA: "Retry" button (primary, 48px, full-width).

---

### 4.4 Bottom Sheets & Drawers

**Bottom Sheet**:
- Appears from bottom, 50–80% of screen height.
- Rounded top corners: 16px.
- Drag handle: Small line (40x4px, gray, centered, top 8px padding).
- Content: Standard spacing, can scroll if needed.
- Backdrop: Optional, dismisses on tap.

**Drawer (Hamburger Menu)** (if used):
- Slides from left, 250–300px width.
- Same design system (spacing, text, colors).
- Menu items: Body Large, 16px, 16px padding vertical, full-width tap target.
- Active item: Background light blue, text blue.

---

### 4.5 Notifications & Toasts

**Toast Messages** (brief feedback):
- Position: Bottom of screen (above nav bar), 16px margin bottom.
- Background: Semi-transparent dark (or per type: green for success, red for error).
- Text: Body Regular, white, 14px, up to 2 lines.
- Auto-dismiss: 3–4 seconds.
- Duration: Smooth fade-in/out (200–300ms).

**Notification Types**:
- Success: Green background (#10B981), checkmark icon.
- Error: Red background (#EF4444), X icon.
- Info: Blue background (#0066CC), info icon.
- Warning: Orange background (#F97316), warning icon.

---

### 4.6 Dark Mode Implementation

**Dark Mode Colors**:
- Background: #0F172A (very dark blue).
- Surface: #1E293B (dark blue-gray, elevated).
- Surface Alt: #334155 (lighter surface, higher elevation).
- Text Primary: #F1F5F9 (off-white).
- Text Secondary: #CBD5E1 (light gray).
- Text Tertiary: #94A3B8 (medium gray).
- Borders: #475569 (dark borders).

**Dark Mode Transitions**:
- System dark mode or user toggle in settings.
- Smooth color transitions (200ms) when switching.
- All colors must contrast well in both light and dark (WCAG AA minimum).

**Example Color Mapping**:
```dart
// Light mode
Color primary = Color(0xFF0066CC);
Color background = Color(0xFFF9FAFB);
Color text = Color(0xFF111827);

// Dark mode
Color primary = Color(0xFF1D7FD6); // slightly lighter primary for dark
Color background = Color(0xFF0F172A);
Color text = Color(0xFFF1F5F9);
```

---

## 5. Component Interaction Patterns

### 5.1 Buttons

**Button States**:
- **Default**: Solid background color (blue for primary).
- **Hover** (on web/mouse): Subtle shadow lift, slight scale (1.02x).
- **Pressed** (active): Background darkens, scale down (0.95x), duration 100ms.
- **Disabled**: Opacity 0.5, no interaction.
- **Loading**: Spinner replaces icon/text, button disabled.

**Button Sizes**:
- **Large** (primary CTA): 48px height, full-width OR flex-grow.
- **Medium** (secondary): 40px height, variable width.
- **Small** (tertiary): 36px height, compact spacing.

---

### 5.2 Form Interactions

**Input Focus**:
- Border color changes to primary blue.
- Subtle shadow added (0.5px blur, blue tint).
- Keyboard appears (mobile).
- Cursor positioned inside field.

**Input Validation** (real-time or on blur):
- **IMEI**: Must be 15 digits, auto-formats with hyphens.
- **Email**: Standard email regex.
- **Phone**: Pakistani format (+92 or 0, 10 digits after code).
- **Date**: Valid date picker, no future dates.
- **Required fields**: Show red border + error message on submit if empty.

---

### 5.3 Navigation Transitions

**Screen Transitions**:
- Push (new screen): Slide-in from right (300ms ease-out).
- Pop (back): Slide-out to right (200ms ease-in).
- Tab switching: Fade-in/out (200ms) OR no transition (instant).
- Modal: Scale-in from center (200ms ease-out) + fade-in backdrop.

---

### 5.4 List Interactions

**List Item Interactions**:
- Tap: Navigates to detail screen OR triggers action.
- Hover (web): Subtle background color change, pointer cursor.
- Swipe (mobile, optional): Swipe-to-delete OR swipe-to-reveal actions.
- Long-press (mobile): Context menu (copy, delete, share, etc.).

---

## 6. Accessibility & Inclusivity

### 6.1 Contrast & Text Legibility

**WCAG AA Compliance** (minimum):
- Text on background: 4.5:1 contrast ratio (normal text).
- Large text (18px+): 3:1 contrast ratio.
- UI components: 3:1 contrast ratio.

**Examples**:
- White text (#FFFFFF) on blue (#0066CC): ✅ 8:1 (passes).
- Light gray text (#9CA3AF) on white (#FFFFFF): ❌ 2.5:1 (fails) → use dark gray (#6B7280) instead.

### 6.2 Touch Targets

- All interactive elements: Minimum 48x48px tap target.
- Spacing: 8px minimum between adjacent tap targets (to prevent mis-taps).

### 6.3 Semantic HTML / Accessibility Labels

- All buttons, inputs, icons must have **semantic labels** (`semanticLabel` in Flutter).
- Links must be distinguishable from regular text (underline or color + underline).
- Form labels must be associated with inputs (not placeholder-only).

### 6.4 Focus Indicators

- Visible focus ring (2–3px, blue) when tabbing through UI.
- High contrast: Blue focus ring on all backgrounds.

---

## 7. Performance & Loading

### 7.1 Image Optimization

- Device icons: SVG or PNG at 1x, 2x, 3x resolutions.
- User avatars: JPG/PNG, max 200x200px, lazy-loaded.
- Hero images: Compressed JPG, max 500KB, displayed as hero in onboarding.

### 7.2 Lazy Loading

- Long lists (devices, FIRs): Implement pagination or infinite scroll (load 10 items at a time).
- Images: Lazy-load on scroll, show placeholder (light gray background).

### 7.3 Skeleton Screens

- Instead of loading spinner, show skeleton (gray placeholder boxes) mimicking the final UI.
- Duration: 500–1000ms OR until data arrives.

---

## 8. Dark Mode Checklist

- [ ] All text colors tested in dark mode (sufficient contrast).
- [ ] All backgrounds and surfaces adapted for dark mode.
- [ ] Icons visible and clear in dark mode.
- [ ] Shadows adjusted (less pronounced in dark).
- [ ] Gradients maintained or adjusted for dark aesthetic.
- [ ] Form inputs clearly visible (borders, focus states).
- [ ] Cards/surfaces distinguishable from background.
- [ ] Links distinguishable from body text.

---

## 9. Implementation Checklist for Frontend Designers

Before Claude Opus 4.7 builds, verify:

- [ ] **Color System**: All colors defined in `lib/theme/colors.dart`, match palette (Section 2.1).
- [ ] **Typography**: All text styles defined in `lib/theme/text_styles.dart`, use correct font + size.
- [ ] **Spacing**: All padding/margin use `core/constants/spacing.dart` (xs, sm, md, lg, xl).
- [ ] **Components**: Reusable widgets in `lib/core/widgets/` (buttons, inputs, cards, badges, dialogs).
- [ ] **Theme Support**: Light + dark mode tested, toggle works smoothly.
- [ ] **Accessibility**: Contrast ≥ 4.5:1, touch targets ≥ 48x48px, semantic labels on all interactive elements.
- [ ] **Responsive**: Layouts adapt to small phones (320px) and tablets (600px+).
- [ ] **Performance**: Images optimized, lists use pagination/lazy-load, no jank on scroll.
- [ ] **Navigation**: Transitions smooth, back button works, deep linking supported (Phase 7+).
- [ ] **Form Validation**: Real-time feedback, error messages clear, success states visible.
- [ ] **Empty/Error States**: All screens have empty state (no data) and error state (load failure) UI.
- [ ] **Skeleton Screens**: Implemented for long-loading views (list, detail, dashboard).
- [ ] **Lint-Free**: `flutter analyze` shows "No issues found!" + `dart format .` passes.

---

## 10. Design Handoff Deliverables

When this Design.md is finalized and handed off to Claude Opus 4.7, ensure:

1. **This file** is the single source of truth. No external design files needed (unless Phase 7 adds Figma).
2. **Color constants** are pre-populated in `lib/theme/colors.dart` (Section 2.1).
3. **Text styles** are pre-populated in `lib/theme/text_styles.dart` (Section 2.2).
4. **Spacing constants** are in `lib/core/constants/spacing.dart`.
5. **Component widgets** (button, input, card, badge, dialog) are scaffolded in `lib/core/widgets/`.
6. **Screens** are scaffolded in `lib/features/` per phase (without full implementation).
7. **CLAUDE.md** is present and referenced (this Design.md complements it).

---

## 11. Edge Cases & Special Screens

### 11.1 Offline Mode

**Indicator**: "Offline" banner at top (Body Small, orange background, #F97316).
- Actions disabled: Buttons show "Check your connection" on tap.
- Cached data: Old data shown as-is with "Last updated: X hours ago" note.

### 11.2 No Internet / Network Errors

- Full-screen error state: Icon (signal, 64x64px, red), title, retry button.
- Toast: "Connection lost. Retrying..." (fade-in/out as user action occurs).

### 11.3 Session Expiry / Unauthorized

- Modal: "Your session expired. Please sign in again."
- Auto-navigate to login screen after 30s.

### 11.4 Feature Not Available (Role-Based)

- Disabled UI or hidden section with explanation: "This feature is only available to police officers."

---

## 12. Animation & Micro-Interaction Spec

### 12.1 Page Transitions

- **Push** (new screen): Slide from right + fade, 300ms, ease-out.
- **Pop** (back): Slide to right + fade, 200ms, ease-in.
- **Tab switch**: Fade (instant or 150ms cross-fade).

### 12.2 Button Interactions

- **Hover** (web): Scale 1.02x, shadow lift, 100ms ease-out.
- **Press**: Scale 0.95x, duration 100ms, snap back on release.
- **Loading**: Spinner rotation (continuous, 1s per full rotation).

### 12.3 List Animations

- **Item entry**: Slide-in from bottom + fade, staggered delay (50ms per item), duration 300ms.
- **Item removal**: Slide-out to right + fade, duration 200ms.

### 12.4 Form Feedback

- **Field focus**: Border color change (200ms), subtle shadow appear.
- **Validation message**: Slide-down + fade-in, 200ms.
- **Success checkmark**: Scale-in + rotate, 400ms ease-out.

### 12.5 Ripple / Splash Effect

- On button/list tap: Material ripple (Android-style) or subtle opacity change.
- Duration: 200–300ms.
- Color: Slight darker shade of primary color.

---

## 13. Testing Checklist for Design Fidelity

Before marking "design complete", test on actual devices (or emulators):

- [ ] **Light Mode**: All screens, all text readable, colors accurate, shadows visible.
- [ ] **Dark Mode**: All screens, contrast sufficient, colors adapted, shadows subtle.
- [ ] **Small Phone** (320–360px): No overflow, text wrapped well, buttons tappable, navigation accessible.
- [ ] **Large Phone** (400–480px): Proportional spacing, no excessive gaps.
- [ ] **Tablet** (600px+, if applicable): Layouts expand, side-by-side views OR single-column with max-width.
- [ ] **Forms**: Input focus clear, error messages visible, validation feedback immediate.
- [ ] **Buttons**: Ripple effect visible, disabled state clear, loading state clear.
- [ ] **Lists**: Items distinct, scroll smooth, no jank, lazy-load works.
- [ ] **Modals**: Centered, rounded corners, backdrop visible, close works.
- [ ] **Icons**: All sized correctly, visible in light + dark, semantic meaning clear.
- [ ] **Transitions**: Smooth, not too fast (< 300ms), not too slow (> 500ms for micro-interactions).
- [ ] **Deep Linking**: Each screen has a route, can navigate via URL (Phase 7+).

---

## 14. Final Notes for Claude Opus 4.7

### 14.1 Tone & Execution

You are building a **government-grade digital service**. Every pixel matters. The design must:
- Feel **professional** but not cold.
- Feel **trustworthy** but not outdated.
- Feel **efficient** but not overwhelming.
- Feel **modern** but not frivolous.

Your aesthetic direction is **Modern Civic Design**: Think UK GOV.UK (clarity, sans-serif, bold hierarchy) meets contemporary banking apps (rounded corners, subtle shadows, cohesive color). Avoid trends; commit to principles.

### 14.2 When in Doubt

1. Refer to Section 2 (Core Design System) for colors, fonts, spacing.
2. Refer to Section 3 (Screen-by-Screen Spec) for exact layouts.
3. Refer to Section 4 (Global Patterns) for consistency across screens.
4. Refer to Section 6 (Accessibility) for contrast + touch targets.
5. If something is not covered, ask yourself: "What would a professional government app do here?"

### 14.3 Code Quality

- ZERO hardcoded colors, fonts, sizes, or spacing in widgets.
- Use theme system religiously: `Theme.of(context).primaryColor`, `AppColors.primary`, `AppTextStyles.h1`, etc.
- Every reusable component goes into `lib/core/widgets/`.
- Every screen respects the design system without exception.
- `flutter analyze` must show "No issues found!" before declaring any phase complete.

### 14.4 Commit to Boldness

This is your chance to show what thoughtful, intentional design looks like at scale. Don't hold back. Push the design system. Make unexpected choices where justified. Make eDRMP feel like the professional, modern service it is.

---

## Appendix A: Color Accessibility Matrix

| Color | Light BG | Dark BG | Usage | Contrast |
|-------|----------|---------|-------|----------|
| #0066CC (Primary Blue) | ✅ 8:1 | ✅ 5:1 | Buttons, links, active states | Pass |
| #10B981 (Green) | ✅ 5:1 | ✅ 4:1 | Success, verified, approved | Pass |
| #EF4444 (Red) | ❌ 2:1 | ❌ 3:1 | Use only for small UI (badges, icons) | Conditional |
| #F97316 (Orange) | ❌ 3:1 | ✅ 4:1 | Pending, in-progress | Conditional |
| #6B7280 (Gray) | ✅ 5:1 | ✅ 4:1 | Secondary text | Pass |
| #9CA3AF (Light Gray) | ❌ 2.5:1 | ✅ 3:1 | Hints, placeholders (large bodies) | Conditional |

**Rule**: If contrast < 4.5:1, use for small text only (< 14px) OR pair with icon.

---

## Appendix B: Responsive Breakpoints

```
Mobile (0–480px):
  - Single-column layouts.
  - Full-width buttons, cards, inputs.
  - Bottom nav for main navigation.
  - Padding: 16px on sides.

Tablet (480–800px):
  - Wider cards, side-by-side layouts optional.
  - Two-column for device grid.
  - Top nav OR bottom nav (adaptive).
  - Padding: 24px on sides.

Desktop (800px+):
  - Max-width container (800–1000px, center).
  - Multi-column layouts.
  - Side drawer for navigation.
  - Padding: 32px on sides.
```

---

## Appendix C: Common Component Code Patterns

These patterns should be implemented as reusable widgets in `lib/core/widgets/`:

### Primary Button Widget
```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(text, style: AppTextStyles.labelLarge),
      ),
    );
  }
}
```

### Input Field Widget
```dart
class AppInputField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType keyboardType;

  const AppInputField({
    required this.label,
    this.placeholder,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: widget.label, style: AppTextStyles.bodySmall),
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          onChanged: (value) {
            setState(() {
              _error = widget.validator?.call(value);
            });
          },
        ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
```

---

## Appendix D: Theme Configuration (lib/theme/app_theme.dart)

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    // ... rest of theme config
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    // ... dark theme config mirroring light theme
  );
}
```

---

*End of Design.md*

---

**Generated for**: Saif @ COMSATS University Islamabad  
**Project**: eDRMP (e-Device Registration & Management Platform)  
**Version**: 1.0  
**Date**: March 2025  
**Intended for**: Claude Opus 4.7 — Frontend Design Optimization & Visualization


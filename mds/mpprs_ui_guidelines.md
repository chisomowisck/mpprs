# MPPRS Mobile UI Design Guidelines (Flutter)
**System:** Malawi Police Payment and Revenue System (MPPRS)  
**Audience:** Product Owners, UI/UX, Flutter Developers  
**Goal:** Modern, corporate, clean, and consistent UI for a government/enterprise app  
**Companion doc:** Corporate Clean Architecture Design fileciteturn2file0L1-L12

---

## 1. UI Goals
1. **Clarity first:** minimal cognitive load; users are often under time pressure.
2. **Corporate + trustworthy:** calm, official look; avoid “hype” visuals.
3. **Consistency:** predictable patterns across modules.
4. **Speed:** low taps to complete issuance; fast lists/search.
5. **Resilience:** clear offline/sync states; safe retries; no silent failures.
6. **Accessibility:** readable typography, large touch targets, high contrast.

---

## 2. Design System Foundations

### 2.1 Theme
- **Use Material 3** with a tailored corporate color scheme.
- Prefer **neutral surfaces** (light gray/white) with one primary brand color.
- Status colors must be standardized:
  - **Success:** Paid / Confirmed
  - **Warning:** Near deadline / Pending sync
  - **Error:** Failed sync / Overdue / Voided / Validation errors

### 2.2 Typography
- Use a modern sans-serif (e.g., Inter/Roboto).
- Define a small set of styles:
  - Title (Screen title)
  - Section header
  - Body
  - Caption/Meta
- Avoid too many font sizes; prioritize consistency.

### 2.3 Spacing & Layout
- Adopt an 8pt spacing grid (8/16/24/32).
- Prefer **cards** for grouped information and **sections** for forms.
- Use **one primary action** per screen (“Issue PRN”, “Save Draft”, etc.).

### 2.4 Components (Reusable)
Create shared components under a UI kit layer (e.g., `core/ui/`):
- AppBar variants (standard, search, detail)
- Primary/secondary buttons
- Form input fields (text, phone, date)
- Lookup picker (bottom sheet)
- Status chips/badges (Paid, Unpaid, Overdue, Voided, Pending)
- Receipt template view
- Loading skeletons + empty states
- Error banner + retry widget
- Offline banner + sync indicator

---

## 3. Navigation & Information Architecture

### 3.1 Primary Navigation
Recommended bottom navigation:
1. **Home**
2. **New**
3. **Search**
4. **Queue**
5. **Profile**

Rules:
- Keep max **5** primary tabs.
- “New” is a hub: *Traffic Offense* and optional *Service Fee*.

### 3.2 Secondary Navigation
- Use deep links from lists → transaction detail.
- Use modal/bottom-sheet for pickers and short actions (void, filter).

---

## 4. Screen-by-Screen UI Requirements

### 4.1 Login
**Must**
- Username + password (or configured auth method).
- Station indicator (pre-bound or selectable if role allows).
- Device binding status message.
- Clear error text and locked state after repeated failed attempts (policy-based).

**UI**
- Single column, minimal.
- Show app version at bottom for support.

---

### 4.2 Home Dashboard
**Must**
- Quick actions:
  - New Traffic Offense
  - New Service Fee (if enabled)
  - Search PRN
- Summary cards (role-permitted):
  - Issued today
  - Paid today
  - Pending sync
  - Overdue count

**Should**
- “Last 5 transactions” list for fast reprint/status check.

---

### 4.3 New Traffic Offense Form
**Must**
- Step-based or single scroll form with sections:
  1. Vehicle
  2. Offender
  3. Offense
  4. Review
- Inline validation + summary errors at top on submit.
- Offense category picker must:
  - search
  - recently used
  - favorite (star)

**Should**
- Auto-format registration number to uppercase; prevent invalid chars.
- Camera scan support for reg number/ID (optional if feasible).

**Design rules**
- Prefer “Review & Confirm” before PRN request.
- Use sticky bottom action bar:
  - Primary: **Review** / **Issue PRN**
  - Secondary: **Save Draft**

---

### 4.4 Category Picker (Offense/Service)
**Must**
- Search input at top.
- List items show:
  - Category name
  - Code (if relevant)
  - Default amount
- Tap selects and returns.

**Should**
- Group by category headings if many items.
- Provide “Most used” section.

---

### 4.5 Review & Confirm
**Must**
- Read-only summary grouped by sections.
- Prominent “Amount” and “Deadline” indicators.
- Confirm checkbox: “Details verified” (optional policy).

**Must not**
- Allow editing amounts unless policy allows; if allowed, require reason and supervisor override flow.

---

### 4.6 PRN Issued + Receipt Screen
**Must show**
- PRN (large, copy button)
- Amount
- Deadline date
- Payment instructions (channels)
- Station + officer + date/time
- Optional QR code area (if enabled)

**Actions**
- Primary: **Print** (if device supports) or **Share**
- Secondary: **Done**
- Tertiary: **Reprint** (from transaction detail)

**Design**
- Receipt preview uses a clean “paper” card with monochrome styling.

---

### 4.7 Transaction Detail
**Must**
- Status chip (Paid/Unpaid/Overdue/Voided/Pending)
- Timeline/history section:
  - Created → PRN issued → paid/overdue/voided
- Actions:
  - Refresh status
  - Reprint receipt
  - Void (authorized only; unpaid only)

**Should**
- Display audit metadata: created by, updated by, device, station.

---

### 4.8 Search
**Must**
- Search by PRN with instant results.
- Advanced filters:
  - Date range
  - Status
  - Station (role-permitted)
  - Officer (role-permitted)
  - Vehicle reg / offender name

**UI**
- Search bar + filter icon.
- Filters in bottom sheet.

---

### 4.9 Queue / Offline Drafts
**Must**
- Show pending items with sync state:
  - Pending
  - Failed
  - Retrying
- Allow:
  - Retry now
  - Edit draft
  - Discard draft (only if never issued PRN; with confirmation)

**Must**
- Persistent offline banner when connectivity is absent.

---

### 4.10 Void PRN (Supervisor)
**Must**
- Confirmation modal + mandatory reason field.
- Display “Cannot void paid PRN” rule clearly.
- After success: transaction becomes read-only with “Voided” banner.

---

### 4.11 Profile & Settings
**Must**
- User identity + role + station + device ID
- Logout
- Optional:
  - Printer pairing status (if used)
  - Diagnostics export (for support)
  - App update notes link

---

## 5. Visual Style Requirements (Modern + Corporate)
1. **Minimal iconography**: simple line icons, consistent stroke.
2. **Limited color usage**: color reserved for status and primary actions.
3. **No cluttered backgrounds**: use subtle gradients at most.
4. **Cards with soft elevation**: small shadows; avoid heavy skeuomorphism.
5. **Consistent rounded corners**: e.g., 12–16 radius across cards/buttons.
6. **Large tap targets**: minimum 44px height for buttons/fields.
7. **Readable tables/lists**: strong hierarchy:
   - primary line (PRN / category)
   - secondary line (amount, date)
   - trailing status chip

---

## 6. State & Feedback Patterns
### 6.1 Loading
- Use skeleton loaders for lists.
- Use inline button loaders for primary actions.
- Never block entire app unless absolutely necessary.

### 6.2 Errors
- Inline field errors for forms.
- Top-of-screen error banner for request failures.
- Provide actionable next steps:
  - Retry
  - Save draft
  - Contact support (with error code)

### 6.3 Success
- After PRN issuance, show a success state with receipt immediately.
- Provide “Copy PRN” and “Print/Share” as next actions.

---

## 7. Accessibility Requirements
- Support dynamic font scaling (within reasonable layout limits).
- Provide screen-reader labels for key actions (Issue PRN, Copy PRN, Print).
- Ensure contrast ratio meets WCAG guidelines (esp. status chips).

---

## 8. Content & Microcopy Guidelines
- Use simple, official language.
- Avoid ambiguous labels:
  - “Issue PRN” not “Submit”
  - “Save Draft” not “Save”
  - “Void PRN” not “Delete”
- Always show dates in an unambiguous format: **DD MMM YYYY**.

---

## 9. UI Acceptance Criteria
1. Officer can issue a PRN in **≤ 60 seconds** on average with minimal steps (target).
2. All primary workflows are doable **one-handed** (field conditions).
3. Status chips are consistent across screens and match backend status.
4. Offline drafts are clearly visible and recoverable.
5. Receipt view is clean, printable, and contains all mandatory fields.

---

## 10. Deliverables Recommended
- Figma design kit (components + styles)
- Screen designs for all inventory screens
- Interaction specs:
  - validation states
  - empty states
  - offline and retry flows
- Printer flow spec (if deployed)

---
*End of UI design guidelines.*

# MPPRS Mobile Application SRS (Flutter)
**System:** Malawi Police Payment and Revenue System (MPPRS)  
**Artifact:** Mobile Application Requirements (Business Logic + UI Flows)  
**Document name:** `mpprs_srs.md`  
**Source baseline:** MPPRS Business Requirements Specification (BRS) v1.1 (Jan 30, 2026)

---

## 1. Purpose
This document defines the **requirements for the MPPRS Mobile Application** used by Malawi Police Service (MPS) officers and supervisors to:
- capture traffic offenses and (where applicable) service-fee requests,
- request/generate Payment Reference Numbers (PRNs),
- issue receipts (digital and/or printed),
- track payment status, overdue items, and enforcement follow-up,
- maintain auditability and controlled operation on authorized devices.

The goal is to specify **what the mobile app must do** (business logic + UI behavior), not how it will be implemented technically.

---

## 2. Scope
### 2.1 In scope (Mobile App)
1. Officer authentication and role-based access.
2. Device binding / device fingerprinting and station assignment.
3. Traffic offense capture and PRN issuance workflow.
4. Police service-fee request capture and PRN issuance workflow (if enabled for mobile stations).
5. Lookup and selection of offense/service categories and revenue codes.
6. Automated charge application and payment deadline calculation.
7. PRN receipt generation (digital), optional on-device printing, and optional QR validation encoding.
8. Search and retrieval of transactions (PRN, offender, vehicle, date, station, status).
9. Payment status refresh (near real-time) and synchronization with external systems where required.
10. PRN voiding/cancellation (unpaid only), with authorization and reason capture.
11. Overdue identification and notifications/reminders (as configured by backend policies).
12. Audit trail capture for all actions initiated from the app.
13. Offline-tolerant capture with queued submission where connectivity is limited (per operational constraint).

### 2.2 Out of scope (Mobile App)
- Back-office reconciliation workflows and dashboards (web/finance systems).
- Public self-service portal features.
- Policy/legislative changes.

---

## 3. User Roles (Mobile)
- **Traffic Officer (Issuer):** captures offenses, issues PRNs/receipts, checks status.
- **Station Supervisor:** approves/authorizes voiding, reviews station activity, resolves exceptions.
- **Finance/Audit Viewer (optional on mobile):** view-only access for inspection/audit spot checks.

Role-based access control must restrict features by role.

---

## 4. Mobile App Modules
1. **Authentication & Device Control**
2. **Traffic Offense Capture**
3. **Police Service Fee Capture (optional)**
4. **PRN & Receipt Management**
5. **Payment Status & Overdue Monitoring**
6. **Search & History**
7. **Administration (mobile-limited)**
8. **Support & Diagnostics**

---

## 5. Business Objects & Data (Mobile Capture)
### 5.1 Traffic Offense (core fields)
- Registration Number (mandatory)
- Chassis Number (conditional)
- Driver/Offender Name (mandatory)
- Offense Category (mandatory, lookup)
- Revenue Code (mandatory, lookup)
- Fine Amount (mandatory; auto-populated by category; editable only if policy allows)
- Offense Date (mandatory)
- Issuing Officer Identifier (mandatory)
- Issuing Station (mandatory)
- Offender Phone Number (optional)
- Issuing Device (mandatory device ID + binding fingerprint)

### 5.2 Police Service Fee Request (core fields)
- Citizen Identification (mandatory)
- Citizen Name (mandatory)
- Service Category (mandatory, lookup)
- Service Description (optional)
- Revenue Code (mandatory, lookup)
- Service Fee Amount (mandatory; auto-populated by category; editable only if policy allows)
- Service Request Date (mandatory)
- Issuing Officer Identifier (mandatory)
- Issuing Station (mandatory)
- Citizen Phone Number (optional)

### 5.3 Payment Reference Number (PRN)
- PRN value (returned from MRA ePayment)
- PRN status: Draft / Issued-Unpaid / Paid / Overdue / Voided / Error
- PRN issue timestamp
- Payment deadline date (computed)
- External references (e.g., MALTIS offense reference)
- Audit metadata: createdBy, updatedBy, deviceId, stationId

---

## 6. Core Workflows (UI + Logic)

### 6.1 Login & Device Binding
**Goal:** only authorized users on authorized devices can issue PRNs.
1. User opens app → selects station (if not pre-bound) → login.
2. App verifies credentials and role.
3. App verifies device binding (device ID + fingerprint) and station assignment.
4. On success → home dashboard.

**UI screens**
- Login
- Station selection (if required)
- Device binding status / registration (admin-only)
- Home dashboard

---

### 6.2 Traffic Offense → PRN Issuance (Primary Flow)
This flow aligns with the MPPRS “To Be” traffic fines process:
1. Officer selects **New Traffic Offense**.
2. Officer captures offender/vehicle/context details.
3. Officer selects **Offense Category** (lookup) → system derives **Revenue Code** and **Fine Amount**.
4. App validates mandatory fields.
5. App requests a PRN from MPPRS backend (which integrates to MRA ePayment).
6. On success, app shows PRN + payment instructions + deadline (21 days unless overridden).
7. Officer issues a **digital receipt** and (if supported) prints receipt on POS-like device.
8. Offense appears in **Issued (Unpaid)** list; status updates to **Paid** upon confirmation.

**UI screens**
- New Traffic Offense (form)
- Offense Category picker (search + favorites)
- Review & Confirm (summary + validation errors)
- PRN Issued (receipt preview + share/print)
- Transaction detail (status, history, actions)

**Validation rules**
- All mandatory fields must be present before PRN request.
- Duplicate prevention: app must check for duplicate issuance for the same offense (via backend rule; may include MALTIS reference).
- If PRN request fails: app must keep the record as Draft/Queued and allow retry.

---

### 6.3 Police Service Fee → PRN Issuance (Optional Mobile Flow)
1. Officer selects **New Service Fee Request**.
2. Captures citizen details and selects service category.
3. System derives revenue code and fee amount.
4. Validates mandatory fields.
5. Requests PRN; displays deadline (7 days unless policy overrides).
6. Issues receipt/invoice for payer.
7. Service delivery is dependent on confirmed payment where applicable.

**UI screens**
- New Service Fee Request (form)
- Service Category picker
- Review & Confirm
- PRN Issued (invoice/receipt preview + share/print)
- Transaction detail

---

### 6.4 Attach/Link to MALTIS Offense (Where Applicable)
For traffic offenses already captured in MALTIS, the mobile app must support:
1. Search MALTIS offenses by reference/vehicle/driver (as permitted).
2. Select an offense.
3. Append/associate the MPPRS fine and PRN issuance to that record.
4. Display MALTIS reference on the receipt and transaction details.
5. Sync payment status updates back to MALTIS when confirmed.

**UI screens**
- MALTIS search
- MALTIS offense detail (read-only)
- Link & Issue PRN

---

### 6.5 Payment Status Refresh
1. User opens transaction or pulls-to-refresh list.
2. App calls backend to fetch latest payment confirmation state.
3. Status updates: Unpaid → Paid, Unpaid → Overdue (deadline passed), etc.
4. App displays confirmation details and locks financial fields after payment confirmation.

**UI behavior**
- Paid transactions: show “Paid” banner and disable edits/voiding.
- Overdue: show red status and follow-up actions.

---

### 6.6 PRN Voiding / Cancellation (Unpaid Only)
**Purpose:** allow cancellation only when no payment is received.
1. Supervisor (or authorized role) opens an Unpaid PRN transaction.
2. Selects **Void PRN**.
3. Enters **reason**; confirms.
4. Backend validates unpaid status and permissions, updates status to Voided, and notifies MRA ePayment where applicable.
5. App shows audit record of who voided and why.

**UI screens**
- Void PRN confirmation (requires reason)
- Voided transaction detail (read-only)

---

### 6.7 Overdue Identification & Reminders
1. App computes a local “approaching deadline” indicator using transaction deadline date.
2. Backend flags overdue based on official policy.
3. App lists overdue items and supports follow-up workflows:
   - filter by station/officer/date
   - export/share list (if permitted)
4. Reminders/notifications are shown to internal users as configured.

---

## 7. Functional Requirements (Mobile) — MoSCoW
> IDs in this section are **mobile-app specific** (MReq-xx) and trace back to the baseline BRS functions.

### A. Authentication, RBAC, and Audit
- **MReq-01 (Must):** The app must require authenticated login before any access to operational screens.
- **MReq-02 (Must):** The app must enforce role-based access control (RBAC) for all features.
- **MReq-03 (Must):** The app must timestamp and attribute all in-app actions to the authenticated user.
- **MReq-04 (Must):** The app must send audit events to the backend for: login/logout, create/edit drafts, PRN issuance, printing, voiding, status refresh, and error/retry actions.

### B. Offense & Service Capture
- **MReq-05 (Must):** The app must support capture of traffic offenses by authorized officers.
- **MReq-06 (Must):** The app must allow capture of vehicle, offender, offense, and enforcement details.
- **MReq-07 (Should):** The app should support capture of police service fee requests (if enabled for the deployment).
- **MReq-08 (Must):** The app must allow selection of predefined offense/service categories linked to approved revenue codes.
- **MReq-09 (Must):** The app must automatically apply predefined charges based on the selected category.
- **MReq-10 (Must):** The app must support court-ordered fines capture where applicable, including payment deadlines.

### C. MALTIS Linking (Traffic)
- **MReq-11 (Must):** The app must allow searching existing offenses from MALTIS during receipt issuance.
- **MReq-12 (Must):** The app must prevent duplicate PRN issuance for the same offense (by enforcing backend checks and showing clear user feedback).
- **MReq-13 (Must):** The app must display the MALTIS offense reference number on receipts and transaction details.
- **MReq-14 (Should):** The app should support status synchronization back to MALTIS after payment confirmation.

### D. PRN Generation & Receipt Issuance
- **MReq-15 (Must):** The app must request PRNs through MPPRS backend integration with MRA ePayment, and display PRN results to the officer.
- **MReq-16 (Must):** The app must validate mandatory fields before requesting a PRN.
- **MReq-17 (Must):** The app must generate a digital receipt/invoice view containing PRN and payment instructions.
- **MReq-18 (Must):** The app must compute and display payment timelines:
  - Traffic fines: 21 days
  - Service fees: 7 days
  - Court-ordered: court-defined
- **MReq-19 (Must):** The app must support printing receipts on supported POS-like devices with integrated printers (where deployed).
- **MReq-20 (Could):** The app could embed a QR code on receipts that links to a secure authenticity validation page.

### E. PRN Status & Controls
- **MReq-21 (Must):** The app must receive and display payment confirmation updates (via backend polling/refresh).
- **MReq-22 (Must):** The app must lock financial transaction fields after payment confirmation (read-only).
- **MReq-23 (Must):** The app must identify and display overdue items based on payment deadlines and backend flags.
- **MReq-24 (Must):** The app must allow PRN voiding/cancellation only for unpaid PRNs, only for authorized roles, and only with a captured reason.
- **MReq-25 (Should):** The app should notify the user if a PRN is unpaid but nearing deadline.

### F. Search & History
- **MReq-26 (Should):** The app should provide search and retrieval by PRN, date, station, status, vehicle registration, and offender/citizen name.
- **MReq-27 (Should):** The app should provide “My Issued PRNs” and “Station PRNs” views based on role and permissions.
- **MReq-28 (Could):** The app could support exporting selected transaction lists (subject to policy).

### G. Offline & Resilience (Operational Constraint)
- **MReq-29 (Should):** The app should support offline draft capture and queue PRN requests until connectivity is restored.
- **MReq-30 (Must):** The app must clearly show sync state (Synced / Pending / Failed) and provide retry controls.
- **MReq-31 (Must):** The app must prevent loss of locally captured drafts pending submission.

---

## 8. UI Requirements (Business-Focused)
### 8.1 Navigation
- Bottom navigation (or drawer) with:
  - Home
  - New (Offense / Service)
  - Search
  - Pending/Queue (offline)
  - Profile/Settings

### 8.2 Home Dashboard
- Quick actions: New Traffic Offense, New Service Fee (if enabled), Search PRN
- KPIs (role-permitted): Today issued, Paid today, Overdue count

### 8.3 Forms & Pickers
- Lookup pickers must support:
  - search by keyword/code
  - recently used / favorites
  - offline cached lists (where possible)

### 8.4 Receipt Screen
- Must display:
  - PRN
  - payer/offender identifiers
  - offense/service category
  - amount
  - payment deadline date
  - payment instructions (channels)
  - station + officer + date/time
- Actions:
  - Print (if supported)
  - Share as PDF/image (policy-permitted)
  - Copy PRN

### 8.5 Transaction Detail
- Status timeline: Draft → Issued → Paid/Overdue/Voided
- Audit snippet: createdBy/createdAt, last updated, deviceId
- Actions:
  - Refresh status
  - Void (authorized & unpaid only)
  - Reprint receipt

---

## 9. Business Rules Implemented in the Mobile App
1. **PRN is mandatory for any payable obligation.**
2. **One PRN per obligation; PRNs must not be reused.**
3. **Payment completion is only recognized after electronic confirmation from the payment service.**
4. **Traffic fines payment window = 21 days; service fees = 7 days; court-ordered = court-defined.**
5. **Overdue classification when payment not received within allowed timeframe.**
6. **Void PRN only if unpaid and authorized, with reason and audit trail.**
7. **No deletion of financial transactions; corrections via authorized adjustments (handled by backend policy).**

---

## 10. External Interfaces (Mobile Perspective)
- **MPPRS Backend API** (primary): authentication, master data (categories, revenue codes), PRN issuance, transaction queries, audit events.
- **MRA ePayment** (indirect): PRN generation and payment confirmations via backend.
- **MALTIS** (where applicable): offense lookup, offense linking, payment status sync (through backend).

---

## 11. Non-Functional Requirements (Mobile)
- **Security:** encryption in transit, secure local storage for tokens, session timeout, device binding.
- **Reliability:** retry with backoff for PRN requests; safe offline queueing.
- **Performance:** “near real-time” PRN issuance and status refresh under normal conditions.
- **Usability:** fast forms, minimal steps, clear validation messages, support low-connectivity environments.
- **Auditability:** immutable log submission for key events.

---

## 12. Acceptance Criteria (Mobile)
A release is acceptable when:
1. An officer can capture a traffic offense and successfully issue a PRN and receipt end-to-end.
2. Mandatory fields validation blocks PRN issuance until complete.
3. Duplicate issuance is prevented for the same offense.
4. Payment status transitions to Paid after confirmation and locks financial edits.
5. Authorized users can void an unpaid PRN with reason; paid PRNs cannot be voided.
6. Receipts display all required fields and can be printed on supported devices (where configured).
7. Offline draft capture works and syncs when connectivity returns, without data loss.

---

## 13. Appendix: Screen Inventory
1. Login
2. Station selection (optional)
3. Home dashboard
4. New Traffic Offense
5. Offense category picker
6. Review & Confirm (Traffic)
7. PRN Issued / Receipt (Traffic)
8. MALTIS search & link (optional)
9. New Service Fee Request (optional)
10. Service category picker
11. Review & Confirm (Service)
12. PRN Issued / Invoice (Service)
13. Search
14. Transaction detail
15. Void PRN (authorized only)
16. Pending queue / Offline drafts
17. Profile & Settings
18. Help / Diagnostics

---
*End of mobile application SRS.*

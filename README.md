# MPPRS Mobile Application (Flutter)

## Overview
The **Malawi Police Payment and Revenue System (MPPRS) Mobile Application** is a Flutter-based mobile solution designed for Malawi Police Service (MPS) officers and supervisors.

The mobile application enables:
- Traffic offense capture
- Police service fee capture (where enabled)
- PRN (Payment Reference Number) generation
- Digital receipt issuance
- Payment status tracking
- PRN voiding (authorized roles only)
- Offline draft capture and synchronization

This application integrates with the MPPRS backend, which in turn integrates with MRA ePayment and (where applicable) MALTIS.

---

## Project Structure (Recommended)

```
lib/
 ├── core/              # Shared utilities, theme, constants, UI kit
 ├── features/
 │    ├── auth/         # Login, device binding
 │    ├── offense/      # Traffic offense capture
 │    ├── service_fee/  # Police service fee capture
 │    ├── prn/          # PRN issuance & receipt
 │    ├── search/       # Search & filters
 │    ├── queue/        # Offline drafts & sync
 │    └── profile/      # User profile & settings
 ├── models/            # Data models
 ├── services/          # API services
 ├── state/             # State management
 └── main.dart
```

---

## Key Features

### 1. Authentication & Device Binding
- Secure login
- Role-based access control (RBAC)
- Device binding and station assignment

### 2. Traffic Offense Workflow
- Capture vehicle and offender details
- Select offense category
- Auto-apply revenue code and fine
- Generate PRN
- Issue digital receipt
- Print (if device supports)

### 3. Police Service Fee Workflow
- Capture citizen details
- Select service category
- Auto-apply revenue code and fee
- Generate PRN and invoice

### 4. PRN Management
- Real-time payment status refresh
- Overdue detection
- Authorized PRN voiding (unpaid only)
- Receipt reprint/share

### 5. Offline Support
- Draft saving without connectivity
- Sync queue with retry support
- Clear sync state indicators

---

## UI & Design Principles
- Modern, corporate, clean interface
- Material 3-based design system
- Minimal color usage with strong status indicators
- Clear validation and feedback
- Optimized for field use (low connectivity, fast operation)

---

## Business Rules (Mobile-Enforced)
- One PRN per obligation
- No duplicate issuance
- Paid transactions are read-only
- Void allowed only for unpaid PRNs with reason
- Payment deadlines:
  - Traffic fines: 21 days
  - Service fees: 7 days
  - Court-ordered fines: court-defined

---

## Non-Functional Requirements
- Secure API communication (HTTPS)
- Token-based authentication
- Audit trail for all critical actions
- Reliable retry mechanisms
- Optimized performance for field use

---

## Build & Run

### Requirements
- Flutter SDK (stable)
- Android Studio / VS Code
- Android device or emulator
- Internet access for API integration

### Run
```bash
flutter pub get
flutter run
```

---

## Environments
- Development
- Testing/UAT
- Production

Environment configuration should be managed using secure environment variables or flavor-based builds.

---

## Documentation
- mpprs_srs.md – Mobile application requirements (business logic)
- mpprs_ui_guidelines.md – UI design guidelines
- system_architecture.md – System architecture guidelines

---

## Ownership
Malawi Police Service (MPS)  
MPPRS Project Team

---

## License
Internal Government Project – Not for Public Distribution

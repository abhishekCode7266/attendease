# Student Attendance Portal 📱🎓
### Production-Ready Offline Student Attendance & Academic Management Mobile Application

[![Deploy AttendEase & Build APK](https://github.com/abhishekCode7266/attendease/actions/workflows/deploy.yml/badge.svg)](https://github.com/abhishekCode7266/attendease/actions/workflows/deploy.yml)
[![Live Demo](https://img.shields.io/badge/Live_Demo-GitHub_Pages-success?logo=github)](https://abhishekcode7266.github.io/attendease/)
[![Download APK](https://img.shields.io/badge/Download_APK-Release-blue?logo=android)](https://github.com/abhishekCode7266/attendease/actions)

🌐 **Live Web Application**: [https://abhishekcode7266.github.io/attendease/](https://abhishekcode7266.github.io/attendease/)  
📦 **Android Release APK**: Generated and available in GitHub Actions Artifacts.

> **Student Attendance Portal** is a modern, high-performance Flutter mobile application built exclusively with a **100% LOCAL SQLite Database (`sqflite`)**. It runs entirely offline without Firebase, backend servers, or internet access required. Includes a discrete owner/developer quick master bypass.

---

## 🌟 Key Highlights & Tech Stack

- **Framework**: Flutter (Dart 3+, Material 3 design system)
- **Database**: `sqflite` + `path` (SQLite with strict Foreign Keys, Cascades & Unique Constraints)
- **State Management**: `provider` (Reactive, testable, decoupled view-model architecture)
- **Local Key-Value Storage**: `shared_preferences` (Persistent login sessions & theme modes)
- **Formatting**: `intl` (Standardized dates, times, and numerical calculations)
- **Platforms**: Android (minSdkVersion 21+, targetSdkVersion 34+), Cross-platform ready
- **Architecture**: Domain-driven directory organization (models, database, providers, screens, widgets, utils)

---

## 👥 User Roles & Access Control

### 1. 🛡️ Admin Portal
- **Default Credentials**: Username `admin`, Password `admin123` (Stored in local SQLite; can be changed in Settings)
- **Student Management**:
  - Enroll new students (Full Name, Roll Number, Class/Department, Password, Contact)
  - Prevent duplicate roll numbers across the institution (case-insensitive validation)
  - Edit student details with real-time uniqueness validation
  - Delete students with confirmation dialog and cascade cleanup
  - Search students by name or roll number with real-time reactive filtering
- **Date-Wise Attendance Management**:
  - Interactive date picker (Previous Day, Calendar Picker, Next Day)
  - Subject and class filter dropdowns
  - Real-time counters: Present, Absent, Late, and Not Marked
  - One-tap status toggles (P / A / L) per student
  - Batch marking actions: **"Mark All Present"** & **"Mark All Absent"**
  - Manual override and correction for any date
- **Analytics & Shortage Reports**:
  - Overall college/class attendance percentage gauge
  - **Critical Shortage Highlighting**: Students below **75% attendance** are highlighted in bold red alerts
  - Export simulation for PDF and Excel/CSV formats
- **Leave Management**:
  - Review student leave applications
  - One-tap Approve or Reject with instant database status updates
- **Notice Board**: Post campus-wide announcements and notices

### 2. 🎓 Student Portal
- **Login**: Roll Number (e.g., `CS2026-001`) and Student Password (default: `password123`)
- **Today's Attendance Marking**:
  - One-tap "Mark Attendance Today" button with live system timestamp
  - **Strict Daily Enforcement**: Can only be marked once per day; locks with a green success badge once recorded
- **Live Clock & Calendar**:
  - Real-time digital clock and formatted calendar date
- **Attendance Gauge & Shortage Alerts**:
  - Overall attendance percentage progress bar
  - Prominent red warning banner if attendance falls below 75%
  - Total days, present days, absent days, and late days count
- **Subject-Wise Attendance Breakdown**:
  - Real-time tracking per subject (e.g. Python Programming: 18/20 = 90%, DBMS: 16/20 = 80%, DSA)
- **Interactive Attendance Calendar**:
  - Month switcher with color-coded daily indicator dots:
    - 🟢 Green: Present
    - 🔴 Red: Absent
    - 🟡 Amber: Late
    - 🔵 Blue: Approved Leave
    - ⚪ Grey: Holiday / Not Marked
- **Leave Application**:
  - Select date range and submit reason for absence
  - Real-time tracking of application status (Pending / Approved / Rejected)

---

## 🗄️ SQLite Database Schema

```sql
-- 1. Admins
CREATE TABLE admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
);

-- 2. Students
CREATE TABLE students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    roll_no TEXT UNIQUE NOT NULL,
    class_name TEXT NOT NULL,
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    created_at TEXT NOT NULL
);

-- 3. Attendance (With Compound Unique Constraint)
CREATE TABLE attendance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    date TEXT NOT NULL,                -- Format: yyyy-MM-dd
    status TEXT NOT NULL,              -- present, absent, late, leave, not_marked
    subject TEXT NOT NULL DEFAULT 'General',
    timestamp TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    UNIQUE (student_id, date, subject)
);

-- 4. Leave Applications
CREATE TABLE leaves (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    from_date TEXT NOT NULL,
    to_date TEXT NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, approved, rejected
    applied_at TEXT NOT NULL,
    reviewed_at TEXT,
    FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
);

-- 5. Announcements / Notice Board
CREATE TABLE announcements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    date TEXT NOT NULL,
    author TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'normal'
);
```

---

## 📁 Project Structure

```
attendease/
├── android/                        # Android build scripts, Gradle & Manifest
│   ├── app/
│   │   ├── build.gradle            # minSdkVersion 21, compileSdk 34
│   │   └── src/main/AndroidManifest.xml
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── lib/
│   ├── database/
│   │   └── database_helper.dart    # SQLite singleton, migrations, seed data & CRUD
│   ├── models/
│   │   ├── admin_model.dart        # Admin entity
│   │   ├── student_model.dart      # Student entity & initials
│   │   ├── attendance_model.dart   # Attendance records & statistical summaries
│   │   ├── leave_model.dart        # Leave application entity
│   │   └── announcement_model.dart # Campus announcements
│   ├── providers/
│   │   ├── auth_provider.dart      # Session management & credential validation
│   │   ├── student_provider.dart   # Student listing, search & CRUD operations
│   │   ├── attendance_provider.dart# Attendance marking, summaries & date filter
│   │   ├── leave_provider.dart     # Student leaves & admin approval
│   │   ├── announcement_provider.dart
│   │   └── theme_provider.dart     # Light/Dark mode with SharedPreferences
│   ├── screens/
│   │   ├── splash_screen.dart      # Session verification & routing
│   │   ├── login_screen.dart       # Role-switching login portal
│   │   ├── admin_dashboard_screen.dart # KPI dashboard & quick actions
│   │   ├── student_list_screen.dart# Searchable directory with delete dialog
│   │   ├── add_edit_student_screen.dart # Add/edit with duplicate check
│   │   ├── attendance_by_date_screen.dart # Date-wise marking & batch actions
│   │   ├── student_dashboard_screen.dart # Student attendance marking & status
│   │   ├── my_attendance_screen.dart # Color-coded monthly calendar & history
│   │   ├── leave_management_screen.dart # Leave applications & approvals
│   │   ├── reports_screen.dart     # <75% shortage alert & summary tables
│   │   └── settings_screen.dart    # Theme toggle, password change & logout
│   ├── widgets/
│   │   ├── custom_button.dart      # Tactile button with loading state
│   │   ├── custom_text_field.dart  # Form text fields with validation
│   │   ├── stat_card.dart          # KPI metric cards
│   │   ├── student_tile.dart       # Student list row with percentage badge
│   │   ├── attendance_tile.dart    # One-tap P / A / L status toggles
│   │   └── attendance_progress_bar.dart # Color threshold progress bar (<75% red)
│   ├── utils/
│   │   ├── constants.dart          # Tables, roles, colors & thresholds
│   │   ├── validators.dart         # Form validation rules
│   │   ├── app_theme.dart          # Material 3 light & dark theme palettes
│   │   └── date_helper.dart        # Date formatting & percentage math
│   └── main.dart                   # Application bootstrap with MultiProvider
├── test/
│   ├── unit/
│   │   ├── attendance_calculation_test.dart # Mathematical edge cases & thresholds
│   │   ├── validators_test.dart            # Form input validation rules
│   │   └── duplicate_prevention_test.dart   # Roll number uniqueness logic
│   └── widget/
│       ├── login_screen_test.dart          # Login role switching & rendering
│       └── stat_card_test.dart             # KPI metric widget interaction
├── pubspec.yaml                    # Dependencies & Flutter configuration
├── DEMO_SCRIPT.md                  # Video demonstration script
└── README.md                       # Documentation
```

---

## 🚀 Setup & Execution Guide

### Prerequisites
- Flutter SDK (3.10+ / 3.47+)
- Dart 3.0+
- Android Studio / Android SDK (Platform 21 to 34)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Static Analysis
```bash
flutter analyze
```
*Expected: `No issues found! (ran in 1.2s)`*

### 3. Run Unit and Widget Tests
```bash
flutter test
```
*Expected: All test suites pass.*

### 4. Run the App in Debug / Emulator
```bash
flutter run
```

### 5. Build Release APK
```bash
flutter build apk --release
```
The compiled APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Pre-Seeded Local Accounts

Because AttendEase works 100% offline, the database automatically seeds initial testing data upon first run:

| Role | Username / Roll No | Password | Description |
|---|---|---|---|
| **Admin** | `admin` | `admin123` | Default Administrator account |
| **Student 1** | `CS2026-001` | `password123` | Aarav Sharma (Good attendance: ~100%) |
| **Student 2** | `CS2026-002` | `password123` | Priya Patel (Good attendance: ~90%) |
| **Student 3** | `CS2026-003` | `password123` | Rohan Verma (**Shortage alert: ~40% < 75%**) |
| **Student 4** | `CS2026-004` | `password123` | Ananya Gupta (Healthy: ~80%) |
| **Student 5** | `CS2026-005` | `password123` | Vikram Singh (**Shortage alert: ~60% < 75%**) |

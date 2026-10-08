# 🎬 AttendEase Demo Video Script

This script provides an exact, step-by-step walkthrough to record or demonstrate the **AttendEase** mobile application.

---

## ⏱️ Timeline & Scene Breakdown

### 🎯 Scene 1: Splash Screen & Admin Login (0:00 - 0:25)
1. **Launch App**: Open AttendEase. Observe the animated blue gradient Splash screen with the app logo and tagline.
2. **Login Screen**: Notice the modern segmented role tabs: **"Admin Portal"** and **"Student Portal"**.
3. **Admin Form**: The default admin account is pre-filled:
   - **Username**: `admin`
   - **Password**: `admin123`
4. **Action**: Tap **"Login as Admin"**.
5. **Result**: A green snackbar displays `"Welcome, admin!"`, and the app navigates seamlessly to the **Admin Dashboard**.

---

### 🎯 Scene 2: Admin Dashboard & Enrolling a Student (0:25 - 0:55)
1. **Inspect Dashboard**:
   - Point out the KPI cards: **Total Students (5)**, **Present Today**, **Absent Today**, and **Shortage Alerts**.
   - Notice the prominent warning card: `"2 students below 75% attendance!"`.
2. **Navigate to Students**: Tap on the **Students** tab in the bottom navigation bar (or the **"Enroll Student"** quick action).
3. **Student Directory**:
   - Filter by class using the horizontal chips (`All`, `B.Tech CSE - Sec A`, etc.).
   - Type in the search bar: `"Priya"` or `"CS2026-002"`. Notice instant real-time filtering.
4. **Add New Student**:
   - Tap the **"+" (Add Student)** Floating Action Button.
   - Enter details:
     - **Full Name**: `Deepak Kumar`
     - **Roll Number**: Try entering `CS2026-001` (an existing roll number) and tap **"Enroll Student"**.
     - **Observe Validation**: Notice the instant error alert: `"Roll Number 'CS2026-001' already exists"`.
     - Change Roll Number to `CS2026-006`.
     - **Class**: Select `B.Tech CSE - Sec A`.
     - **Password**: `password123`.
   - Tap **"Enroll Student"**.
5. **Result**: Deepak Kumar is saved to the local SQLite database and immediately appears in the directory with total count updated to 6.

---

### 🎯 Scene 3: Student Login & Marking Attendance (0:55 - 1:30)
1. **Logout Admin**: Go to **Settings** > tap **"Logout Session"** > confirm logout.
2. **Switch to Student Portal**:
   - On the Login screen, tap the **"Student Portal"** tab.
   - Enter:
     - **Roll Number**: `CS2026-001`
     - **Password**: `password123`
   - Tap **"Login as Student"**.
3. **Student Dashboard Tour**:
   - Profile card displaying **Aarav Sharma**, **Roll No: CS2026-001**, and live digital clock.
   - Overall Attendance Progress Bar showing **100% (Green)**.
   - Subject-wise breakdown displaying **Python Programming (90%)**, **DBMS (80%)**, and **DSA (86%)**.
4. **Mark Attendance for Today**:
   - In the **"Today's Attendance"** card, observe status is **"PENDING"**.
   - Tap the large **"Mark Attendance as Present"** button.
   - **Result**: Button locks instantly, status changes to **"MARKED" (Green)** with a checkmark, and a confirmation toast appears: `"Attendance marked successfully for today!"`.
   - Explain: *"A student cannot mark attendance twice in the same day."*

---

### 🎯 Scene 4: Student Calendar & Leave Application (1:30 - 1:55)
1. **My Calendar**:
   - Tap **"My Calendar"**.
   - View the color-coded monthly calendar view with green dots (Present), red dots (Absent), and yellow dots (Late).
   - Scroll down to review the date-wise history log.
2. **Apply Leave**:
   - Go back and tap **"Apply Leave"**.
   - Pick a date range (e.g. tomorrow to day after tomorrow).
   - Enter reason: `"Family function in hometown"`.
   - Tap **"Submit Application"**.
   - Notice the application immediately appears with a yellow **"Pending"** badge.

---

### 🎯 Scene 5: Admin Date-Wise Inspection & Editing (1:55 - 2:30)
1. **Logout & Log back into Admin**:
   - Settings > Logout.
   - Select Admin Portal > Login (`admin` / `admin123`).
2. **Open Date-wise Attendance Screen**:
   - Tap the **"Attendance"** tab.
   - Point out today's date header, subject selector, and counters.
   - Notice Aarav Sharma is marked **"P"** (Present) from his self-marking action.
   - Demonstrate manual toggle: Tap **"A"** for any student to mark Absent, or **"L"** to mark Late. The database updates reactively.
   - Demonstrate batch operations: Tap **"Mark All Present"** button.

---

### 🎯 Scene 6: Reports Screen & Shortage Alert (<75%) (2:30 - 2:55)
1. **Navigate to Reports**: Tap the **"Reports"** tab.
2. **Review Metrics**:
   - Class Average percentage card.
   - Total enrolled students card.
   - **Shortage Counter**: Displays the exact number of students under 75%.
3. **Show Red Shortage Banner**:
   - Show the highlighted **RED ALERT** container: `"CRITICAL: Attendance Shortage (<75%)"`.
   - Shows **Rohan Verma (CS2026-003)** at **40.0%** and **Vikram Singh (CS2026-005)** at **60.0%** in bold red alert styling with days attended vs total days.
4. **Export Simulation**: Tap the PDF icon in the AppBar. A toast confirms: `"Attendance report generated successfully (PDF exported locally)"`.

---

### 🎯 Scene 7: Dark Mode & Theming (2:55 - 3:15)
1. **Navigate to Settings**: Tap the **"Settings"** tab.
2. **Toggle Dark Mode**:
   - Toggle the **"Dark Mode"** switch.
   - Observe the entire application instantly transitions into a rich, sleek dark theme with high contrast Material 3 slate and indigo surfaces.
3. **Demonstrate Persistence**:
   - The theme choice is saved automatically to `SharedPreferences`.
4. **Conclusion**:
   - Highlight: *"AttendEase is 100% local, ultra-fast, zero-cloud dependency, and fully ready for production."*

import 'package:flutter/material.dart';

/// App-wide constants for AttendEase
class AppConstants {
  // App Info
  static const String appName = 'AttendEase';
  static const String appTagline = 'Smart, Offline Student Attendance & Management';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'attendease.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String tableAdmins = 'admins';
  static const String tableStudents = 'students';
  static const String tableAttendance = 'attendance';
  static const String tableLeaves = 'leaves';
  static const String tableAnnouncements = 'announcements';

  // Default Admin Credentials
  static const String defaultAdminUsername = 'admin';
  static const String defaultAdminPassword = 'admin123';

  // SharedPreferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserRole = 'user_role';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';
  static const String prefUserRollNo = 'user_roll_no';
  static const String prefUserClass = 'user_class';

  // Attendance Thresholds
  static const double attendanceThreshold = 75.0; // In percentage
  static const double attendanceWarningThreshold = 80.0;

  // Standard Subject list for comprehensive subject-wise tracking
  static const List<String> defaultSubjects = [
    'General',
    'Python Programming',
    'Database Management (DBMS)',
    'Data Structures & Algorithms',
    'Computer Networks',
    'Software Engineering',
  ];

  // Standard Classes
  static const List<String> defaultClasses = [
    'B.Tech CSE - Sec A',
    'B.Tech CSE - Sec B',
    'BCA - Year 1',
    'BCA - Year 2',
    'MCA - Sem 1',
  ];
}

/// User Roles in AttendEase
enum UserRole {
  admin,
  student,
  teacher,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
    }
  }

  static UserRole fromString(String? role) {
    if (role == 'student') return UserRole.student;
    if (role == 'teacher') return UserRole.teacher;
    return UserRole.admin;
  }
}

/// Attendance Status Types
enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
  notMarked,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.leave:
        return 'leave';
      case AttendanceStatus.notMarked:
        return 'not_marked';
    }
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.notMarked:
        return 'Not Marked';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return const Color(0xFF10B981); // Emerald Green
      case AttendanceStatus.absent:
        return const Color(0xFFEF4444); // Rose Red
      case AttendanceStatus.late:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case AttendanceStatus.leave:
        return const Color(0xFF3B82F6); // Blue
      case AttendanceStatus.notMarked:
        return const Color(0xFF9CA3AF); // Neutral Gray
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.access_time_filled_rounded;
      case AttendanceStatus.leave:
        return Icons.beach_access_rounded;
      case AttendanceStatus.notMarked:
        return Icons.help_outline_rounded;
    }
  }

  static AttendanceStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'leave':
        return AttendanceStatus.leave;
      default:
        return AttendanceStatus.notMarked;
    }
  }
}

/// Leave Status
enum LeaveStatus {
  pending,
  approved,
  rejected,
}

extension LeaveStatusExtension on LeaveStatus {
  String get value {
    switch (this) {
      case LeaveStatus.pending:
        return 'pending';
      case LeaveStatus.approved:
        return 'approved';
      case LeaveStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return const Color(0xFFF59E0B);
      case LeaveStatus.approved:
        return const Color(0xFF10B981);
      case LeaveStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  static LeaveStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }
}

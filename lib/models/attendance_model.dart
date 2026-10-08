import '../utils/constants.dart';
import '../utils/date_helper.dart';
import 'student_model.dart';

/// Attendance Model representing a recorded attendance session
class AttendanceModel {
  final int? id;
  final int studentId;
  final String date; // yyyy-MM-dd
  final AttendanceStatus status;
  final String subject;
  final String? timestamp; // ISO 8601 string or time string
  final String? notes;

  const AttendanceModel({
    this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.subject = 'General',
    this.timestamp,
    this.notes,
  });

  /// Factory constructor to parse AttendanceModel from a SQLite Map
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      date: map['date'] as String,
      status: AttendanceStatusExtension.fromString(map['status'] as String?),
      subject: (map['subject'] as String?) ?? 'General',
      timestamp: map['timestamp'] as String?,
      notes: map['notes'] as String?,
    );
  }

  /// Converts the AttendanceModel to a SQLite Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'student_id': studentId,
      'date': date,
      'status': status.value,
      'subject': subject,
      'timestamp': timestamp ?? DateTime.now().toIso8601String(),
      'notes': notes,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  AttendanceModel copyWith({
    int? id,
    int? studentId,
    String? date,
    AttendanceStatus? status,
    String? subject,
    String? timestamp,
    String? notes,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'AttendanceModel(id: $id, studentId: $studentId, date: $date, status: ${status.name}, subject: $subject)';
}

/// Helper model combining attendance record with student details for Admin views
class AttendanceWithStudent {
  final StudentModel student;
  final AttendanceModel? attendance;
  final AttendanceStatus status;

  const AttendanceWithStudent({
    required this.student,
    this.attendance,
    required this.status,
  });

  AttendanceWithStudent copyWith({
    StudentModel? student,
    AttendanceModel? attendance,
    AttendanceStatus? status,
  }) {
    return AttendanceWithStudent(
      student: student ?? this.student,
      attendance: attendance ?? this.attendance,
      status: status ?? this.status,
    );
  }
}

/// Statistical summary of attendance for a single student
class StudentAttendanceSummary {
  final int studentId;
  final String studentName;
  final String rollNo;
  final String className;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int leaveDays;
  final double percentage;

  const StudentAttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.className,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.leaveDays,
    required this.percentage,
  });

  /// Factory calculator
  factory StudentAttendanceSummary.calculate({
    required StudentModel student,
    required List<AttendanceModel> records,
  }) {
    final total = records.length;
    int present = 0;
    int absent = 0;
    int late = 0;
    int leave = 0;

    for (final rec in records) {
      switch (rec.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.late:
          // Count late as present or half present (in AttendEase, student attended class)
          late++;
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.leave:
          leave++;
          break;
        case AttendanceStatus.notMarked:
          break;
      }
    }

    final pct = DateHelper.calculatePercentage(present, total);

    return StudentAttendanceSummary(
      studentId: student.id ?? 0,
      studentName: student.name,
      rollNo: student.rollNo,
      className: student.className,
      totalDays: total,
      presentDays: present,
      absentDays: absent,
      lateDays: late,
      leaveDays: leave,
      percentage: pct,
    );
  }

  bool get isBelowThreshold => percentage < AppConstants.attendanceThreshold;
}

/// Subject-wise attendance calculation
class SubjectAttendanceSummary {
  final String subject;
  final int totalClasses;
  final int presentClasses;
  final double percentage;

  const SubjectAttendanceSummary({
    required this.subject,
    required this.totalClasses,
    required this.presentClasses,
    required this.percentage,
  });

  bool get isBelowThreshold => percentage < AppConstants.attendanceThreshold;
}

import '../utils/constants.dart';
import 'student_model.dart';

/// Leave Model representing an application for leave
class LeaveModel {
  final int? id;
  final int studentId;
  final String fromDate; // yyyy-MM-dd
  final String toDate; // yyyy-MM-dd
  final String reason;
  final LeaveStatus status;
  final String? appliedAt;
  final String? reviewedAt;

  const LeaveModel({
    this.id,
    required this.studentId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.appliedAt,
    this.reviewedAt,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      fromDate: map['from_date'] as String,
      toDate: map['to_date'] as String,
      reason: map['reason'] as String,
      status: LeaveStatusExtension.fromString(map['status'] as String?),
      appliedAt: map['applied_at'] as String?,
      reviewedAt: map['reviewed_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'student_id': studentId,
      'from_date': fromDate,
      'to_date': toDate,
      'reason': reason,
      'status': status.value,
      'applied_at': appliedAt ?? DateTime.now().toIso8601String(),
      'reviewed_at': reviewedAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  LeaveModel copyWith({
    int? id,
    int? studentId,
    String? fromDate,
    String? toDate,
    String? reason,
    LeaveStatus? status,
    String? appliedAt,
    String? reviewedAt,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

/// Helper model for Leave application with Student details
class LeaveWithStudent {
  final LeaveModel leave;
  final StudentModel student;

  const LeaveWithStudent({
    required this.leave,
    required this.student,
  });
}

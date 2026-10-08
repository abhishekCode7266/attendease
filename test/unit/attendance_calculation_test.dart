import 'package:flutter_test/flutter_test.dart';
import 'package:attendease/utils/constants.dart';
import 'package:attendease/utils/date_helper.dart';
import 'package:attendease/models/student_model.dart';
import 'package:attendease/models/attendance_model.dart';

void main() {
  group('Attendance Calculation Unit Tests', () {
    test('calculatePercentage handles zero and boundary cases correctly', () {
      // 0 total days -> 0.0%
      expect(DateHelper.calculatePercentage(0, 0), equals(0.0));
      // 0 present out of 10 -> 0.0%
      expect(DateHelper.calculatePercentage(0, 10), equals(0.0));
      // 10 present out of 10 -> 100.0%
      expect(DateHelper.calculatePercentage(10, 10), equals(100.0));
      // 15 present out of 20 -> 75.0%
      expect(DateHelper.calculatePercentage(15, 20), equals(75.0));
      // 14 present out of 20 -> 70.0%
      expect(DateHelper.calculatePercentage(14, 20), equals(70.0));
      // 18 present out of 20 -> 90.0%
      expect(DateHelper.calculatePercentage(18, 20), equals(90.0));
      // Decimal precision: 16 present out of 21 -> 76.2%
      expect(DateHelper.calculatePercentage(16, 21), equals(76.2));
    });

    test('Threshold verification: accurately identifies shortage below 75%', () {
      const student = StudentModel(
        id: 1,
        name: 'Test Student',
        rollNo: 'TEST-001',
        className: 'B.Tech CSE - Sec A',
        password: 'password123',
      );

      // Student with 14 present out of 20 days = 70.0% (< 75%)
      final recordsShortage = <AttendanceModel>[
        ...List.generate(
          14,
          (i) => AttendanceModel(
            studentId: 1,
            date: '2026-10-${(i + 1).toString().padLeft(2, '0')}',
            status: AttendanceStatus.present,
          ),
        ),
        ...List.generate(
          6,
          (i) => AttendanceModel(
            studentId: 1,
            date: '2026-10-${(i + 15).toString().padLeft(2, '0')}',
            status: AttendanceStatus.absent,
          ),
        ),
      ];

      final summaryShortage = StudentAttendanceSummary.calculate(
        student: student,
        records: recordsShortage,
      );

      expect(summaryShortage.totalDays, equals(20));
      expect(summaryShortage.presentDays, equals(14));
      expect(summaryShortage.absentDays, equals(6));
      expect(summaryShortage.percentage, equals(70.0));
      expect(summaryShortage.isBelowThreshold, isTrue);

      // Student with 18 present out of 20 days = 90.0% (>= 75%)
      final recordsHealthy = <AttendanceModel>[
        ...List.generate(
          18,
          (i) => AttendanceModel(
            studentId: 1,
            date: '2026-10-${(i + 1).toString().padLeft(2, '0')}',
            status: AttendanceStatus.present,
          ),
        ),
        ...List.generate(
          2,
          (i) => AttendanceModel(
            studentId: 1,
            date: '2026-10-${(i + 19).toString().padLeft(2, '0')}',
            status: AttendanceStatus.absent,
          ),
        ),
      ];

      final summaryHealthy = StudentAttendanceSummary.calculate(
        student: student,
        records: recordsHealthy,
      );

      expect(summaryHealthy.percentage, equals(90.0));
      expect(summaryHealthy.isBelowThreshold, isFalse);
    });

    test('Late status is counted as attended class', () {
      const student = StudentModel(
        id: 2,
        name: 'Late Student',
        rollNo: 'TEST-002',
        className: 'BCA - Year 1',
        password: 'password123',
      );

      final records = [
        const AttendanceModel(studentId: 2, date: '2026-10-01', status: AttendanceStatus.present),
        const AttendanceModel(studentId: 2, date: '2026-10-02', status: AttendanceStatus.late),
        const AttendanceModel(studentId: 2, date: '2026-10-03', status: AttendanceStatus.late),
        const AttendanceModel(studentId: 2, date: '2026-10-04', status: AttendanceStatus.absent),
      ];

      final summary = StudentAttendanceSummary.calculate(student: student, records: records);
      expect(summary.totalDays, equals(4));
      expect(summary.presentDays, equals(3)); // 1 present + 2 late
      expect(summary.lateDays, equals(2));
      expect(summary.absentDays, equals(1));
      expect(summary.percentage, equals(75.0));
      expect(summary.isBelowThreshold, isFalse);
    });
  });
}

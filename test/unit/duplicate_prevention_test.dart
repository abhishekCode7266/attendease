import 'package:flutter_test/flutter_test.dart';
import 'package:attendease/models/student_model.dart';

void main() {
  group('Student Model & Duplicate Prevention Logic Unit Tests', () {
    test('Student initials generator functions as expected', () {
      const student1 = StudentModel(
        name: 'Aarav Sharma',
        rollNo: 'CS101',
        className: 'B.Tech CSE',
        password: 'pass',
      );
      expect(student1.initials, equals('AS'));

      const student2 = StudentModel(
        name: 'Priya',
        rollNo: 'CS102',
        className: 'B.Tech CSE',
        password: 'pass',
      );
      expect(student2.initials, equals('P'));

      const student3 = StudentModel(
        name: 'Dr. John Doe',
        rollNo: 'CS103',
        className: 'B.Tech CSE',
        password: 'pass',
      );
      expect(student3.initials, equals('DJ'));
    });

    test('Roll number normalized to uppercase for case-insensitive uniqueness', () {
      const student = StudentModel(
        name: 'Rohan Verma',
        rollNo: 'cs2026-003',
        className: 'B.Tech CSE',
        password: 'pass',
      );

      final map = student.toMap();
      expect(map['roll_no'], equals('CS2026-003'));
    });

    test('Student equality comparison operates on id and roll number', () {
      const studentA = StudentModel(
        id: 1,
        name: 'Aarav',
        rollNo: 'CS101',
        className: 'B.Tech CSE',
        password: 'pass',
      );

      const studentB = StudentModel(
        id: 1,
        name: 'Aarav Updated',
        rollNo: 'CS101',
        className: 'B.Tech CSE Sec B',
        password: 'pass',
      );

      const studentC = StudentModel(
        id: 2,
        name: 'Priya',
        rollNo: 'CS102',
        className: 'B.Tech CSE',
        password: 'pass',
      );

      expect(studentA == studentB, isTrue);
      expect(studentA == studentC, isFalse);
    });
  });
}

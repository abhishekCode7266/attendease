import 'package:flutter_test/flutter_test.dart';
import 'package:attendease/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('requiredField validator correctly tests inputs', () {
      expect(Validators.requiredField(null, 'Name'), equals('Name is required'));
      expect(Validators.requiredField('', 'Name'), equals('Name is required'));
      expect(Validators.requiredField('   ', 'Name'), equals('Name is required'));
      expect(Validators.requiredField('Valid Value', 'Name'), isNull);
    });

    test('validateName rejects empty or invalid characters', () {
      expect(Validators.validateName(null), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull); // Too short
      expect(Validators.validateName('John123'), isNotNull); // Digits not allowed in name
      expect(Validators.validateName('Aarav Sharma'), isNull);
      expect(Validators.validateName("O'Connor"), isNull);
    });

    test('validateRollNumber ensures alphanumeric format', () {
      expect(Validators.validateRollNumber(null), isNotNull);
      expect(Validators.validateRollNumber(''), isNotNull);
      expect(Validators.validateRollNumber('X'), isNotNull); // Too short
      expect(Validators.validateRollNumber('CS2026-001'), isNull);
      expect(Validators.validateRollNumber('BCA/2026/45'), isNull);
      expect(Validators.validateRollNumber('2026_09'), isNull);
      expect(Validators.validateRollNumber('Roll Number!'), isNotNull); // Special symbols
    });

    test('validatePassword validates minimum length', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('123', minLength: 4), isNotNull);
      expect(Validators.validatePassword('1234', minLength: 4), isNull);
      expect(Validators.validatePassword('admin123', minLength: 4), isNull);
    });

    test('validateReason requires minimum length', () {
      expect(Validators.validateReason(null), isNotNull);
      expect(Validators.validateReason('Ill'), isNotNull); // Less than 5 chars
      expect(Validators.validateReason('Medical emergency at home'), isNull);
    });
  });
}

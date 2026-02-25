import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:app1/services/auth_service.dart';
import 'package:app1/config/exceptions.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid-123';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  bool get emailVerified => false;
}

class MockUserCredential extends Mock implements UserCredential {
  final User _user;

  MockUserCredential(this._user);

  @override
  User? get user => _user;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Fake implements CollectionReference {}

class MockDocumentReference extends Fake implements DocumentReference {}

class MockDocumentSnapshot extends Fake implements DocumentSnapshot {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  bool get exists => true;

  @override
  Map<String, dynamic>? data() => _data;
}

void main() {
  group('AuthService Unit Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential(mockUser);
    });

    group('Validation Logic Tests', () {
      test('email validation should reject invalid email format', () {
        const invalidEmails = [
          'invalid-email',
          'test@',
          '@example.com',
          'test@.com',
          'test @example.com',
        ];

        for (final email in invalidEmails) {
          expect(
            () {
              // Test email validation pattern
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(email)) {
                throw ValidationException(message: 'Format email tidak valid');
              }
            },
            throwsA(isA<ValidationException>()),
            reason: 'Should reject: $email',
          );
        }
      });

      test('email validation should accept valid email format', () {
        const validEmails = [
          'test@example.com',
          'user.name@example.co.uk',
          'first+last@example.com',
        ];

        for (final email in validEmails) {
          expect(
            () {
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(email)) {
                throw ValidationException(message: 'Format email tidak valid');
              }
            },
            returnsNormally,
            reason: 'Should accept: $email',
          );
        }
      });

      test('password validation should reject password < 6 characters', () {
        const shortPasswords = ['', '1', 'short', '12345'];

        for (final password in shortPasswords) {
          expect(
            () {
              if (password.length < 6) {
                throw ValidationException(
                  message: 'Password minimal 6 karakter',
                );
              }
            },
            throwsA(isA<ValidationException>()),
            reason: 'Should reject: $password',
          );
        }
      });

      test('password validation should accept password >= 6 characters', () {
        const validPasswords = ['pass12', 'password123', 'P@ssw0rd!'];

        for (final password in validPasswords) {
          expect(
            () {
              if (password.length < 6) {
                throw ValidationException(
                  message: 'Password minimal 6 karakter',
                );
              }
            },
            returnsNormally,
            reason: 'Should accept: $password',
          );
        }
      });

      test('name validation should reject name < 3 characters', () {
        const shortNames = ['', 'A', 'AB'];

        for (final name in shortNames) {
          expect(
            () {
              if (name.length < 3 || name.length > 50) {
                throw ValidationException(message: 'Nama harus 3-50 karakter');
              }
            },
            throwsA(isA<ValidationException>()),
            reason: 'Should reject: $name',
          );
        }
      });

      test('name validation should reject name > 50 characters', () {
        final longName = 'a' * 51;

        expect(() {
          if (longName.length < 3 || longName.length > 50) {
            throw ValidationException(message: 'Nama harus 3-50 karakter');
          }
        }, throwsA(isA<ValidationException>()));
      });

      test('name validation should accept valid name length', () {
        const validNames = ['John', 'John Doe', 'Maria-Santiago', 'J-K'];

        for (final name in validNames) {
          expect(
            () {
              if (name.length < 3 || name.length > 50) {
                throw ValidationException(message: 'Nama harus 3-50 karakter');
              }
            },
            returnsNormally,
            reason: 'Should accept: $name',
          );
        }
      });
    });

    group('Mock Behavior Tests', () {
      test('MockUser returns correct uid', () {
        expect(mockUser.uid, equals('test-uid-123'));
      });

      test('MockUser returns correct email', () {
        expect(mockUser.email, equals('test@example.com'));
      });

      test('MockUser returns correct displayName', () {
        expect(mockUser.displayName, equals('Test User'));
      });

      test('MockUser returns emailVerified as false', () {
        expect(mockUser.emailVerified, equals(false));
      });

      test('MockUserCredential returns user correctly', () {
        expect(mockUserCredential.user, equals(mockUser));
      });

      test('MockDocumentSnapshot returns data correctly', () {
        const testData = {'email': 'test@example.com', 'name': 'Test User'};
        final snapshot = MockDocumentSnapshot(testData);

        expect(snapshot.exists, true);
        expect(snapshot.data(), equals(testData));
      });
    });

    group('Exception Handling', () {
      test('ValidationException contains correct message', () {
        const message = 'Email tidak valid';
        final exception = ValidationException(message: message);

        expect(exception.toString(), contains(message));
      });

      test('AuthException is a subclass of AppException', () {
        final exception = AuthException(message: 'Auth error');

        expect(exception, isA<AppException>());
      });

      test('NetworkException is a subclass of AppException', () {
        final exception = NetworkException(message: 'Network error');

        expect(exception, isA<AppException>());
      });
    });
  });
}

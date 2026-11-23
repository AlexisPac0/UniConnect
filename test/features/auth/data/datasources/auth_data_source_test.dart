import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/features/auth/data/datasources/auth_data_source.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late FirebaseAuthDataSource dataSource;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    dataSource = FirebaseAuthDataSource(firebaseAuth);
  });

  MockUser firebaseUser({required String uid, String? email}) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    return user;
  }

  group('authStateChanges', () {
    test('converts each Firebase User into an AuthUser', () {
      when(() => firebaseAuth.authStateChanges()).thenAnswer(
        (_) => Stream.fromIterable([
          firebaseUser(uid: 'uid-1', email: 'student@foi.hr'),
          firebaseUser(uid: 'uid-2', email: 'professor@foi.hr'),
        ]),
      );

      expect(
        dataSource.authStateChanges(),
        emitsInOrder([
          const AuthUser(id: 'uid-1', email: 'student@foi.hr'),
          const AuthUser(id: 'uid-2', email: 'professor@foi.hr'),
          emitsDone,
        ]),
      );
    });

    test('emits null when nobody is signed in', () {
      when(
        () => firebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      expect(dataSource.authStateChanges(), emitsInOrder([isNull, emitsDone]));
    });

    test('a user without an email gets an empty one', () {
      when(
        () => firebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(firebaseUser(uid: 'uid-1')));

      expect(
        dataSource.authStateChanges(),
        emits(const AuthUser(id: 'uid-1', email: '')),
      );
    });
  });
}

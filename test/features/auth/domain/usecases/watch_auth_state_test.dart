import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/features/auth/domain/entities/auth_user.dart';
import 'package:uniconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:uniconnect/features/auth/domain/usecases/watch_auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const tUser = AuthUser(id: 'uid-1', email: 'student@foi.hr');

  late MockAuthRepository repository;
  late WatchAuthState useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = WatchAuthState(repository);
  });

  test('emits the authentication state given by the repository', () {
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => Stream.fromIterable(const [null, tUser, null]));

    expect(useCase(), emitsInOrder([null, tUser, null, emitsDone]));
    verify(() => repository.authStateChanges()).called(1);
  });
}

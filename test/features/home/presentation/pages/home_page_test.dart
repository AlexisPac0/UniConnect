import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uniconnect/core/di/injection.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/core/widgets/widgets.dart';
import 'package:uniconnect/features/auth/presentation/cubit/sign_out_cubit.dart';
import 'package:uniconnect/features/auth/presentation/widgets/sign_out_button.dart';
import 'package:uniconnect/features/home/presentation/cubit/home_cubit.dart';
import 'package:uniconnect/features/home/presentation/pages/home_page.dart';
import 'package:uniconnect/features/home/presentation/widgets/welcome_item_card.dart';

import '../../fixtures.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockSignOutCubit extends MockCubit<SignOutState>
    implements SignOutCubit {}

void main() {
  late MockHomeCubit cubit;

  setUpAll(() => registerFallbackValue(UserRole.student));

  setUp(() {
    cubit = MockHomeCubit();
    when(() => cubit.load(any())).thenAnswer((_) async {});
    // The log out button of the app bar gets its cubit from get_it.
    final signOutCubit = MockSignOutCubit();
    when(() => signOutCubit.state).thenReturn(const SignOutIdle());
    getIt.registerFactory<SignOutCubit>(() => signOutCubit);
  });

  tearDown(() => getIt.reset());

  Future<void> pumpHomeView(WidgetTester tester, HomeState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: cubit,
          child: const HomeView(role: UserRole.student),
        ),
      ),
    );
  }

  testWidgets('shows a progress indicator while loading', (tester) async {
    await pumpHomeView(tester, const HomeLoading());

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(WelcomeItemCard), findsNothing);
  });

  testWidgets('shows one card per welcome item when loaded', (tester) async {
    await pumpHomeView(tester, const HomeLoaded(tWelcomeItems));

    expect(find.text('Welcome to UniConnect'), findsOneWidget);
    expect(find.text('Student space'), findsOneWidget);
    expect(find.byType(WelcomeItemCard), findsNWidgets(tWelcomeItems.length));
    expect(find.text('Your timetable'), findsOneWidget);
    expect(find.text('Attendance check-in'), findsOneWidget);
  });

  testWidgets('shows the settings and log out buttons in the app bar', (
    tester,
  ) async {
    await pumpHomeView(tester, const HomeLoaded(tWelcomeItems));

    final appBar = find.byType(AppBar);
    expect(
      find.descendant(of: appBar, matching: find.byTooltip('Settings')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: appBar, matching: find.byType(SignOutButton)),
      findsOneWidget,
    );
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    await pumpHomeView(tester, const HomeError('Could not load'));

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Could not load'), findsOneWidget);

    await tester.tap(find.text('Retry'));

    verify(() => cubit.load(UserRole.student)).called(1);
  });

  testWidgets('HomePage gets its cubit from get_it and loads the role', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(const HomeLoaded(tWelcomeItems));
    getIt.registerFactory<HomeCubit>(() => cubit);

    await tester.pumpWidget(
      const MaterialApp(home: HomePage(role: UserRole.professor)),
    );

    verify(() => cubit.load(UserRole.professor)).called(1);
    expect(find.text('Professor space'), findsOneWidget);
  });
}

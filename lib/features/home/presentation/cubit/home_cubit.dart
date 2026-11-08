import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';
import 'package:uniconnect/features/home/domain/usecases/get_welcome_items.dart';

part 'home_state.dart';

/// Loads the home screen content. Depends on the domain only.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getWelcomeItems) : super(const HomeLoading());

  final GetWelcomeItems _getWelcomeItems;

  Future<void> load(UserRole role) async {
    emit(const HomeLoading());
    final result = await _getWelcomeItems(role);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final value) => HomeLoaded(value),
      Failure(:final failure) => HomeError(failure.message),
    });
  }
}

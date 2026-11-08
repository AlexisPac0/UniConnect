import 'package:uniconnect/core/result/result.dart';
import 'package:uniconnect/core/session/user_role.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

/// Contract of the home data source, implemented in the `data` layer.
///
/// Implementations must never throw: every error is returned as a `Failure`.
abstract interface class HomeRepository {
  /// Returns the shortcuts to display on the home screen of [role].
  Future<Result<List<WelcomeItem>>> getWelcomeItems(UserRole role);
}

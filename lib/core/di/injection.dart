import 'package:get_it/get_it.dart';

/// Global service locator.
///
/// Every dependency of the app is registered here, in one place, so that the
/// object graph is easy to read and to replace in tests. This file (with
/// `core/router`) is the composition root: it is the only place outside a
/// feature allowed to import that feature's `data` layer.
final GetIt getIt = GetIt.instance;

/// Registers all dependencies. Must be called once before `runApp`.
void configureDependencies() {
  // Features register their dependencies below, one function per feature.
}

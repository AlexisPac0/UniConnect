/// The three kinds of users of UniConnect.
///
/// Pure Dart: it can be used by every layer, including `domain`.
enum UserRole {
  student('Student'),
  professor('Professor'),
  admin('Administrator');

  const UserRole(this.label);

  /// Name displayed in the UI.
  final String label;
}

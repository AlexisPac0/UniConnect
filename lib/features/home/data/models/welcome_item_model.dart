import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

/// Data representation of a [WelcomeItem], as stored by the backend.
///
/// Models know how to (de)serialize themselves; entities do not.
class WelcomeItemModel {
  const WelcomeItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.action,
  });

  /// Throws a [FormatException] or an [ArgumentError] if [map] is invalid.
  /// The repository converts these errors into a `Failure`.
  factory WelcomeItemModel.fromMap(Map<String, Object?> map) {
    final id = map['id'];
    final title = map['title'];
    final description = map['description'];
    final action = map['action'];
    if (id is! String ||
        title is! String ||
        description is! String ||
        action is! String) {
      throw FormatException('Invalid welcome item: $map');
    }
    return WelcomeItemModel(
      id: id,
      title: title,
      description: description,
      action: action,
    );
  }

  final String id;
  final String title;
  final String description;

  /// Name of a [WelcomeAction] value.
  final String action;

  WelcomeItem toEntity() {
    return WelcomeItem(
      id: id,
      title: title,
      description: description,
      action: WelcomeAction.values.byName(action),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/features/home/data/models/welcome_item_model.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

void main() {
  test('fromMap then toEntity builds the matching entity', () {
    final model = WelcomeItemModel.fromMap(const {
      'id': '1',
      'title': 'My attendance',
      'description': 'Attendance rate per course',
      'action': 'myAttendance',
    });

    expect(
      model.toEntity(),
      const WelcomeItem(
        id: '1',
        title: 'My attendance',
        description: 'Attendance rate per course',
        action: WelcomeAction.myAttendance,
      ),
    );
  });

  test('fromMap throws a FormatException when a field is missing', () {
    expect(
      () => WelcomeItemModel.fromMap(const {'id': '1'}),
      throwsFormatException,
    );
  });
}

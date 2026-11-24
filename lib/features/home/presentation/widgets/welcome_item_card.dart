import 'package:flutter/material.dart';
import 'package:uniconnect/core/widgets/app_card.dart';
import 'package:uniconnect/features/home/domain/entities/welcome_item.dart';

class WelcomeItemCard extends StatelessWidget {
  const WelcomeItemCard({super.key, required this.item, this.onTap});

  final WelcomeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      // The ListTile brings its own padding.
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(_iconFor(item.action)),
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }

  static IconData _iconFor(WelcomeAction action) {
    return switch (action) {
      WelcomeAction.timetable => Icons.calendar_month_outlined,
      WelcomeAction.scanAttendance => Icons.qr_code_scanner,
      WelcomeAction.myAttendance => Icons.fact_check_outlined,
      WelcomeAction.startAttendanceSession => Icons.qr_code_2,
      WelcomeAction.attendanceDashboard => Icons.insights_outlined,
      WelcomeAction.manageCourses => Icons.school_outlined,
    };
  }
}

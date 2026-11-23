/// A feature of UniConnect whose access depends on the user's role.
///
/// See `RoleAccessPolicy` for which roles can use each feature.
enum AppFeature {
  /// Timetable and lecture details (UC5, UC3, UC4).
  timetable,

  /// Check-in by scanning the QR code of a lecture (UC10).
  attendanceCheckIn,

  /// Own attendance record (UC14).
  myAttendance,

  /// Open and close an attendance session, display its QR code (UC8, UC9).
  attendanceSession,

  /// Attendance statistics (UC13).
  attendanceDashboard,

  /// Create courses and manage their members (UC1, UC2).
  courseManagement,

  /// Personal settings.
  settings,
}

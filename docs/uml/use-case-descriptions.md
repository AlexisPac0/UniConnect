# Use case descriptions (Timetable and Attendance modules)

Source: acceptance criteria of the Jira stories SCRUM-30 to SCRUM-44. Actors: Student, Professor, Administrator.

## Timetable module

**UC1 Manage courses** (SCRUM-30)
- Actor: Administrator
- Description: The administrator creates, edits and deletes courses from a course list.
- Rules: a course has a name, a code and a semester. Deleting a course asks for confirmation.

**UC2 Assign professors and enrol students in a course** (SCRUM-31)
- Actor: Administrator
- Description: The administrator searches users by name or e-mail and adds or removes professors and students on a course.
- Rules: an enrolled student sees the course in their timetable immediately.

**UC3 Schedule a lecture** (SCRUM-32)
- Actor: Professor
- Description: The professor creates a lecture with a date, a time and a room.
- Rules: only for courses the professor teaches. End time is after start time. Room is required. The lecture appears in the timetable of all enrolled students.

**UC4 Move or cancel a lecture** (SCRUM-33)
- Actor: Professor
- Description: The professor changes the date, time or room of a lecture, or cancels it with an optional reason.
- Rules: changed and cancelled lectures are clearly marked for students. The change triggers UC6.

**UC5 View daily / weekly timetable** (SCRUM-34)
- Actor: Student
- Description: The student switches between a day view and a week view of their timetable. Tapping a lecture opens its details (course, professor, room, time).
- Rules: only lectures of courses the student is enrolled in.

**UC6 Receive push notification on lecture change** (SCRUM-35)
- Actor: Student
- Description: The student receives a push notification when a lecture is moved to a new room or time, or cancelled. Tapping it opens the lecture details.
- Rules: only affected students are notified. Sent by a Cloud Function through Firebase Cloud Messaging.

**UC7 View timetable offline** (SCRUM-36)
- Actor: Student
- Description: The student opens the last synchronised timetable without network.
- Rules: an indicator shows the data may be outdated. Data refreshes automatically when the network is back. Extends UC5.

## Attendance module

**UC8 Open / close attendance session** (SCRUM-37)
- Actor: Professor
- Description: The professor opens an attendance session for a lecture, then closes it.
- Rules: only for one of the professor's lectures. One open session per lecture at a time. Closing stops all further check-ins. Opening a session displays the QR code (UC9).

**UC9 Display rotating QR code** (SCRUM-38)
- Actor: Professor (via the app)
- Description: The app shows a QR code holding a signed token tied to the session. It regenerates automatically (for example every 10 seconds) to prevent sharing screenshots.
- Rules: an expired token is rejected. The token cannot be forged by the client.

**UC10 Check in by scanning QR code** (SCRUM-39)
- Actor: Student
- Description: The student opens the camera scanner from the home screen and scans the QR code. A success screen confirms the course and lecture.
- Rules: clear error for an expired code, a closed session or a wrong course. A check-in includes the location check (UC11).

**UC11 Verify location of check-in** (SCRUM-40)
- Actor: none (system step of UC10)
- Description: The student's position is checked against the faculty area (configurable radius).
- Rules: a check-in outside the area is refused with an explanation. Location permission is requested with a clear explanation.

**UC12 See who is present and correct an entry** (SCRUM-42)
- Actor: Professor
- Description: The professor sees a live list of checked-in students during the session and can mark a student present or absent manually.
- Rules: manual corrections are flagged as such.

**UC13 View attendance statistics** (SCRUM-43)
- Actor: Professor
- Description: A dashboard shows attendance per lecture (number and percentage of present students) and per student across the course (percentage of attended lectures).
- Rules: filter by course.

**UC14 View own attendance record** (SCRUM-44)
- Actor: Student
- Description: The student sees, for each course, the list of lectures with present / absent status and an overall attendance percentage.

## Choices to validate

- UC9 and UC11 are modelled as included use cases, UC6 as included in UC4, UC7 as an extension of UC5. These links are my interpretation, not stated in Jira.
- SCRUM-41 (check-in business rules) is a technical task, not a use case. It is not in the diagram. Its rules are reflected in UC10 and UC11.
- Authentication, roles and language (SCRUM-25 to 28, 45) are outside the Timetable and Attendance modules and are not modelled.

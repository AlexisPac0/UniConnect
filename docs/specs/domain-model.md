# Domain model (SCRUM-20)

Entities, value objects and repository contracts of the domain layer (pure
Dart, see [the architecture](../architecture.md)). Repositories return
`Result<T>` and never throw. PlantUML source:
[`domain-class-diagram.puml`](../uml/domain-class-diagram.puml).

```mermaid
classDiagram
    %% Core Framework Primitives
    class UseCase~Type, Params~ {
        <<abstract>>
        +call(Params params) Future~Result~Type~~
    }
    class Result~T~ {
        <<sealed>>
    }
    class Success~T~ {
        +T data
    }
    class Failure~T~ {
        +AppFailure failure
    }
    class AppFailure {
        <<abstract>>
        +String message
        +String code
    }
    Result <|-- Success
    Result <|-- Failure
    Failure o-- AppFailure
    UseCase ..> Result : returns

    %% Enums and Value Objects
    class UserRole {
        <<enumeration>>
        student
        professor
        admin
    }
    class LectureStatus {
        <<enumeration>>
        scheduled
        rescheduled
        cancelled
    }
    class SessionStatus {
        <<enumeration>>
        open
        closed
    }
    class CheckInMethod {
        <<enumeration>>
        qr
        manual
    }
    class AttendanceStatus {
        <<enumeration>>
        present
        absent
        late
        excused
    }
    class GeoLocation {
        <<ValueObject>>
        +double latitude
        +double longitude
        +double accuracyMeters
        +distanceTo(GeoLocation other) double
        +isWithinRadius(GeoLocation center, double radiusMeters) bool
    }
    class AttendanceStatistics {
        <<ValueObject>>
        +String courseId
        +int totalLectures
        +int attendedLectures
        +double attendancePercentage
        +Map~String, double~ perStudentRate
    }

    %% Domain Entities
    class User {
        +String id
        +String email
        +String displayName
        +UserRole role
        +String studentNumber
        +List~String~ fcmTokens
        +DateTime createdAt
        +DateTime updatedAt
        +isStudent() bool
        +isProfessor() bool
        +isAdmin() bool
    }

    class Course {
        +String id
        +String code
        +String name
        +String semester
        +List~String~ professorIds
        +int studentCount
        +DateTime createdAt
        +DateTime updatedAt
        +isTaughtBy(String professorId) bool
    }

    class Enrolment {
        +String id
        +String studentId
        +String courseId
        +DateTime enrolledAt
    }

    class Lecture {
        +String id
        +String courseId
        +String professorId
        +String title
        +String room
        +DateTime startTime
        +DateTime endTime
        +LectureStatus status
        +String cancellationReason
        +DateTime rescheduledTo
        +DateTime updatedAt
        +duration Duration
        +isCancelled bool
        +isRescheduled bool
        +overlapsWith(Lecture other) bool
    }

    class AttendanceSession {
        +String id
        +String lectureId
        +String courseId
        +String professorId
        +DateTime openedAt
        +DateTime closedAt
        +SessionStatus status
        +String qrSecretSalt
        +int qrRotationIntervalSeconds
        +isOpen bool
        +isExpired(DateTime now) bool
    }

    class AttendanceRecord {
        +String id
        +String sessionId
        +String lectureId
        +String courseId
        +String studentId
        +DateTime timestamp
        +CheckInMethod checkInMethod
        +GeoLocation verifiedLocation
        +AttendanceStatus status
        +String manualOverrideBy
        +String manualOverrideReason
        +DateTime manualOverrideAt
        +isManualOverride bool
        +isPresent bool
    }

    %% Repository Interfaces
    class AuthRepository {
        <<interface>>
        +signInWithEmailAndPassword(String email, String password) Future~Result~User~~
        +signOut() Future~Result~void~~
        +getCurrentUser() Future~Result~User?~~
        +watchAuthState() Stream~User?~
        +registerFcmToken(String token) Future~Result~void~~
    }

    class CourseRepository {
        <<interface>>
        +getCourses() Future~Result~List~Course~~~
        +getCourseById(String courseId) Future~Result~Course~~
        +createCourse(String code, String name, String semester) Future~Result~Course~~
        +updateCourse(Course course) Future~Result~Course~~
        +deleteCourse(String courseId) Future~Result~void~~
        +assignProfessor(String courseId, String professorId) Future~Result~void~~
        +removeProfessor(String courseId, String professorId) Future~Result~void~~
        +enrolStudent(String courseId, String studentId) Future~Result~void~~
        +unenrolStudent(String courseId, String studentId) Future~Result~void~~
        +getCoursesForStudent(String studentId) Future~Result~List~Course~~~
        +getCoursesForProfessor(String professorId) Future~Result~List~Course~~~
    }

    class TimetableRepository {
        <<interface>>
        +getDailyTimetable(String userId, DateTime date) Future~Result~List~Lecture~~~
        +getWeeklyTimetable(String userId, DateTime weekStart) Future~Result~List~Lecture~~~
        +scheduleLecture(...) Future~Result~Lecture~~
        +rescheduleLecture(String lectureId, DateTime newStart, DateTime newEnd, String newRoom) Future~Result~Lecture~~
        +cancelLecture(String lectureId, String? reason) Future~Result~void~~
        +watchUpcomingLectures(String userId) Stream~List~Lecture~~
    }

    class AttendanceRepository {
        <<interface>>
        +openSession(String lectureId) Future~Result~AttendanceSession~~
        +closeSession(String sessionId) Future~Result~void~~
        +getActiveSession(String lectureId) Future~Result~AttendanceSession?~~
        +watchActiveSession(String lectureId) Stream~AttendanceSession?~
        +checkInWithQrToken(String sessionId, String qrToken, GeoLocation location) Future~Result~AttendanceRecord~~
        +manualOverrideAttendance(String recordId, AttendanceStatus status, String reason, String profId) Future~Result~AttendanceRecord~~
        +getSessionAttendance(String sessionId) Future~Result~List~AttendanceRecord~~~
        +watchSessionAttendance(String sessionId) Stream~List~AttendanceRecord~~
        +getStudentAttendanceHistory(String studentId, String? courseId) Future~Result~List~AttendanceRecord~~~
        +getCourseAttendanceStatistics(String courseId) Future~Result~AttendanceStatistics~~
    }

    %% Relationships
    User "1" *-- "1" UserRole : role
    Course "1" o-- "*" User : taught by
    Course "1" -- "*" Enrolment : enrols
    User "1" -- "*" Enrolment : student
    Course "1" *-- "*" Lecture : schedules
    User "1" -- "*" Lecture : professor
    Lecture "1" *-- "*" AttendanceSession : has
    AttendanceSession "1" *-- "*" AttendanceRecord : records
    User "1" -- "*" AttendanceRecord : attendee
    Lecture "1" *-- "1" LectureStatus : state
    AttendanceSession "1" *-- "1" SessionStatus : state
    AttendanceRecord "1" *-- "1" CheckInMethod : method
    AttendanceRecord "1" *-- "1" AttendanceStatus : state
    AttendanceRecord "1" o-- "0..1" GeoLocation : checks

    AuthRepository ..> User : provides
    CourseRepository ..> Course : manages
    CourseRepository ..> Enrolment : manages
    TimetableRepository ..> Lecture : manages
    AttendanceRepository ..> AttendanceSession : manages
    AttendanceRepository ..> AttendanceRecord : manages
    AttendanceRepository ..> AttendanceStatistics : produces
```

## Traceability

| Domain Entity | Firestore Collection (SCRUM-23) | Component / Layer (SCRUM-22) | Primary Use Cases (SCRUM-19) |
| :--- | :--- | :--- | :--- |
| `User` | `users` | Presentation / Domain / Auth | SCRUM-25, SCRUM-28 |
| `Course` | `courses` | Presentation / Domain / Course | UC1, UC2 (SCRUM-30, SCRUM-31) |
| `Enrolment` | `enrolments` | Data / Domain / Course | UC2 (SCRUM-31) |
| `Lecture` | `lectures` | Timetable Feature | UC3, UC4, UC5, UC6, UC7 (SCRUM-32 to SCRUM-36) |
| `AttendanceSession` | `attendance_sessions` | Attendance Feature | UC8, UC9 (SCRUM-37, SCRUM-38) |
| `AttendanceRecord` | `attendance_records` | Attendance Feature | UC10, UC11, UC12, UC14 (SCRUM-39 to SCRUM-44) |
| `AttendanceStatistics`| Computed Aggregate | Attendance Feature | UC13 (SCRUM-43) |

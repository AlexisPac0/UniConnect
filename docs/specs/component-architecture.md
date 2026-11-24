# Component architecture (SCRUM-22)

Flutter client (layers described in [the architecture](../architecture.md))
and Firebase backend. PlantUML source:
[`component-diagram.puml`](../uml/component-diagram.puml).

```mermaid
flowchart TB
    %% STYLING
    classDef clientStyle fill:#EBF3FB,stroke:#2C5282,stroke-width:2px,color:#1A365D;
    classDef layerStyle fill:#FFFFFF,stroke:#4A5568,stroke-width:1.5px,stroke-dasharray: 4 2,color:#2D3748;
    classDef moduleStyle fill:#EDF2F7,stroke:#4A5568,stroke-width:1px,color:#1A202C;
    classDef cloudStyle fill:#FFF5F5,stroke:#C53030,stroke-width:2px,color:#742A2A;
    classDef cloudCompStyle fill:#FFFFFF,stroke:#E53E3E,stroke-width:1.5px,color:#9B2C2C;
    classDef hardwareStyle fill:#EDFDFD,stroke:#234E52,stroke-width:1.5px,color:#234E52;

    %% FLUTTER MOBILE APP CLIENT
    subgraph Client["📱 Flutter Mobile Application (Android / iOS)"]
        
        subgraph Hardware["Device Hardware & Sensors"]
            CAM["📷 Camera Hardware\n(QR Scanner)"]:::hardwareStyle
            GPS["📍 Location Sensor\n(GPS Geofence)"]:::hardwareStyle
        end

        subgraph Core["Core Infrastructure (Cross-Cutting)"]
            ROUTER["AppRouter\n(go_router + role guards)"]:::moduleStyle
            DI["Service Locator\n(get_it)"]:::moduleStyle
            SESSION["Session & Role Manager\n(Student / Prof / Admin)"]:::moduleStyle
            RESULT["Result & Error Handling\n(Result<T>, AppFailure)"]:::moduleStyle
            THEME["Theme & Design System\n(Material 3)"]:::moduleStyle
        end

        subgraph Features["Feature Modules"]
            direction TB
            subgraph Presentation["Presentation Layer (UI & State)"]
                UI_AUTH["Auth Pages & Cubits"]:::moduleStyle
                UI_TT["Timetable Pages & Cubits\n(Day/Week View)"]:::moduleStyle
                UI_ATT["Attendance Pages & Cubits\n(QR Display / Scanner / Stats)"]:::moduleStyle
                UI_HOME["Home & Dashboard Pages"]:::moduleStyle
            end

            subgraph Domain["Domain Layer (Pure Dart Business Logic)"]
                UC_AUTH["Auth Use Cases & Entities"]:::moduleStyle
                UC_TT["Timetable Use Cases & Entities\n(GetTimetable, ScheduleLecture)"]:::moduleStyle
                UC_ATT["Attendance Use Cases & Entities\n(CheckIn, OpenSession, GetStats)"]:::moduleStyle
                REPO_INTERFACES["Repository Contracts (Interfaces)"]:::moduleStyle
            end

            subgraph Data["Data Layer (Data Access & Infrastructure)"]
                REPO_IMPL["Repository Implementations"]:::moduleStyle
                DS_REMOTE["Remote Data Sources\n(Firestore / Functions API)"]:::moduleStyle
                DS_LOCAL["Local Cache Data Sources\n(Offline Persistence)"]:::moduleStyle
                DS_HARDWARE["Hardware Adapters\n(Camera & GPS Services)"]:::moduleStyle
            end
        end
    end

    %% FIREBASE CLOUD BACKEND
    subgraph Firebase["☁️ Firebase Cloud Ecosystem (Backend as a Service)"]
        FB_AUTH["🔐 Firebase Authentication\n(Email/Password, Tokens)"]:::cloudCompStyle
        FB_FIRESTORE[("🗄️ Cloud Firestore\n(NoSQL Realtime Database)")]:::cloudCompStyle
        FB_FUNCTIONS["⚡ Cloud Functions\n(Check-in Validation & Change Triggers)"]:::cloudCompStyle
        FB_FCM["🔔 Firebase Cloud Messaging (FCM)\n(Push Notifications)"]:::cloudCompStyle
    end

    %% RELATIONSHIPS / INTERACTIONS
    Presentation -->|Dispatches intents| Domain
    Domain -->|Defines contract| REPO_INTERFACES
    REPO_IMPL -.->|Implements| REPO_INTERFACES
    Presentation -.->|Consumes state| Core
    
    Data --> Hardware
    Hardware -.-> CAM
    Hardware -.-> GPS

    %% CLIENT TO CLOUD
    DS_REMOTE -->|User Credentials| FB_AUTH
    DS_REMOTE <-->|Realtime Streams & Queries| FB_FIRESTORE
    DS_REMOTE -->|Validate QR & Geofence| FB_FUNCTIONS
    
    %% CLOUD INTERNAL INTERACTIONS
    FB_FUNCTIONS -->|Read/Write Records & Sessions| FB_FIRESTORE
    FB_FUNCTIONS -->|Trigger schedule alerts| FB_FCM
    FB_FCM -.->|Push notification payloads| Client

    %% STYLES APPLICATION
    class Client clientStyle;
    class Firebase cloudStyle;
    class Presentation,Domain,Data,Core,Hardware layerStyle;
```

## Backend

- **Firebase Auth**: accounts, sessions, password resets.
- **Cloud Firestore**: the six collections of the
  [data model](firestore-data-model.md), with real-time listeners for the
  timetable and the live attendance list. Its offline cache serves the
  timetable without network (UC7).
- **Cloud Functions** (planned):
  - `verifyCheckIn`: checks the rotating QR token and the distance between
    the student and the faculty, then writes the attendance record.
  - `onLectureUpdated`: when a lecture is moved or cancelled, notifies the
    enrolled students.
- **Cloud Messaging** (planned): push notifications for lecture changes (UC6).

On the device: the camera scans QR codes (`mobile_scanner`, UC10) and
`geolocator` gives the position for the location check (UC11).

## Check-in with rotating QR code and location (UC8 to UC11)

```mermaid
sequenceDiagram
    autonumber
    actor Prof as Professor
    actor Stud as Student
    participant AppP as Prof App (AttendanceCubit)
    participant AppS as Student App (ScannerCubit)
    participant GPS as Device GPS
    participant CF as Cloud Functions (verifyCheckIn)
    participant FS as Cloud Firestore

    Prof->>AppP: Opens attendance session (UC8)
    AppP->>FS: Create attendance_session (status: 'open', geofence, seed)
    AppP->>AppP: Display rotating QR code every 10s (UC9)

    Stud->>AppS: Opens QR Scanner (UC10)
    AppS->>GPS: Request current location (UC11)
    GPS-->>AppS: Returns (latitude, longitude)
    Stud->>AppS: Scans rotating QR code
    AppS->>CF: Call verifyCheckIn(token, sessionID, lat, lng)
    
    CF->>CF: Verify token validity against session seed
    CF->>CF: Verify student location within faculty geofence radius
    alt Check-in Valid
        CF->>FS: Create attendance_record (status: 'present')
        CF-->>AppS: Success (Course & lecture confirmed)
        AppP->>FS: Realtime listener receives new attendance_record
        AppP-->>Prof: Live dashboard updates with student presence (UC12)
    else Check-in Invalid (Expired QR or Outside Campus)
        CF-->>AppS: Error (Rejection reason)
    end
```

## Lecture change and push notification (UC4, UC6)

```mermaid
sequenceDiagram
    autonumber
    actor Prof as Professor
    participant AppP as Prof App
    participant FS as Cloud Firestore
    participant CF as Cloud Functions (onLectureUpdated)
    participant FCM as Firebase Cloud Messaging
    actor Stud as Student
    participant AppS as Student App

    Prof->>AppP: Moves lecture room or time (UC4)
    AppP->>FS: Update lecture document (status: 'moved', previousDetails)
    FS->>CF: Trigger onLectureUpdated event
    CF->>FS: Query enrolled students for courseId from 'enrolments'
    CF->>FS: Fetch FCM device tokens from 'users'
    CF->>FCM: Send push notification payload (lecture details)
    FCM-->>AppS: Deliver push notification (UC6)
    AppS-->>Stud: Displays system notification ("Lecture moved to Room 304")
    Stud->>AppS: Taps notification -> Navigates to Lecture Details (UC5)
```

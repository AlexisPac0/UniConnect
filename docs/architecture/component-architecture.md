# System Architecture and Component Specification

**Project:** UniConnect (University Timetable & Attendance Mobile Platform)  
**Ticket:** SCRUM-22 (Create architecture / component diagram)  
**Target Platform:** Flutter (Android/iOS) & Google Firebase Backend  
**Document Status:** Complete / Ready for Confluence publication  

---

## 1. Architectural Vision & Design Principles

UniConnect is designed as a distributed, modular, and reactive mobile system. The architecture guarantees high maintainability, testability, and responsiveness under varying network conditions.

### Architectural Principles:
1. **Clean Architecture by Feature**: The Flutter client is partitioned into self-contained feature slices (`auth`, `timetable`, `attendance`, `home`). Each feature is organized into three distinct layers:
   - **Presentation Layer**: UI widgets, views, and state management via BLoC/Cubit.
   - **Domain Layer**: Core enterprise business logic, entities, repository contracts, and use cases (100% pure Dart, decoupled from Flutter and Firebase).
   - **Data Layer**: Implementation of repository contracts, remote/local data sources, and DTO mappers.
2. **Dependency Inversion & Composition Root**: Features never import other features directly. Cross-feature integration, navigation (`go_router`), and dependency injection (`get_it`) are centralized within the `core` module.
3. **Reactive Cloud Backend (Firebase BaaS)**:
   - Real-time data synchronization using **Cloud Firestore**.
   - Serverless event-driven business logic using **Cloud Functions** (verifying rotating QR tokens and geofencing).
   - Targeted push notifications via **Firebase Cloud Messaging (FCM)**.
   - Secure authentication and identity management via **Firebase Auth**.
4. **Resilience & Offline First**: Critical features (such as timetable consultation) rely on local cache persistence to operate without network coverage (UC7).

---

## 2. Overall Component Diagram

The following diagram illustrates the global system architecture: the Flutter client layers, hardware integrations, and the Firebase cloud ecosystem.

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

---

## 3. Component Breakdown & Responsibilities

### 3.1 Client Layer: Feature Modules & Clean Architecture

Each feature module is organized into three strictly decoupled layers, enforced by automated architecture lint tests:

| Component / Layer | Responsibility | Dependencies & Constraints |
| :--- | :--- | :--- |
| **Presentation Layer** | Renders UI (Widgets, Screens) using Flutter Material 3. Manages UI state and user events using **BLoC / Cubit**. Displays loading indicators, snackbars, and error states. | Depends **only** on the `Domain` layer and `Core`. Strictly forbidden from importing the `Data` layer or Firebase SDK directly. |
| **Domain Layer** | Encapsulates enterprise logic: Entities (e.g. `User`, `Lecture`, `AttendanceSession`), abstract Repository interfaces, and Use Cases (e.g. `ScheduleLecture`, `CheckInWithQrCode`). | **Pure Dart**. Has zero dependencies on Flutter, Firebase, UI, or external SDKs. Completely portable and unit-testable. |
| **Data Layer** | Implements the domain repository contracts. Orchestrates data fetching from remote data sources (Cloud Firestore, Cloud Functions) and local persistent caches. Converts raw JSON/Firestore snapshots into domain entities via DTO models. | Depends on `Domain` and external SDKs (Firebase SDK, Camera, Geolocator). Never leaks external models to the presentation layer. |

---

### 3.2 Client Layer: Core Infrastructure Modules

The `lib/core` directory contains cross-cutting building blocks shared across all features:

* **AppRouter (`core/router`)**:
  - Declarative routing powered by `go_router`.
  - Manages deep linking and role-based route guards (`UserRole: student, professor, admin`).
  - Automatically redirects unauthenticated users to `/login` and routes authenticated users to their specific role dashboard (`/student`, `/professor`, `/admin`).
* **Service Locator (`core/di/injection.dart`)**:
  - Dependency injection container built with `get_it`.
  - Acts as the application's composition root: instantiates and registers data sources, repositories, cubits, and platform services as singletons or factories.
* **Session Manager (`core/session`)**:
  - Maintains the active user identity, authentication state, and role claims throughout the app lifecycle.
* **Result & Error System (`core/result` & `core/error`)**:
  - Functional error handling using a sealed class `Result<T>` (`Success` or `Failure`).
  - Ensures repositories catch all infrastructure exceptions and wrap them into typed `AppFailure` instances. **No uncaught exception ever crashes the UI**.

---

### 3.3 Client Layer: Hardware & Platform Services

* **Camera Subsystem (`DS_HARDWARE / Camera`)**:
  - Integrates device camera hardware to scan rotating QR codes (UC10) using `mobile_scanner`.
* **Geolocation Subsystem (`DS_HARDWARE / GPS`)**:
  - Interacts with device location services (`geolocator`) to capture real-time GPS coordinates $(lat, lng)$ for physical presence validation within the university boundary (UC11).
* **Local Offline Cache (`DS_LOCAL`)**:
  - Leverages Firestore native offline cache and local secure storage to allow students to consult their latest synchronized schedule without active network coverage (UC7).

---

### 3.4 Backend Layer: Firebase Cloud Platform

* **Firebase Authentication (`FB_AUTH`)**:
  - Handles user account credentials, password resets, session tokens, and security claims.
* **Cloud Firestore (`FB_FIRESTORE`)**:
  - Highly scalable, multi-region NoSQL document database.
  - Houses the 6 core collections (`users`, `courses`, `enrolments`, `lectures`, `attendance_sessions`, `attendance_records`).
  - Provides real-time reactive streams (`onSnapshot`) to update student schedules and the professor's live attendance monitor instantly.
* **Firebase Cloud Functions (`FB_FUNCTIONS`)**:
  - Serverless compute environment executing trusted backend operations:
    1. **`verifyCheckIn`**: Validates the cryptographic rotating token seed and calculates the Haversine distance between the student's GPS location and faculty coordinates, preventing fraud.
    2. **`onLectureUpdated`**: Database trigger listening to changes on the `lectures` collection. When a lecture is cancelled or relocated, it automatically gathers affected students and dispatches FCM notifications.
* **Firebase Cloud Messaging (`FB_FCM`)**:
  - Low-latency push notification gateway delivering schedule modification alerts to students' iOS and Android devices in background or terminated states (UC6).

---

## 4. Key End-to-End Interaction Flows

### Flow 1: Attendance Check-in with Rotating QR & Geofence (UC8 to UC11)

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

### Flow 2: Timetable Reschedule & Push Notification (UC4 & UC6)

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

---

## 5. Technology Stack & Component Mapping

| Architectural Component | Technology / Library | Layer / Location |
| :--- | :--- | :--- |
| **Mobile Client Framework** | Flutter SDK 3.x (Dart 3.x) | Client Application |
| **UI Design System** | Material 3 Components | `lib/core/theme/` & `presentation/` |
| **State Management** | `flutter_bloc` / Cubit | `lib/features/*/presentation/` |
| **Dependency Injection** | `get_it` | `lib/core/di/injection.dart` |
| **Navigation & Routing** | `go_router` | `lib/core/router/` |
| **QR Code Scanner** | `mobile_scanner` | `lib/features/attendance/data/` |
| **Geolocation & Geofence** | `geolocator` | `lib/features/attendance/data/` |
| **Unit & Architecture Testing**| `flutter_test`, `mocktail`, `bloc_test` | `test/` |
| **User Identity** | Firebase Authentication | Cloud Backend |
| **Realtime Database** | Google Cloud Firestore | Cloud Backend |
| **Serverless Logic** | Firebase Cloud Functions (TypeScript/Node.js) | Cloud Backend |
| **Push Notification Service** | Firebase Cloud Messaging (FCM) | Cloud Backend |

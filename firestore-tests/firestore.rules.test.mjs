// Firestore security rules tests (SCRUM-29).
//
// Run with `npm run test:rules`: it starts the Firestore emulator on the
// offline `demo-uniconnect` project and runs this file with `node --test`.

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-uniconnect';

const now = Timestamp.fromMillis(Date.UTC(2026, 10, 24, 9, 0));
const later = Timestamp.fromMillis(Date.UTC(2026, 10, 24, 11, 0));

// --------------------------------------------------------------- fixtures

const user = (role, extra = {}) => ({
  email: `${role}@uni.test`,
  displayName: role,
  role,
  createdAt: now,
  updatedAt: now,
  ...extra,
});

const course = (extra = {}) => ({
  code: 'CS302',
  name: 'Mobile App Dev',
  semester: '2026-FALL',
  professorIds: ['prof'],
  studentCount: 1,
  createdAt: now,
  updatedAt: now,
  ...extra,
});

const enrolment = (studentId, courseId, extra = {}) => ({
  studentId,
  courseId,
  studentName: 'Student',
  studentEmail: 'student@uni.test',
  courseCode: 'CS302',
  courseName: 'Mobile App Dev',
  enrolledAt: now,
  ...extra,
});

const lecture = (extra = {}) => ({
  courseId: 'c1',
  courseCode: 'CS302',
  courseName: 'Mobile App Dev',
  professorId: 'prof',
  professorName: 'Prof',
  title: 'Intro',
  room: 'Hall A',
  startTime: now,
  endTime: later,
  status: 'scheduled',
  createdAt: now,
  updatedAt: now,
  ...extra,
});

const session = (extra = {}) => ({
  lectureId: 'l1',
  courseId: 'c1',
  professorId: 'prof',
  status: 'open',
  openedAt: now,
  tokenRotationIntervalSeconds: 30,
  geofence: { latitude: 48.85, longitude: 2.35, radiusMeters: 50 },
  ...extra,
});

const manualRecord = (extra = {}) => ({
  sessionId: 's1',
  lectureId: 'l1',
  courseId: 'c1',
  studentId: 'student',
  studentName: 'Student',
  studentEmail: 'student@uni.test',
  status: 'present',
  checkInMethod: 'manual_professor',
  checkInTime: now,
  isManualCorrection: true,
  correctedByProfessorId: 'prof',
  correctedAt: now,
  ...extra,
});

const qrRecord = (extra = {}) => ({
  sessionId: 's1',
  lectureId: 'l1',
  courseId: 'c1',
  studentId: 'student',
  studentName: 'Student',
  studentEmail: 'student@uni.test',
  status: 'present',
  checkInMethod: 'qr',
  checkInTime: now,
  isManualCorrection: false,
  ...extra,
});

// ----------------------------------------------------------------- setup

let env;

// Seeded data: c1 is taught by `prof` and has `student` enrolled; c2 is
// taught by `prof2` and has nobody enrolled.
async function seed() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await Promise.all([
      setDoc(doc(db, 'users/admin'), user('admin')),
      setDoc(doc(db, 'users/prof'), user('professor')),
      setDoc(doc(db, 'users/prof2'), user('professor')),
      setDoc(doc(db, 'users/student'), user('student')),
      setDoc(doc(db, 'users/student2'), user('student')),
      setDoc(doc(db, 'courses/c1'), course()),
      setDoc(doc(db, 'courses/c2'), course({ code: 'CS400', professorIds: ['prof2'] })),
      setDoc(doc(db, 'enrolments/student_c1'), enrolment('student', 'c1')),
      setDoc(doc(db, 'lectures/l1'), lecture()),
      setDoc(doc(db, 'lectures/l2'), lecture({ courseId: 'c2', professorId: 'prof2' })),
      setDoc(doc(db, 'attendance_sessions/s1'), session()),
      setDoc(doc(db, 'attendance_sessions/s1/private/secret'), { sessionSecret: 'seed' }),
      setDoc(doc(db, 'attendance_records/s1_student'), qrRecord()),
    ]);
  });
}

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await seed();
});

after(async () => {
  await env?.cleanup();
});

// ----------------------------------------------------------------- users

describe('users', () => {
  test('signed-out callers can read nothing', async () => {
    await assertFails(getDoc(doc(anon(), 'users/student')));
    await assertFails(getDoc(doc(anon(), 'courses/c1')));
  });

  test('a user reads their own profile but not someone else\'s', async () => {
    await assertSucceeds(getDoc(doc(as('student'), 'users/student')));
    await assertFails(getDoc(doc(as('student'), 'users/student2')));
    await assertFails(getDoc(doc(as('prof'), 'users/student')));
  });

  test('only admins list users', async () => {
    await assertSucceeds(getDocs(collection(as('admin'), 'users')));
    await assertFails(getDocs(collection(as('prof'), 'users')));
  });

  test('only admins create valid users', async () => {
    await assertSucceeds(setDoc(doc(as('admin'), 'users/new'), user('student')));
    await assertFails(setDoc(doc(as('admin'), 'users/bad'), user('superuser')));
    await assertFails(setDoc(doc(as('admin'), 'users/bad'), user('student', { id: 'other' })));
    await assertFails(setDoc(doc(as('admin'), 'users/bad'), user('student', { extra: 1 })));
    // Nobody creates their own profile, even with a valid document.
    await assertFails(setDoc(doc(as('self'), 'users/self'), user('student')));
  });

  test('owners can update device tokens but not their role', async () => {
    const db = as('student');
    await assertSucceeds(updateDoc(doc(db, 'users/student'), { fcmTokens: ['t1'], updatedAt: later }));
    await assertFails(updateDoc(doc(db, 'users/student'), { role: 'admin', updatedAt: later }));
    await assertFails(updateDoc(doc(db, 'users/student'), { displayName: 'X', updatedAt: later }));
  });

  test('admins update others but cannot change their own role', async () => {
    const db = as('admin');
    await assertSucceeds(updateDoc(doc(db, 'users/student'), { role: 'professor' }));
    await assertSucceeds(updateDoc(doc(db, 'users/admin'), { displayName: 'Root' }));
    await assertFails(updateDoc(doc(db, 'users/admin'), { role: 'student' }));
  });

  test('admins delete other users but not themselves', async () => {
    await assertSucceeds(deleteDoc(doc(as('admin'), 'users/student2')));
    await assertFails(deleteDoc(doc(as('admin'), 'users/admin')));
    await assertFails(deleteDoc(doc(as('student'), 'users/student')));
  });

  test('a signed-in caller without a profile is denied', async () => {
    await assertFails(getDoc(doc(as('ghost'), 'courses/c1')));
  });
});

// --------------------------------------------------------------- courses

describe('courses', () => {
  test('enrolled students read their course by id only', async () => {
    await assertSucceeds(getDoc(doc(as('student'), 'courses/c1')));
    await assertFails(getDoc(doc(as('student'), 'courses/c2')));
    await assertFails(getDocs(collection(as('student'), 'courses')));
  });

  test('professors read and query the courses they teach', async () => {
    const db = as('prof');
    await assertSucceeds(getDoc(doc(db, 'courses/c1')));
    await assertFails(getDoc(doc(db, 'courses/c2')));
    await assertSucceeds(getDocs(query(collection(db, 'courses'),
      where('professorIds', 'array-contains', 'prof'))));
    await assertFails(getDocs(collection(db, 'courses')));
  });

  test('only admins write courses', async () => {
    await assertSucceeds(setDoc(doc(as('admin'), 'courses/c3'), course()));
    await assertFails(setDoc(doc(as('admin'), 'courses/c4'), course({ studentCount: -1 })));
    await assertFails(updateDoc(doc(as('prof'), 'courses/c1'), { name: 'Hacked' }));
    await assertFails(deleteDoc(doc(as('prof'), 'courses/c1')));
    await assertSucceeds(deleteDoc(doc(as('admin'), 'courses/c2')));
  });
});

// ------------------------------------------------------------ enrolments

describe('enrolments', () => {
  test('students read their own enrolments', async () => {
    await assertSucceeds(getDoc(doc(as('student'), 'enrolments/student_c1')));
    await assertSucceeds(getDocs(query(collection(as('student'), 'enrolments'),
      where('studentId', '==', 'student'))));
    await assertFails(getDoc(doc(as('student2'), 'enrolments/student_c1')));
  });

  test('professors read enrolments of courses they teach', async () => {
    await assertSucceeds(getDoc(doc(as('prof'), 'enrolments/student_c1')));
    await assertFails(getDoc(doc(as('prof2'), 'enrolments/student_c1')));
  });

  test('admins create enrolments with a composite id for an existing course', async () => {
    const db = as('admin');
    await assertSucceeds(setDoc(doc(db, 'enrolments/student2_c1'), enrolment('student2', 'c1')));
    await assertFails(setDoc(doc(db, 'enrolments/wrong-id'), enrolment('student2', 'c2')));
    await assertFails(setDoc(doc(db, 'enrolments/student2_nope'), enrolment('student2', 'nope')));
    await assertFails(setDoc(doc(as('student2'), 'enrolments/student2_c2'), enrolment('student2', 'c2')));
  });

  test('admins only update the denormalised copies', async () => {
    const db = as('admin');
    await assertSucceeds(updateDoc(doc(db, 'enrolments/student_c1'), { studentName: 'Renamed' }));
    await assertFails(updateDoc(doc(db, 'enrolments/student_c1'), { courseId: 'c2' }));
  });
});

// -------------------------------------------------------------- lectures

describe('lectures', () => {
  test('enrolled students and course professors read lectures', async () => {
    await assertSucceeds(getDoc(doc(as('student'), 'lectures/l1')));
    await assertFails(getDoc(doc(as('student'), 'lectures/l2')));
    await assertSucceeds(getDoc(doc(as('prof'), 'lectures/l1')));
    await assertFails(getDoc(doc(as('prof'), 'lectures/l2')));
  });

  test('constrained timetable queries pass, unconstrained ones fail', async () => {
    await assertSucceeds(getDocs(query(collection(as('prof'), 'lectures'),
      where('professorId', '==', 'prof'))));
    await assertSucceeds(getDocs(query(collection(as('student'), 'lectures'),
      where('courseId', '==', 'c1'))));
    await assertFails(getDocs(collection(as('student'), 'lectures')));
  });

  test('course professors create valid lectures', async () => {
    const db = as('prof');
    await assertSucceeds(setDoc(doc(db, 'lectures/l3'), lecture()));
    await assertFails(setDoc(doc(db, 'lectures/l4'), lecture({ endTime: now, startTime: later })));
    await assertFails(setDoc(doc(db, 'lectures/l5'), lecture({ status: 'postponed' })));
    await assertFails(setDoc(doc(db, 'lectures/l6'), lecture({ professorId: 'prof2' })));
    await assertFails(setDoc(doc(db, 'lectures/l7'), lecture({ courseId: 'c2', professorId: 'prof2' })));
    await assertFails(setDoc(doc(as('student'), 'lectures/l8'), lecture()));
  });

  test('course professors cancel lectures but cannot move them to another course', async () => {
    const db = as('prof');
    await assertSucceeds(updateDoc(doc(db, 'lectures/l1'), {
      status: 'cancelled', cancellationReason: 'Sick', updatedAt: later,
    }));
    await assertFails(updateDoc(doc(db, 'lectures/l1'), { courseId: 'c2' }));
    await assertFails(updateDoc(doc(as('prof2'), 'lectures/l1'), { room: 'Lab 3' }));
  });

  test('only course professors delete lectures', async () => {
    await assertFails(deleteDoc(doc(as('student'), 'lectures/l1')));
    await assertSucceeds(deleteDoc(doc(as('prof'), 'lectures/l1')));
  });
});

// --------------------------------------------------- attendance sessions

describe('attendance sessions', () => {
  test('enrolled students read sessions but never the QR secret', async () => {
    const db = as('student');
    await assertSucceeds(getDoc(doc(db, 'attendance_sessions/s1')));
    await assertFails(getDoc(doc(db, 'attendance_sessions/s1/private/secret')));
    await assertSucceeds(getDoc(doc(as('prof'), 'attendance_sessions/s1/private/secret')));
    await assertFails(getDoc(doc(as('prof2'), 'attendance_sessions/s1/private/secret')));
  });

  test('a course professor opens a session and its secret in one batch', async () => {
    const db = as('prof');
    const batch = writeBatch(db);
    batch.set(doc(db, 'attendance_sessions/s2'), session());
    batch.set(doc(db, 'attendance_sessions/s2/private/secret'), { sessionSecret: 'abc' });
    await assertSucceeds(batch.commit());
  });

  test('session creation is checked', async () => {
    const db = as('prof');
    await assertFails(setDoc(doc(db, 'attendance_sessions/s3'), session({ status: 'closed' })));
    await assertFails(setDoc(doc(db, 'attendance_sessions/s3'), session({ professorId: 'prof2' })));
    await assertFails(setDoc(doc(db, 'attendance_sessions/s3'), session({ lectureId: 'l2' })));
    await assertFails(setDoc(doc(db, 'attendance_sessions/s3'), session({ sessionSecret: 'leak' })));
    await assertFails(setDoc(doc(db, 'attendance_sessions/s3'),
      session({ geofence: { latitude: 0, longitude: 0, radiusMeters: 0 } })));
    await assertFails(setDoc(doc(as('student'), 'attendance_sessions/s3'), session()));
  });

  test('secrets live only at private/secret', async () => {
    await assertFails(setDoc(doc(as('prof'), 'attendance_sessions/s1/private/other'),
      { sessionSecret: 'abc' }));
    await assertFails(setDoc(doc(as('prof'), 'attendance_sessions/s1/private/secret'),
      { sessionSecret: '' }));
  });

  test('course professors close sessions', async () => {
    await assertSucceeds(updateDoc(doc(as('prof'), 'attendance_sessions/s1'),
      { status: 'closed', closedAt: later }));
    await assertFails(updateDoc(doc(as('prof'), 'attendance_sessions/s1'), { courseId: 'c2' }));
    await assertFails(updateDoc(doc(as('student'), 'attendance_sessions/s1'), { status: 'closed' }));
  });
});

// ---------------------------------------------------- attendance records

describe('attendance records', () => {
  test('students read only their own records', async () => {
    await assertSucceeds(getDoc(doc(as('student'), 'attendance_records/s1_student')));
    await assertFails(getDoc(doc(as('student2'), 'attendance_records/s1_student')));
    await assertSucceeds(getDocs(query(collection(as('student'), 'attendance_records'),
      where('studentId', '==', 'student'))));
  });

  test('course professors read records filtered by course', async () => {
    await assertSucceeds(getDocs(query(collection(as('prof'), 'attendance_records'),
      where('courseId', '==', 'c1'), where('sessionId', '==', 's1'))));
    await assertFails(getDocs(query(collection(as('prof2'), 'attendance_records'),
      where('courseId', '==', 'c1'))));
  });

  test('students cannot check themselves in', async () => {
    await assertFails(setDoc(doc(as('student'), 'attendance_records/s1_student2'),
      qrRecord({ studentId: 'student2' })));
    await assertFails(updateDoc(doc(as('student'), 'attendance_records/s1_student'),
      { status: 'late' }));
  });

  test('course professors add manual records for enrolled students only', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'enrolments/student2_c1'), enrolment('student2', 'c1'));
    });
    const db = as('prof');
    await assertSucceeds(setDoc(doc(db, 'attendance_records/s1_student2'),
      manualRecord({ studentId: 'student2' })));
    await assertFails(setDoc(doc(db, 'attendance_records/s1_outsider'),
      manualRecord({ studentId: 'outsider' })));
    await assertFails(setDoc(doc(db, 'attendance_records/s1_student2'),
      manualRecord({ studentId: 'student2', correctedByProfessorId: 'prof2' })));
  });

  test('course professors correct records, flagged as manual', async () => {
    const db = as('prof');
    // A QR record must be flagged when it is corrected.
    await assertFails(updateDoc(doc(db, 'attendance_records/s1_student'), { status: 'absent' }));
    await assertSucceeds(updateDoc(doc(db, 'attendance_records/s1_student'), {
      status: 'late', isManualCorrection: true, correctedByProfessorId: 'prof', correctedAt: later,
    }));
    await assertFails(updateDoc(doc(as('prof2'), 'attendance_records/s1_student'), {
      status: 'late', isManualCorrection: true, correctedByProfessorId: 'prof2', correctedAt: later,
    }));
  });

  test('nobody deletes attendance records from a client', async () => {
    await assertFails(deleteDoc(doc(as('admin'), 'attendance_records/s1_student')));
    await assertFails(deleteDoc(doc(as('prof'), 'attendance_records/s1_student')));
  });
});

// --------------------------------------------------------------- default

test('unknown collections are denied', async () => {
  await assertFails(getDoc(doc(as('admin'), 'notifications/n1')));
  await assertFails(setDoc(doc(as('admin'), 'notifications/n1'), { body: 'x' }));
});

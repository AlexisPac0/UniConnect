// Seeds the UniConnect demo accounts: one Firebase Auth user and one
// users/{uid} profile per person (schema: docs/specs/firestore-data-model.md).
//
// Uses the Admin SDK, which bypasses firestore.rules: this is how the first
// admin gets created. Safe to run again: existing accounts are reused and
// their profile is updated (their password is left unchanged).
//
// The admin gets its own password, so that the password shared by the demo
// professors and students never gives admin access. Running against the real
// project needs --prod, to avoid seeding it by mistake:
//
//   GOOGLE_APPLICATION_CREDENTIALS=./service-account.json \
//   SEED_PASSWORD='...' ADMIN_SEED_PASSWORD='...' npm run seed:users -- --prod
//
// Against the emulators instead, set FIREBASE_AUTH_EMULATOR_HOST and
// FIRESTORE_EMULATOR_HOST (no credentials nor --prod needed).

import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? 'uniconnect-910ca';
const PASSWORD = process.env.SEED_PASSWORD;
const ADMIN_PASSWORD = process.env.ADMIN_SEED_PASSWORD;
const MIN_PASSWORD_LENGTH = 12;

function fail(message) {
  console.error(message);
  process.exit(1);
}

for (const [name, value] of [
  ['SEED_PASSWORD', PASSWORD],
  ['ADMIN_SEED_PASSWORD', ADMIN_PASSWORD],
]) {
  if (!value || value.length < MIN_PASSWORD_LENGTH) {
    fail(`Set ${name} (at least ${MIN_PASSWORD_LENGTH} characters).`);
  }
}
if (ADMIN_PASSWORD === PASSWORD) {
  fail('ADMIN_SEED_PASSWORD must differ from SEED_PASSWORD.');
}

const USERS = [
  { email: 'admin@uniconnect.test', displayName: 'Admin UniConnect', role: 'admin' },

  { email: 'prof.martin@uniconnect.test', displayName: 'Marko Martin', role: 'professor', department: 'Computer Science' },
  { email: 'prof.horvat@uniconnect.test', displayName: 'Ana Horvat', role: 'professor', department: 'Computer Science' },
  { email: 'prof.novak@uniconnect.test', displayName: 'Ivan Novak', role: 'professor', department: 'Mathematics' },

  { email: 'student1@uniconnect.test', displayName: 'Luka Kovač', role: 'student', studentNumber: 'STU-2026-0001', department: 'Computer Science' },
  { email: 'student2@uniconnect.test', displayName: 'Petra Babić', role: 'student', studentNumber: 'STU-2026-0002', department: 'Computer Science' },
  { email: 'student3@uniconnect.test', displayName: 'Marin Jurić', role: 'student', studentNumber: 'STU-2026-0003', department: 'Computer Science' },
  { email: 'student4@uniconnect.test', displayName: 'Ema Knežević', role: 'student', studentNumber: 'STU-2026-0004', department: 'Computer Science' },
  { email: 'student5@uniconnect.test', displayName: 'Filip Marić', role: 'student', studentNumber: 'STU-2026-0005', department: 'Mathematics' },
  { email: 'student6@uniconnect.test', displayName: 'Sara Pavlović', role: 'student', studentNumber: 'STU-2026-0006', department: 'Mathematics' },
];

const useEmulators =
  process.env.FIREBASE_AUTH_EMULATOR_HOST && process.env.FIRESTORE_EMULATOR_HOST;

if (!useEmulators && !process.argv.includes('--prod')) {
  fail(
    `Refusing to seed the real project ${PROJECT_ID} without --prod ` +
      '(npm run seed:users -- --prod), or set the emulator hosts.',
  );
}

initializeApp(
  useEmulators
    ? { projectId: PROJECT_ID }
    : { projectId: PROJECT_ID, credential: applicationDefault() },
);

const auth = getAuth();
const db = getFirestore();

async function ensureAuthUser({ email, displayName, role }) {
  try {
    const existing = await auth.getUserByEmail(email);
    return { uid: existing.uid, created: false };
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    const user = await auth.createUser({
      email,
      displayName,
      password: role === 'admin' ? ADMIN_PASSWORD : PASSWORD,
      emailVerified: true,
    });
    return { uid: user.uid, created: true };
  }
}

async function upsertProfile(uid, person) {
  const ref = db.collection('users').doc(uid);
  const snapshot = await ref.get();
  const profile = {
    id: uid,
    email: person.email,
    displayName: person.displayName,
    role: person.role,
    ...(person.studentNumber && { studentNumber: person.studentNumber }),
    ...(person.department && { department: person.department }),
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (snapshot.exists) {
    await ref.update(profile);
  } else {
    await ref.set({ ...profile, createdAt: FieldValue.serverTimestamp() });
  }
}

console.log(`Seeding ${USERS.length} users into ${PROJECT_ID}${useEmulators ? ' (emulators)' : ''}`);

for (const person of USERS) {
  const { uid, created } = await ensureAuthUser(person);
  await upsertProfile(uid, person);
  console.log(`${created ? 'created ' : 'updated '} ${person.role.padEnd(9)} ${person.email} (${uid})`);
}

console.log('Done.');

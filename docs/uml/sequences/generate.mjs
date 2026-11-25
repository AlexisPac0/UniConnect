// Dependency-free SVG and PlantUML generation from the same sequence definitions.
// Run: node docs/uml/sequences/generate.mjs
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const diagrams = [
  {
    id: 'login', title: 'Login and role-based navigation', status: 'Implemented flow on main (e8ffcf7)',
    participants: [
      ['U', 'User'], ['UI', 'LoginPage / LoginCubit'], ['D', 'Auth domain use cases'],
      ['R', 'AuthRepositoryImpl / FirebaseAuthDataSource'], ['A', 'Firebase Authentication'],
      ['S', 'SessionController / AppSession / Router'], ['P', 'GetUserProfile / Profile repository + data source'], ['F', 'Cloud Firestore'],
    ],
    steps: [
      ['note', 'Domain use cases depend on repository interfaces; concrete data implementations are injected.'],
      ['msg', 'U', 'UI', 'Submit email and password'],
      ['msg', 'UI', 'UI', 'Emit LoginSubmitting; show loading'],
      ['msg', 'UI', 'D', 'SignInWithEmail(SignInParams)'],
      ['alt', 'Empty email or password'],
      ['ret', 'D', 'UI', 'Failure(InvalidCredentialsFailure); show message'],
      ['else', 'Nonempty credentials (email is trimmed)'],
      ['msg', 'D', 'R', 'signInWithEmail(email, password)'],
      ['msg', 'R', 'A', 'signInWithEmailAndPassword'],
      ['alt', 'Authentication fails'],
      ['ret', 'A', 'R', 'Firebase error (credentials / disabled / network / rate limit)'],
      ['ret', 'R', 'D', 'Failure(AppFailure), no raw exception'],
      ['ret', 'D', 'UI', 'Failure; emit LoginFailure and show message'],
      ['else', 'Authentication succeeds'],
      ['ret', 'A', 'R', 'UserCredential'],
      ['ret', 'R', 'D', 'Success(AuthUser)'],
      ['ret', 'D', 'UI', 'Success; emit LoginSuccess (no navigation here)'],
      ['end'], ['end'],
      ['group', 'Independent auth-state subscription, established at startup'],
      ['msg', 'A', 'R', 'authStateChanges emits signed-in user'],
      ['msg', 'R', 'D', 'Mapped AuthUser through WatchAuthState'],
      ['msg', 'D', 'S', 'Auth-state event'],
      ['msg', 'S', 'S', 'setLoading; router shows splash'],
      ['msg', 'S', 'P', 'GetUserProfile(user.id) via repository interface'],
      ['msg', 'P', 'F', 'Read users/{uid}'],
      ['ret', 'F', 'P', 'Profile document or read error'],
      ['alt', 'Valid profile; this auth event is still current'],
      ['ret', 'P', 'S', 'Success(UserProfile)'],
      ['msg', 'S', 'S', 'setSignedIn with profile role; refresh router'],
      ['msg', 'S', 'U', 'Open student, professor, or admin home'],
      ['else', 'Missing / invalid profile or read failure'],
      ['ret', 'P', 'S', 'Failure(AppFailure)'],
      ['msg', 'S', 'S', 'setSignedOut(errorMessage); return to login'],
      ['msg', 'S', 'D', 'SignOut(NoParams)'],
      ['msg', 'D', 'R', 'signOut()'],
      ['msg', 'R', 'A', 'signOut()'],
      ['end'], ['end'],
      ['note', 'Auth events may arrive before sign-in returns. Stale profile loads are ignored; signed-out events preserve the error message.'],
    ],
  },
  {
    id: 'qr-check-in', title: 'QR attendance check-in', status: 'Proposed flow: SCRUM-38, 39, 40, 41',
    participants: [['U', 'Student'], ['UI', 'Scanner page / AttendanceCubit'], ['H', 'Camera / location adapter'],
      ['D', 'CheckInWithQrToken use case'], ['R', 'AttendanceRepositoryImpl / remote data source'],
      ['C', 'Firebase callable function'], ['F', 'Cloud Firestore']],
    steps: [
      ['note', 'Precondition: authenticated student; professor opened a session and displays a server-signed rotating QR token.'],
      ['msg', 'U', 'UI', 'Open scanner and scan QR'],
      ['msg', 'UI', 'H', 'Request camera and location permission; explain purpose'],
      ['alt', 'Permission denied or location unavailable'],
      ['ret', 'H', 'UI', 'Permission / location failure'],
      ['msg', 'UI', 'U', 'Explain how to retry; do not submit check-in'],
      ['else', 'QR scanned and location available'],
      ['ret', 'H', 'UI', 'sessionId, signed token, current coordinates'],
      ['msg', 'UI', 'D', 'Check in; show submitting state'],
      ['msg', 'D', 'R', 'checkInWithQrToken(sessionId, token, location)'],
      ['msg', 'R', 'C', 'Callable request with Firebase Auth context'],
      ['msg', 'C', 'C', 'Require authenticated student; derive uid from auth'],
      ['group', 'Server transaction: validation and record creation'],
      ['msg', 'C', 'F', 'Read session, lecture, user, enrolment and existing record'],
      ['ret', 'F', 'C', 'Authoritative state'],
      ['msg', 'C', 'C', 'Check open session, enrolment, signed token + expiry, geofence'],
      ['alt', 'Invalid token / closed session / wrong course / outside area'],
      ['ret', 'C', 'R', 'Typed rejection; no attendance write'],
      ['else', 'Valid request; record already exists'],
      ['ret', 'C', 'R', 'Return existing record; do not overwrite corrections'],
      ['else', 'Valid request; no record exists'],
      ['msg', 'C', 'F', 'Create attendance_records/{sessionId}_{uid}; server timestamp'],
      ['ret', 'F', 'C', 'Transaction committed'],
      ['ret', 'C', 'R', 'Attendance record'],
      ['end'], ['end'],
      ['ret', 'R', 'D', 'Success(AttendanceRecord) or Failure(AppFailure)'],
      ['ret', 'D', 'UI', 'Result; clear submitting state'],
      ['msg', 'UI', 'U', 'Confirm course / lecture, or show actionable error'],
      ['end'],
      ['note', 'Online confirmation required. Network failures are retryable; deterministic record IDs prevent duplicate attendance.'],
      ['note', 'Signing secrets stay server-side. GPS is client-reported evidence, not proof against location spoofing.'],
    ],
  },
  {
    id: 'lecture-change', title: 'Lecture change and push notification', status: 'Proposed flow: SCRUM-33 and SCRUM-35',
    participants: [['U', 'Professor'], ['UI', 'Lecture editor / Cubit'], ['D', 'Lecture change / read use cases'],
      ['R', 'TimetableRepositoryImpl / Firestore data source'], ['F', 'Cloud Firestore + rules'],
      ['C', 'Lecture-change Cloud Function'], ['M', 'Firebase Cloud Messaging'], ['S', 'Student device / app']],
    steps: [
      ['note', 'Preconditions: professor teaches the course; affected students have registered device tokens and enabled notifications.'],
      ['msg', 'U', 'UI', 'Change room / times, or cancel with optional reason'],
      ['msg', 'UI', 'D', 'Submit change; show loading'],
      ['msg', 'D', 'D', 'Validate required room and end after start for reschedule'],
      ['alt', 'Invalid input'],
      ['ret', 'D', 'UI', 'Failure; show validation message'],
      ['else', 'Valid input'],
      ['msg', 'D', 'R', 'rescheduleLecture(...) or cancelLecture(...)'],
      ['msg', 'R', 'F', 'Update lectures/{id}; enforce assigned-professor access'],
      ['alt', 'Permission denied or write fails'],
      ['ret', 'F', 'R', 'Write error'],
      ['ret', 'R', 'D', 'Failure(AppFailure)'],
      ['ret', 'D', 'UI', 'Failure; show error, no notification triggered'],
      ['else', 'Write committed'],
      ['ret', 'F', 'R', 'Committed lecture update'],
      ['ret', 'R', 'D', 'Success(Lecture) or Success(void)'],
      ['ret', 'D', 'UI', 'Show saved change (not a delivery receipt)'],
      ['group', 'Asynchronous notification after commit'],
      ['msg', 'F', 'C', 'Lecture update event: before / after / event ID'],
      ['msg', 'C', 'C', 'Ignore unchanged room, times and status; deduplicate retries'],
      ['msg', 'C', 'F', 'Query course enrolments and users.fcmTokens'],
      ['ret', 'F', 'C', 'Affected students and registration tokens'],
      ['msg', 'C', 'M', 'Send batched alert with lectureId and event ID'],
      ['ret', 'M', 'C', 'Per-token acceptance or send error'],
      ['msg', 'C', 'C', 'Remove invalid tokens; retry transient failures'],
      ['msg', 'M', 'S', 'Deliver notification when possible'],
      ['msg', 'S', 'S', 'Tap: session guard opens lecture details'],
      ['msg', 'S', 'D', 'Read current lecture through domain use case'],
      ['msg', 'D', 'R', 'Fetch authorized lecture details'],
      ['msg', 'R', 'F', 'Read lectures/{id} under security rules'],
      ['ret', 'F', 'R', 'Current lecture or access / network error'],
      ['ret', 'R', 'D', 'Result'],
      ['ret', 'D', 'S', 'Display current state or error'],
      ['end'], ['end'], ['end'],
      ['note', 'Push is best effort; delivery failure never rolls back the lecture. Firestore remains the source of truth.'],
    ],
  },
];

const esc = (s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
function wrap(text, limit) {
  const lines = [''];
  for (const word of text.split(' ')) {
    if (lines.at(-1).length && lines.at(-1).length + word.length + 1 > limit) lines.push('');
    lines[lines.length - 1] += (lines.at(-1) ? ' ' : '') + word;
  }
  return lines;
}

for (const d of diagrams) {
  const gap = 240, width = (d.participants.length - 1) * gap + 260;
  const xs = Object.fromEntries(d.participants.map(([id], i) => [id, 130 + i * gap]));
  let y = 215, count = 0, depth = 0;
  const shapes = [], frames = [], stack = [];
  const text = (x, yy, value, anchor = 'middle', color = '#18324b', size = 15) =>
    `<text x="${x}" y="${yy}" text-anchor="${anchor}" fill="${color}" font-size="${size}">${esc(value)}</text>`;
  const puml = ['@startuml', 'hide footbox', 'skinparam shadowing false', 'skinparam sequenceMessageAlign center', 'skinparam maxMessageSize 100', `title ${d.title}`, 'autonumber'];
  for (const [id, label] of d.participants) puml.push(`participant "${label}" as ${id}`);
  for (const [kind, a, b, label] of d.steps) {
    if (kind === 'note') {
      const lines = wrap(a, Math.floor((width - 150) / 8));
      shapes.push(`<rect x="45" y="${y - 18}" width="${width - 90}" height="${lines.length * 22 + 15}" rx="5" fill="#fff5ce" stroke="#d6bd68"/>`);
      lines.forEach((line, i) => shapes.push(text(width / 2, y + i * 22, line)));
      y += lines.length * 22 + 30;
      puml.push(`note over ${d.participants[0][0]}, ${d.participants.at(-1)[0]}: ${a}`);
    } else if (kind === 'alt' || kind === 'group') {
      stack.push({ y: y - 16, depth: depth++ });
      shapes.push(text(38 + depth * 8, y + 5, `${kind === 'alt' ? 'alt' : 'group'} [${a}]`, 'start', '#34537a'));
      y += 46; puml.push(`${kind} ${a}`);
    } else if (kind === 'else') {
      shapes.push(`<path d="M 30 ${y - 16} H ${width - 30}" stroke="#90a4b8" stroke-dasharray="5 4"/>`);
      shapes.push(text(46 + depth * 8, y + 5, `[${a}]`, 'start', '#34537a'));
      y += 46; puml.push(`else ${a}`);
    } else if (kind === 'end') {
      const f = stack.pop(); if (!f) throw new Error('Unmatched end');
      depth--;
      frames.push(`<rect x="${24 + f.depth * 8}" y="${f.y}" width="${width - 48 - f.depth * 16}" height="${y - f.y}" fill="none" stroke="#90a4b8"/>`);
      y += 22; puml.push('end');
    } else {
      if (!(a in xs) || !(b in xs)) throw new Error('Unknown participant');
      const x1 = xs[a], x2 = xs[b], self = a === b;
      const selfLeft = self && x1 + 210 > width - 25;
      const lines = wrap(`${++count}. ${label}`, Math.max(22, Math.floor((self ? 210 : Math.abs(x2 - x1) - 24) / 7.8)));
      const lineY = y + lines.length * 20;
      lines.forEach((line, i) => shapes.push(text(self ? x1 + (selfLeft ? -10 : 10) : (x1 + x2) / 2, y + i * 20, line, self ? (selfLeft ? 'end' : 'start') : 'middle')));
      shapes.push(`<path d="${self ? `M ${x1} ${lineY} h ${selfLeft ? -190 : 190} v 18 h ${selfLeft ? 190 : -190}` : `M ${x1} ${lineY} H ${x2}`}" fill="none" stroke="#254c72" stroke-width="1.5" ${kind === 'ret' ? 'stroke-dasharray="6 4"' : ''} marker-end="url(#arrow)"/>`);
      y = lineY + (self ? 52 : 36);
      puml.push(`${a} ${kind === 'ret' ? '-->' : '->'} ${b}: ${label}`);
    }
  }
  if (stack.length) throw new Error('Unclosed fragment');
  const height = y + 35;
  const headers = d.participants.map(([id, label]) => {
    const lines = wrap(label, 25);
    return `<path d="M ${xs[id]} 185 V ${height - 20}" stroke="#bdc8d3" stroke-dasharray="6 6"/><rect x="${xs[id] - 110}" y="100" width="220" height="85" rx="5" fill="#eaf1fa" stroke="#6586a8"/>` + lines.map((l, i) => text(xs[id], 125 + i * 19, l)).join('');
  }).join('');
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 Z" fill="#254c72"/></marker></defs><rect width="100%" height="100%" fill="white"/><g font-family="Arial, sans-serif">${text(35, 40, d.title, 'start', '#132d48', 27)}${text(35, 72, d.status, 'start', '#536a80', 17)}${headers}${frames.join('')}${shapes.join('')}</g></svg>`;
  const dir = fileURLToPath(new URL('.', import.meta.url));
  writeFileSync(`${dir}${d.id}.svg`, svg);
  writeFileSync(`${dir}${d.id}.puml`, puml.concat('@enduml', '').join('\n'));
  console.log(`${d.id}: ${count} messages, ${width} x ${height}`);
}

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

export const branchFormat = '<prefix>/SCRUM-<positive-number>-<lowercase-hyphenated-description>';
export const commitFormat = '<type>: <description> (SCRUM-<positive-number>)';
export const validBranch = (value) => /^(feature|feat|fix|docs|refactor|test|chore)\/SCRUM-[1-9]\d*-[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value);
export const validSubject = (value) => /^(feat|fix|docs|refactor|test|chore): \S(?:[^\r\n]*\S)? \(SCRUM-[1-9]\d*\)$/.test(value);

export function eventRange(eventName, event) {
  let base;
  let head;
  if (eventName === 'pull_request') {
    base = event.pull_request.base.sha;
    head = event.pull_request.head.sha;
  } else if (eventName === 'push') {
    base = event.before;
    head = event.after;
  } else {
    throw new Error(`Unsupported event: ${eventName}`);
  }
  if (![base, head].every((sha) => /^[a-f0-9]{40}$/.test(sha) && !/^0+$/.test(sha))) {
    throw new Error('Expected existing base and head commit SHAs; cannot validate this range.');
  }
  return { base, head };
}

export function introducedCommits(base, head, cwd = process.cwd()) {
  const git = (...args) => execFileSync('git', args, { cwd, encoding: 'utf8' });
  // Two-dot reachability excludes all commits already present on the base.
  const shas = git('rev-list', '--no-merges', `${base}..${head}`, '--').trim();
  return shas ? shas.split(/\r?\n/).map((sha) => ({
    sha,
    subject: git('show', '-s', '--format=%s', sha, '--').replace(/\r?\n$/, ''),
  })) : [];
}

function main() {
  const eventName = process.env.GITHUB_EVENT_NAME;
  const event = JSON.parse(readFileSync(process.env.GITHUB_EVENT_PATH, 'utf8'));
  const mode = process.argv[2];
  if (mode === 'branch') {
    if (eventName === 'push' && event.ref === 'refs/heads/main') {
      console.log('main is exempt from ticket branch naming.');
      return;
    }
    if (eventName !== 'pull_request') throw new Error('Expected a pull request or a push to main.');
    const branch = event.pull_request.head.ref;
    if (!validBranch(branch)) {
      throw new Error(`Invalid branch ${JSON.stringify(branch)}. Expected ${branchFormat}; prefixes: feature, feat, fix, docs, refactor, test, chore.`);
    }
    console.log('Branch naming passed.');
  } else if (mode === 'commits') {
    const { base, head } = eventRange(eventName, event);
    const commits = introducedCommits(base, head);
    const invalid = commits.filter(({ subject }) => !validSubject(subject));
    for (const { sha, subject } of invalid) {
      console.error(`Invalid commit ${sha}: ${JSON.stringify(subject)}`);
    }
    if (invalid.length) {
      throw new Error(`Expected ${commitFormat}; types: feat, fix, docs, refactor, test, chore.`);
    }
    console.log(`Commit conventions passed (${commits.length} non-merge commits checked).`);
  } else {
    throw new Error('Usage: node check-conventions.mjs branch|commits');
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    main();
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

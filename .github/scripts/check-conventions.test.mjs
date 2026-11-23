import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, sep } from 'node:path';
import test from 'node:test';
import { eventRange, introducedCommits, validBranch, validSubject } from './check-conventions.mjs';

test('branch prefixes and malformed names', () => {
  for (const prefix of ['feature', 'feat', 'fix', 'docs', 'refactor', 'test', 'chore']) {
    assert.equal(validBranch(`${prefix}/SCRUM-16-set-up-ci-pipeline`), true);
  }
  for (const value of ['main', 'chore/setup-ci', 'build/SCRUM-16-ci', 'Feature/SCRUM-16-ci',
    'feat/SCRUM-0-ci', 'feat/SCRUM-16-CI', 'feat/SCRUM-16-ci_setup',
    'feat/SCRUM-16-ci--setup', 'feat/SCRUM-16-ci-', 'feat/SCRUM-16-']) {
    assert.equal(validBranch(value), false, value);
  }
});

test('commit types and malformed subjects', () => {
  for (const type of ['feat', 'fix', 'docs', 'refactor', 'test', 'chore']) {
    assert.equal(validSubject(`${type}: add checks (SCRUM-16)`), true);
  }
  for (const value of ['feat: add checks', 'feature: add checks (SCRUM-16)',
    'feat(scope): add checks (SCRUM-16)', 'fix:  (SCRUM-16)', 'fix:    (SCRUM-16)',
    'fix: add checks (SCRUM-0)', 'fix: add checks (scrum-16)',
    'fix: add checks (SCRUM-16) trailing']) {
    assert.equal(validSubject(value), false, value);
  }
});

test('event ranges use PR endpoints or push before/after and fail closed', () => {
  const base = 'a'.repeat(40);
  const head = 'b'.repeat(40);
  assert.deepEqual(eventRange('pull_request', { pull_request: { base: { sha: base }, head: { sha: head } } }), { base, head });
  assert.deepEqual(eventRange('push', { before: base, after: head }), { base, head });
  assert.throws(() => eventRange('push', { before: '0'.repeat(40), after: head }));
  assert.throws(() => eventRange('push', { before: '--all', after: head }));
  assert.throws(() => eventRange('workflow_dispatch', {}));
});

test('real Git history excludes main and merges, catches earlier bad commits, and allows bodies', (t) => {
  const root = resolve(tmpdir());
  const cwd = mkdtempSync(join(root, 'uniconnect-policy-'));
  t.after(() => {
    assert.ok(resolve(cwd).startsWith(root + sep));
    rmSync(cwd, { recursive: true, force: true });
  });
  const git = (...args) => execFileSync('git', args, { cwd, encoding: 'utf8' }).trim();
  const commit = (...messages) => git('-c', 'user.name=Policy Test', '-c',
    'user.email=policy@example.invalid', '-c', 'commit.gpgsign=false',
    'commit', '--allow-empty', ...messages.flatMap((message) => ['-m', message]));
  git('init', '--initial-branch=main');
  commit('legacy main subject');
  git('checkout', '-b', 'chore/SCRUM-16-ci');
  commit('invalid earlier commit');
  const invalidSha = git('rev-parse', 'HEAD');
  commit('docs: add checks (SCRUM-16)', 'Optional body with details.');
  git('checkout', 'main');
  commit('another legacy main subject');
  const base = git('rev-parse', 'HEAD');
  git('checkout', 'chore/SCRUM-16-ci');
  git('-c', 'user.name=Policy Test', '-c', 'user.email=policy@example.invalid',
    '-c', 'commit.gpgsign=false', 'merge', '--no-ff', 'main', '-m', 'Merge main');
  const head = git('rev-parse', 'HEAD');
  const commits = introducedCommits(base, head, cwd);
  assert.equal(commits.length, 2);
  assert.deepEqual(commits.filter(({ subject }) => !validSubject(subject)).map(({ sha }) => sha), [invalidSha]);
  assert.deepEqual(introducedCommits(head, head, cwd), []);
});

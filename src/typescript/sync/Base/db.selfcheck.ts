// ponytail-style assert-based self-checks for db.ts, runnable without Yjs
// providers, Dexie or a browser:
//   node src/typescript/sync/Base/db.selfcheck.ts
//
// 1. Owner-token verification as done by `CRDT.claimOwnership` /
//    `resolveOwnerToken` - a pure local hash comparison via the same
//    `peerCrypto` primitives db.ts uses.
// 2. `setArrayValue` (yArray.ts), the single write path for quiz/survey
//    answers: answering a later question before an earlier one must pad
//    with holes instead of throwing (Yjs rejects `undefined` content).
// 3. `coalesce` (coalesce.ts), which serializes the quiz/survey re-dump
//    behind every CRDT observer: a burst of triggers during one run must
//    collapse into exactly one follow-up run, and runs must never overlap
//    (an older async snapshot could otherwise land after a newer one).

import * as Y from 'yjs'
import { sha256Base64, randomBytesBase64 } from './peerCrypto.ts'
import { setArrayValue } from './yArray.ts'
import { coalesce } from './coalesce.ts'

function assert(cond: boolean, message: string) {
  if (!cond) throw new Error('FAILED: ' + message)
  console.log('ok -', message)
}

/** Mirrors `CRDT.resolveOwnerToken`'s verification step. */
async function verifies(token: string, expectedHash: string): Promise<boolean> {
  if (!token || !expectedHash) return false
  return (await sha256Base64(token)) === expectedHash
}

/** Mirrors the hole-skipping read in `CRDT.getSection`. */
function answered(section: Y.Array<any>): number[] {
  const idx: number[] = []
  for (let qi = 0; qi < section.length; qi++) {
    if (section.get(qi) != null) idx.push(qi)
  }
  return idx
}

async function main() {
  const token = randomBytesBase64(32)
  const hash = await sha256Base64(token)

  assert(await verifies(token, hash), 'correct token -> verified')
  assert(
    !(await verifies('not-the-right-token', hash)),
    'wrong token -> rejected'
  )
  assert(!(await verifies('', hash)), 'empty token -> rejected')
  assert(!(await verifies(token, '')), 'no known hash yet -> rejected')
  assert(
    randomBytesBase64(32) !== token,
    'randomBytesBase64 produces distinct values'
  )

  const section = new Y.Doc().getArray<any>('q')
  setArrayValue(section, 2, { trial: 1 })
  assert(section.length === 3, 'writing index 2 first pads to length 3')
  assert(answered(section).join() === '2', 'padding reads as unanswered')
  setArrayValue(section, 0, { trial: 2 })
  setArrayValue(section, 2, { trial: 3 })
  assert(
    answered(section).join() === '0,2',
    'filling a hole and overwriting keep other indices'
  )
  assert(
    section.get(2).trial === 3 && section.get(0).trial === 2,
    'overwrite replaces in place'
  )
  assert(section.get(1) === null, 'hole stays null')

  let runs = 0
  let inFlight = 0
  let overlapped = false
  let release: () => void = () => {}
  const schedule = coalesce(() => {
    runs++
    inFlight++
    if (inFlight > 1) overlapped = true
    return new Promise<void>(resolve => {
      release = () => {
        inFlight--
        resolve()
      }
    })
  })
  const tick = () => new Promise(r => setTimeout(r, 0))
  schedule()
  schedule()
  schedule()
  assert(runs === 1, 'triggers during a run do not start a second run')
  release()
  await tick()
  assert(runs === 2, 'a burst collapses into exactly one follow-up run')
  release()
  await tick()
  assert(runs === 2, 'no third run without a new trigger')
  assert(!overlapped, 'runs never overlap')

  // Watchdog: a job that never settles must not stall every later trigger
  // forever - after `stallMs` the scheduler reports it and accepts the next
  // trigger again.
  let stalledRuns = 0
  let stallReports = 0
  let settleFirst: () => void = () => {}
  const guarded = coalesce(
    () =>
      new Promise<void>(resolve => {
        stalledRuns++
        if (stalledRuns === 1) settleFirst = resolve
        else resolve()
      }),
    { stallMs: 20, onStall: () => stallReports++ }
  )
  guarded()
  guarded()
  assert(
    stalledRuns === 1,
    'watchdog: first run started, second trigger only marked dirty'
  )
  await new Promise(r => setTimeout(r, 60))
  assert(
    stallReports === 1,
    'watchdog: a run exceeding stallMs is reported once'
  )
  assert(
    stalledRuns === 2,
    'watchdog: the pending trigger runs after the stall'
  )
  settleFirst()
  await tick()
  assert(
    stalledRuns === 2,
    'watchdog: the late settle of a stalled run starts nothing'
  )

  console.log('\nall checks passed')
}

main().catch(e => {
  console.error(e)
  process.exit(1)
})

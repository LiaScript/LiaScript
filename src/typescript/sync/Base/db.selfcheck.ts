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

import * as Y from 'yjs'
import { sha256Base64, randomBytesBase64 } from './peerCrypto.ts'
import { setArrayValue } from './yArray.ts'

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

  console.log('\nall checks passed')
}

main().catch(e => {
  console.error(e)
  process.exit(1)
})

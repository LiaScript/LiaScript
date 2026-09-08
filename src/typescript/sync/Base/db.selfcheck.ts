// ponytail-style assert-based self-check for the owner-token verification
// used by `CRDT.claimOwnership` (see the classroom owner-token design doc,
// docs/superpowers/specs/2026-09-02-classroom-owner-token-design.md).
//
// Ownership has no CRDT claim log any more - `claimOwnership(token,
// expectedHash)` is a pure local hash comparison. This exercises exactly
// that comparison via the same `peerCrypto` primitives db.ts uses, without
// needing Yjs or a browser. Run directly with:
//   node src/typescript/sync/Base/db.selfcheck.ts

import { sha256Base64Url, generateToken } from './peerCrypto.ts'

function assert(cond: boolean, message: string) {
  if (!cond) throw new Error('FAILED: ' + message)
  console.log('ok -', message)
}

/** Mirrors `CRDT.claimOwnership`'s verification step. */
async function verifies(token: string, expectedHash: string): Promise<boolean> {
  if (!token || !expectedHash) return false
  return (await sha256Base64Url(token)) === expectedHash
}

async function main() {
  const token = generateToken()
  const hash = await sha256Base64Url(token)

  assert(await verifies(token, hash), 'correct token -> verified')
  assert(!(await verifies('not-the-right-token', hash)), 'wrong token -> rejected')
  assert(!(await verifies('', hash)), 'empty token -> rejected')
  assert(!(await verifies(token, '')), 'no known hash yet -> rejected')

  const otherToken = generateToken()
  assert(otherToken !== token, 'generateToken produces distinct values')

  console.log('\nall checks passed')
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})

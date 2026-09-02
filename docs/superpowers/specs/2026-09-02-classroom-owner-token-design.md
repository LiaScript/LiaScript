# Classroom Owner-Token & Password-Check Design

**Goal:** Replace the silent, automatic "earliest connect wins" owner claim with an explicit opt-in, and make ownership provably tied to a shareable secret token so a random peer can no longer end up as owner just by connecting first or by racing a reconnect. Separately, let a peer with the wrong classroom password find out immediately instead of waiting on the existing 3-second "no other peers" heuristic.

**Non-goals:** True simultaneous co-owners (two peers holding owner rights at the same time). At any moment there is still exactly one owner, matching the existing single-`ownerKey` encryption model (`rewrapForCurrentOwner`, `Base/db.ts:683-699`) — the token only controls *who is allowed to become* that one owner, including taking over from a previous holder. This is a deliberate scope cut; true multi-owner would require wrapping content keys for multiple owner public keys and is out of scope unless asked for.

## Background (current behavior)

- `Base/index.ts:363` calls `this.db.claimOwnership()` unconditionally ~3s after every connect (`sendConnect()`, `index.ts:326-365`). No UI confirmation exists.
- `Base/db.ts:897-919` `claimOwnership()`/`getOwner()`: claims are pushed into a Yjs `metadata: Y.Array<string>` as `"<peerID>@<claimedAt>"`; the earliest `claimedAt` timestamp wins, resolving Yjs's own arbitrary per-doc-clientID tie-break.
- `Session.elm:202-227` `encodeRoom`/`decodeRoom` puts `{backend, course, room, mode}` into the URL as base64 JSON. Password is deliberately excluded today.
- `Base/index.ts:267-296` `uniqueID()` mixes `helper.getHashCode(password)` into a compound hash together with course/room/mode to select the network room bucket — a wrong password lands a peer in a different, empty room, not an error.
- `Base/index.ts:341-361`: since a wrong password just produces an empty room, there's a heuristic — if no other peer shows up ~3s after connecting and a password is set, show a warning. This stays as a fallback.
- Password already gates real access, not just an "owner" convenience: it feeds room-bucket isolation (`uniqueID`) and transport encryption (`security.ts` `wrapTransport()`, password-keyed via `Crypto.ts`).

## 1. Owner claim: token-gated, explicit

### Data model change

Extend the claim string format from `"<peerID>@<claimedAt>"` to `"<peerID>@<claimedAt>@<tokenHash>"`. `parseClaim` (`db.ts:890-895`) gets a third optional field; a claim without a `tokenHash` segment (pre-existing data, or malformed) is treated as `tokenHash: null` and can never match a token-gated founding claim — it simply can't be taken over anymore, which is an acceptable, non-migrated transitional edge case (classroom rooms are short-lived; a reconnect already resets classroom config per the existing comment at `db.ts:643-646`).

`tokenHash` = `SHA-256(token)` (Web Crypto, `crypto.subtle.digest`, consistent with the existing crypto primitives already in `peerCrypto.ts`), full digest, base64url-encoded, no padding. The plaintext token itself is 16 random bytes (`crypto.getRandomValues`), base64url-encoded — short enough to paste into a text field or read aloud. The plaintext token is never written into the Yjs doc, only its hash — anyone already in the room can already read `metadata` (they have room access), but should not be able to lift a copy-pasteable owner credential straight out of the CRDT.

### `claimOwnership(providedToken?: string)`

```
claims = metadata.toArray().map(parseClaim)

if (peerID already in claims) return   // no-op, already claimed once

if (claims.length === 0) {
  token = providedToken || generateToken()     // crypto.getRandomValues, base64url
  push(`${peerID}@${now}@${sha256(token)}`)
  this.ownerToken = token                       // remember locally, plaintext
} else {
  founding = claims.reduce(earliest by ts)
  if (!providedToken || sha256(providedToken) !== founding.tokenHash) return  // rejected
  push(`${peerID}@${now}@${founding.tokenHash}`)
  this.ownerToken = providedToken
}

callback(getOwner() === peerID, 'ownership')   // unchanged shape question, see below
```

### `getOwner()` change

Today: earliest claim, full stop (`db.ts:915-919` and beyond). New:

```
founding = claims.reduce(earliest by ts)                      // defines the canonical token
holders  = claims.filter(c => c.tokenHash === founding.tokenHash)
return holders.reduce(latest by ts).id                        // most recent legitimate holder
```

The founding (first-ever, unguarded) claim still wins any race for an empty room exactly as today — two concurrent first-claims each mint their own token, and only the genuinely earliest of those becomes canonical; the later one has a non-matching token and is excluded. Once a founding token exists, only claims carrying that same token can ever become (or take back) the owner — this is what stops an unrelated peer from claiming the slot, and lets a token holder (original owner after reconnect, or a co-teacher who received the token) become the current owner later.

Owner **handoff over time** (new peer becomes owner because it holds the token) reuses the existing per-room-transferable encryption machinery unchanged: `maybeBecomeOwner()` (`db.ts:664-679`) already generates/announces a fresh keypair whenever `getOwner() === this.peerID` and no cached keypair exists yet, and every peer already re-wraps its content key on `ownerKey` changes (`rewrapForCurrentOwner`, `db.ts:683-699`). No changes needed there.

### UI (Elm)

- `Lia.Sync.Types.Settings` gets a new field `ownerToken : String`.
- `Lia.Sync.View` gets a text field bound to it (same section as the password field, `View.elm:120-160`) plus a "Claim Ownership" button.
- Button click sends a new event `Service.Sync.claimOwnership course room backend token` (mirrors the existing `markOwner` event shape in `Service/Sync.elm:179-180`).
- The existing `"ownership"` TS→Elm event (`Update.elm:809-830`) payload changes from a bare bool to `{ owner: Bool, token: Maybe String }` so a freshly generated token can be pushed into the `ownerToken` field for display/copy. `markOwner` persistence (`Classroom.elm` `Entry`) gains a `token : Maybe String` field alongside the existing `owner : Bool`, so a returning owner (reopening via the saved-classrooms list rather than a URL) doesn't need the link.

### URL

`Session.Room` gains an optional `ownerToken : Maybe String` field; `encodeRoom`/`decodeRoom` (`Session.elm:202-227`) include it when present. Only ever set into the URL for a peer that currently holds the token (i.e., the owner's own browser) — `Session.setClass` already only writes the URL after a successful `"connect"`/`"ownership"` update (`Lia/Sync/Update.elm:185-207`), so this slots into the same place. On load, a present `ownerToken` pre-fills the Settings field but does **not** auto-claim — the button click is still the explicit consent step. This satisfies "shareable manually or via URL" without silently granting ownership just from opening a link.

## 2. Password check via URL (`pwCheck`)

**Security note — read before implementing:** this was explicitly discussed and the risk was consciously accepted, not overlooked. A hash of the password published in the URL turns password verification from an online, rate-limited guess (current 3s-heuristic, requires a live connection) into a free, offline, unlimited oracle. This holds regardless of hash choice — `getHashCode` (32-bit, non-cryptographic) is broken in milliseconds; SHA-256 is not meaningfully better since it has no salt/cost factor and is designed to be fast, and typical classroom passwords (short codes/words) have too little entropy for a cost factor to matter anyway. The password is real access control here (feeds `uniqueID()` room-bucket isolation and `wrapTransport()` transport encryption), so this is a genuine, understood weakening of that control for anyone who obtains the link — not just a cosmetic hint.

```
ponytail: pwCheck exposes an offline password-verification oracle in the
URL; accepted because classroom passwords are treated as low-stakes
room-selectors, not real credentials. Upgrade path if that assumption
stops holding: drop pwCheck, do a live in-band check instead (attempt to
decrypt/read something inside the room right after connect using the
locally-typed password; wrong password → decrypt fails → instant
feedback with nothing static published in the URL).
```

### Implementation

- New optional URL parameter/field on `Session.Room`: `pwCheck : Maybe String` (SHA-256 of the password, full digest, base64url-encoded, no padding — chosen over reusing `getHashCode` per discussion, since we're already pulling in Web Crypto for the owner token and `getHashCode`'s 32-bit output makes accidental collisions somewhat more likely on top of the accepted oracle risk).
- Set whenever the owner has a password configured, alongside `ownerToken`, same place in `Session.setClass`.
- On load, before attempting to connect: if `pwCheck` is present and the locally-entered password's hash doesn't match, show the warning immediately (reuse the existing `sendWarning`/`'warning'` channel, `index.ts:322-324`) instead of waiting for the 3-second heuristic. The heuristic (`index.ts:341-361`) stays as-is for links without `pwCheck` (e.g. pre-existing shared links).

## Error handling

- `claimOwnership()` with a wrong/missing token when a founding claim already exists: silent no-op (already the existing pattern for "claim already exists" — no error surfaced, the button just doesn't do anything visible beyond "you're still not owner"). Consider a short inline UI hint ("token doesn't match") — left to implementation, not a protocol-level concern.
- Legacy claims without a `tokenHash` segment: permanently un-take-over-able under the new scheme (see Data model change above) — acceptable, not handled further.
- `pwCheck` absent (old links, or no password set): behavior is exactly today's — heuristic-only / no password.

## Testing

- Elm: `encodeRoom`/`decodeRoom` roundtrip with `ownerToken`/`pwCheck` present and absent (`tests/`, following existing `Session`-adjacent test patterns if any exist, otherwise a new small module).
- TS: no existing unit-test harness in this repo (per `docs/superpowers/plans/2026-07-27-persistent-classrooms.md`'s stated constraint) — verify `getOwner()`/`claimOwnership()` token logic via a small `assert`-based self-check (ponytail demo-style) covering: empty room → claim wins; foreign claim without matching token → rejected; claim with correct token → takeover; legacy claim (no tokenHash) → not take-over-able. Otherwise rely on type-correctness + manual exercise via `npm run watch`, matching this repo's established TS verification approach.

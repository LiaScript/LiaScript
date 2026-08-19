// Note on the type-only import below: `y-generic`'s package.json `exports`
// map only publishes `.` and `./providers/*` as valid subpaths - there is no
// `./dist/transport` entry. Importing from the package root works because
// `dist/lib.d.ts` (the `.` types entry) re-exports `Transport` and
// `ConnectionConfig` from `./transport` itself. Since this repo has no
// tsconfig.json, Parcel's TS transform erases `import type` entirely before
// bundling anyway, so this import never survives into the runtime bundle -
// but unlike `'y-generic/dist/transport'`, this specifier actually resolves.
import type { Transport, ConnectionConfig } from 'y-generic'
import Database from '../../liascript/service/Database'

/* Message types used by `GenericProvider`, see the `MESSAGE_*` constants in
 * `y-generic/dist/index.js`. */
const MESSAGE_SYNC = 0
const MESSAGE_AWARENESS = 1
const MESSAGE_PUBSUB = 2

/** Sub-type of a `MESSAGE_SYNC` frame, see `y-protocols/sync`. A SyncStep1 is
 * only a *request* for missing updates, it carries no document data. */
const SYNC_STEP1 = 0

/** Read one `lib0/encoding` varuint out of `data`, starting at `offset`.
 *
 * @returns `[value, offsetAfterValue]`, or `null` if the buffer ends within
 *          the number, or if it is not a well-formed varuint.
 */
function readVarUint(
  data: Uint8Array,
  offset: number
): [number, number] | null {
  let num = 0
  let mult = 1
  let i = offset

  while (i < data.length) {
    const byte = data[i++]
    num += (byte & 0b01111111) * mult

    if (byte < 0b10000000) return [num, i]

    mult *= 128

    // a varuint over 5 bytes cannot be a valid message-type
    if (i - offset > 5) return null
  }

  return null
}

/** Decide whether one outgoing frame has to be written to the local cache.
 *
 * `GenericProvider` pushes its *entire* wire protocol through the transport,
 * not only document updates: a SyncStep1 request every `syncInterval` (5s by
 * default), an awareness broadcast whenever presence changes, and pub/sub
 * messages. For a network transport that is correct — but this transport is a
 * local *cache*, and none of those frames carry CRDT state:
 *
 * - awareness is per-session presence. Replaying it resurrects the client-IDs
 *   of long-gone sessions as phantom peers.
 * - pub/sub messages are ephemeral by definition.
 * - a replayed SyncStep1 makes the provider answer with a fresh SyncStep2,
 *   which the transport then stores again — so every reconnect multiplied the
 *   number of rows (measured: 30 -> 81 -> 171 -> 239 rows for a document that
 *   contained a single chat message).
 *
 * Anything that is not positively identified as ephemeral is kept, so that an
 * unknown/future message type can never silently lose data.
 *
 * @param frame - a CRC32-prefixed frame as produced by `GenericProvider._send`
 */
function carriesDocumentState(frame: Uint8Array): boolean {
  // `_send()` prefixes every frame with a 4 byte CRC32 checksum
  const head = readVarUint(frame, 4)

  if (head === null) return true

  const [type, next] = head

  if (type === MESSAGE_AWARENESS || type === MESSAGE_PUBSUB) return false

  // MESSAGE_SYNC_VERIFIED (and any future type) always carries an update
  if (type !== MESSAGE_SYNC) return true

  const sub = readVarUint(frame, next)

  return sub === null || sub[0] !== SYNC_STEP1
}

/** A Yjs transport that persists updates as rows inside the already-open,
 * already-approved per-course Dexie database, instead of opening a brand new
 * raw IndexedDB database (which the project's Dexie security-guard patch
 * would treat as an unknown external script and gate behind a confirm()
 * dialog, see `sync/Base/persist.ts`).
 */
export class DexieTransport implements Transport {
  private uidDB: string = ''
  private key: string = ''
  private messageCallback?: (data: Uint8Array) => void
  private _isConnected: boolean = false

  // Updates loaded from Dexie during `connect()`, buffered here until they
  // can be replayed - see `replayIfReady()`.
  private pendingUpdates: Uint8Array[] = []

  // `replayIfReady()` must run exactly once, whichever of `connect()` /
  // `onMessage()` finishes second - `GenericProvider.connect()` actually
  // calls `onMessage()` *before* awaiting `transport.connect()` (see
  // `y-generic/dist/index.js`, `GenericProvider.connect`), so `connect()`
  // cannot assume a listener is already attached, and `onMessage()` cannot
  // assume `pendingUpdates` is already loaded.
  private replayed: boolean = false

  /** Compaction latch, see `armCompaction()`. */
  private compactOnNextSend: boolean = false

  get isConnected(): boolean {
    return this._isConnected
  }

  /** Arm the one-shot cache compaction.
   *
   * Without this, the cache only ever grows: every `connect()` makes
   * `GenericProvider.connect()` call `syncNow()`, which pushes a *full*
   * `Y.encodeStateAsUpdate(doc)` through the transport - so each connect (and
   * each BroadcastChannel exchange between two tabs of the same classroom)
   * adds another document-sized row that is never merged or pruned. Given
   * enough reconnects that runs into the IndexedDB storage quota, and
   * `GenericProvider._send()` only `console.error`s a rejected write, so the
   * resulting data loss would be silent.
   *
   * The compaction is safe *only* at this exact point: this method is called
   * at the very end of `replayIfReady()`, i.e. after every cached row has
   * been replayed into the document. Whatever those rows contained is
   * therefore part of the document now, and the next frame the provider
   * sends is `syncNow()`'s full snapshot of exactly that document - a single
   * row that is equivalent to all of them. `replaceYjsUpdates()` swaps them
   * in one transaction, so there is no window in which the cache is empty.
   *
   * The latch is deliberately scoped to the current task:
   * `GenericProvider.connect()` runs `transport.connect()` (which is where
   * `replayIfReady()` fires, once `_isConnected` and `messageCallback` are
   * both set) -> `syncNow()` -> `_sendUpdate()` -> `_send()` ->
   * `transport.send()` without a single `await` in between, so the snapshot
   * is guaranteed to be seen while the latch is set. The `queueMicrotask()`
   * disarm makes sure that if that push ever *doesn't* happen (e.g. a future
   * version rate-limits it away), a later *incremental* update can never be
   * mistaken for a full snapshot and wipe the cache.
   */
  private armCompaction() {
    this.compactOnNextSend = true

    queueMicrotask(() => {
      this.compactOnNextSend = false
    })
  }

  async connect(config: ConnectionConfig): Promise<void> {
    this.uidDB = config.uidDB
    this.key = config.room

    this.pendingUpdates = await Database.getYjsUpdates(this.uidDB, this.key)

    this._isConnected = true
    this.replayIfReady()
  }

  disconnect(): void {
    this._isConnected = false
    this.messageCallback = undefined
    this.pendingUpdates = []
    this.compactOnNextSend = false
    this.replayed = false
  }

  send(data: Uint8Array): void | Promise<void> {
    // protocol chatter (awareness, pub/sub, SyncStep1 requests) must not end
    // up in the cache, see `carriesDocumentState()`
    if (!carriesDocumentState(data)) return

    if (this.compactOnNextSend) {
      this.compactOnNextSend = false

      // this frame is the full snapshot of the just-replayed document, see
      // `armCompaction()` - it supersedes every row that was replayed
      return Database.replaceYjsUpdates(this.uidDB, this.key, data)
    }

    return Database.appendYjsUpdate(this.uidDB, this.key, data)
  }

  onMessage(callback: (data: Uint8Array) => void): () => void {
    this.messageCallback = callback

    this.replayIfReady()

    return () => {
      this.messageCallback = undefined
    }
  }

  /** Replay whatever `connect()` loaded from Dexie into the document, once
   * both a listener is attached (`onMessage()`) and the load has finished
   * (`connect()`) - runs exactly once, regardless of which of the two
   * finishes last.
   */
  private replayIfReady(): void {
    if (this.replayed || !this._isConnected || !this.messageCallback) return

    this.replayed = true

    const updates = this.pendingUpdates
    this.pendingUpdates = []

    for (const update of updates) {
      this.messageCallback(update)
    }

    // everything that was cached is part of the document now, so the snapshot
    // the provider is about to push can replace all of it
    this.armCompaction()
  }
}

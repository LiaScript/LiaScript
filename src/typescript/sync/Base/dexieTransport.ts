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
  offset: number,
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

  // Updates loaded from Dexie during `connect()`, buffered here because
  // `GenericProvider.connect()` only calls `onMessage()` *after*
  // `transport.connect()` resolves (see `y-generic/dist/index.js`,
  // `GenericProvider.connect`) - there is no listener registered yet while
  // this method runs. The buffer is flushed as soon as a callback is
  // registered in `onMessage()`.
  private pendingUpdates: Uint8Array[] = []

  get isConnected(): boolean {
    return this._isConnected
  }

  async connect(config: ConnectionConfig): Promise<void> {
    this.uidDB = config.uidDB
    this.key = config.room

    this.pendingUpdates = await Database.getYjsUpdates(this.uidDB, this.key)

    this._isConnected = true
  }

  disconnect(): void {
    this._isConnected = false
    this.messageCallback = undefined
    this.pendingUpdates = []
  }

  send(data: Uint8Array): void | Promise<void> {
    // protocol chatter (awareness, pub/sub, SyncStep1 requests) must not end
    // up in the cache, see `carriesDocumentState()`
    if (!carriesDocumentState(data)) return

    return Database.appendYjsUpdate(this.uidDB, this.key, data)
  }

  onMessage(callback: (data: Uint8Array) => void): () => void {
    this.messageCallback = callback

    // Replay whatever was loaded by `connect()`, now that someone is
    // actually listening. `GenericProvider` calls `onMessage()` synchronously
    // right after `transport.connect()` resolves, with no intervening
    // `await`, so this is not racing against any other caller of `send()`.
    if (this.pendingUpdates.length > 0) {
      const updates = this.pendingUpdates
      this.pendingUpdates = []

      for (const update of updates) {
        this.messageCallback?.(update)
      }
    }

    return () => {
      this.messageCallback = undefined
    }
  }
}

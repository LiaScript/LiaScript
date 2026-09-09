// Note on the type-only import below: `y-generic`'s package.json `exports`
// map only publishes `.` and `./providers/*` as valid subpaths - there is no
// `./dist/transport` entry. Importing from the package root works because
// `dist/lib.d.ts` (the `.` types entry) re-exports `Transport` and
// `ConnectionConfig` from `./transport` itself. Since this repo has no
// tsconfig.json, Parcel's TS transform erases `import type` entirely before
// bundling anyway, but the runtime import of `extractDocUpdates`/
// `frameDocUpdate` below costs nothing extra: `sync/Base/index.ts` already
// imports `GenericProvider` from the same package root, so the core is in
// that chunk anyway.
import type { Transport, ConnectionConfig } from 'y-generic'
import { extractDocUpdates, frameDocUpdate } from 'y-generic'
import * as Y from 'yjs'
import Database from '../../liascript/service/Database'

/** A Yjs transport that persists the document inside the already-open,
 * already-approved per-course Dexie database (see `sync/Base/persist.ts`
 * for why not a raw IndexedDB database of its own).
 *
 * It is handed every frame `GenericProvider` sends and stores only what
 * carries document state: `extractDocUpdates()` (y-generic) yields the Yjs
 * updates of a frame - none for presence, beacons and requests - and
 * `frameDocUpdate()` wraps an update as the SyncStep2 frame the provider
 * applies on load. Rows are such frames, so rows written by the earlier
 * version of this transport (whole provider frames of any type) load the
 * same way. Each `connect()` merges every row into one and writes it back
 * before the document is handed to the provider, so the log holds one
 * document plus the updates since - never the previous session's presence
 * or beacons (which used to come back as phantom peers, and were answered
 * into the store again: 30 -> 81 -> 171 -> 239 rows).
 */
export class DexieTransport implements Transport {
  private uidDB: string = ''
  private key: string = ''
  private messageCallback?: (data: Uint8Array) => void
  private _isConnected: boolean = false

  // The merged stored document, framed, waiting until both `connect()` has
  // loaded it and `onMessage()` has attached a listener - whichever comes
  // second delivers it (`GenericProvider.connect()` calls `onMessage()`
  // before `transport.connect()`, but do not rely on the order).
  private pending: Uint8Array | null = null
  private replayed: boolean = false

  get isConnected(): boolean {
    return this._isConnected
  }

  async connect(config: ConnectionConfig): Promise<void> {
    this.uidDB = config.uidDB
    this.key = config.room

    // Merge every stored row into one and write it back before it is handed
    // to the provider - all inside one Dexie transaction, so a concurrent
    // append (a second tab on the same course/room) is either included or
    // queued behind it, never cleared away.
    this.pending = await Database.compactYjsUpdates(
      this.uidDB,
      this.key,
      (rows) => {
        const updates = rows.flatMap((row) => extractDocUpdates(row))
        return updates.length === 0 ? null : frameDocUpdate(Y.mergeUpdates(updates))
      }
    )

    this._isConnected = true
    this.replayIfReady()
  }

  disconnect(): void {
    this._isConnected = false
    this.messageCallback = undefined
    this.pending = null
    this.replayed = false
  }

  send(data: Uint8Array): void | Promise<void> {
    const updates = extractDocUpdates(data)
    if (updates.length === 0) return // presence, beacon, request: not ours to keep

    return Database.appendYjsUpdate(
      this.uidDB,
      this.key,
      frameDocUpdate(
        updates.length === 1 ? updates[0] : Y.mergeUpdates(updates)
      )
    )
  }

  onMessage(callback: (data: Uint8Array) => void): () => void {
    this.messageCallback = callback
    this.replayIfReady()
    return () => {
      this.messageCallback = undefined
    }
  }

  /** Hand the merged document to the provider exactly once per connect(). */
  private replayIfReady(): void {
    if (this.replayed || !this._isConnected || !this.messageCallback) return
    this.replayed = true
    const frame = this.pending
    this.pending = null
    if (frame) this.messageCallback(frame)
  }
}

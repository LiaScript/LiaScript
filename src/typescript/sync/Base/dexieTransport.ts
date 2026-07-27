// src/typescript/sync/Base/dexieTransport.ts
//
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

  get isConnected(): boolean {
    return this._isConnected
  }

  async connect(config: ConnectionConfig): Promise<void> {
    this.uidDB = config.uidDB
    this.key = config.room

    const updates = await Database.getYjsUpdates(this.uidDB, this.key)

    for (const update of updates) {
      this.messageCallback?.(update)
    }

    this._isConnected = true
  }

  disconnect(): void {
    this._isConnected = false
    this.messageCallback = undefined
  }

  send(data: Uint8Array): void | Promise<void> {
    return Database.appendYjsUpdate(this.uidDB, this.key, data)
  }

  onMessage(callback: (data: Uint8Array) => void): () => void {
    this.messageCallback = callback

    return () => {
      this.messageCallback = undefined
    }
  }
}

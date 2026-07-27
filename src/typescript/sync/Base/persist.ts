/** Identifiers for the local (Dexie-backed) classroom cache.
 *
 * This module is intentionally free of any dependency — especially of `yjs`
 * and of `y-generic` — so that it can be imported from the eagerly loaded
 * parts of LiaScript (e.g. `liascript/service/Sync.ts` or the Browser
 * connector) without dragging the entire CRDT machinery into the initial
 * bundle. The provider itself has to be imported dynamically, wherever it is
 * really used.
 */

/** Legacy database-name prefix, kept only because
 * `liascript/service/Sync.ts`'s `delete_classroom` handler still imports it
 * to address the old, raw-IndexedDB-backed cache (via `y-generic`'s
 * `IndexedDBTransport.deleteDatabase`) directly by name. `Base/index.ts` no
 * longer uses this — it now persists through `DexieTransport`, which reuses
 * the already-open per-course Dexie database instead of opening a
 * standalone one. Removing this export is Task 4's job, once `Sync.ts`'s
 * `delete_classroom` path is migrated to `Database.clearYjsUpdates`.
 */
export const PERSIST_PREFIX = 'lia-classroom'

/** Identify the local cache of one classroom as a row-grouping key within
 * the per-course Dexie `yjsUpdates` table, see `DexieTransport`.
 *
 * The `backend` is required, otherwise two different backends, that share the
 * same room-name for the same course, would silently overwrite each other's
 * cache.
 *
 * @param course - the (normalized) course URL
 * @param room - the room-name
 * @param backend - the full, pipe-encoded backend string
 */
export function docId(course: string, room: string, backend: string): string {
  return `${course}::${backend}::${room}`
}

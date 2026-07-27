/** Identifiers for the local (Dexie-backed) classroom cache.
 *
 * This module is intentionally free of any dependency — especially of `yjs`
 * and of `y-generic` — so that it can be imported from the eagerly loaded
 * parts of LiaScript (e.g. `liascript/service/Sync.ts` or the Browser
 * connector) without dragging the entire CRDT machinery into the initial
 * bundle. The provider itself has to be imported dynamically, wherever it is
 * really used.
 */

/** Identify the local cache of one classroom as a row-grouping key within
 * the per-course Dexie `yjsUpdates` table, see `DexieTransport`.
 *
 * The `backend` is required, otherwise two different backends, that share the
 * same room-name for the same course, would silently overwrite each other's
 * cache.
 *
 * @param course - the un-normalized course URL / `uidDB`; do **not** pass a
 *                 normalized value here, the cache-key has to match the one
 *                 the Elm side derives, see `Service/Sync.elm`
 * @param room - the room-name
 * @param backend - the full, pipe-encoded backend string
 */
export function docId(course: string, room: string, backend: string): string {
  return `${course}::${backend}::${room}`
}

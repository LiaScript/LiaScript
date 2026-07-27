/** Identifiers for the local (IndexedDB) classroom cache.
 *
 * This module is intentionally free of any dependency — especially of `yjs`
 * and of `y-generic` — so that it can be imported from the eagerly loaded
 * parts of LiaScript (e.g. `liascript/service/Sync.ts` or the Browser
 * connector) without dragging the entire CRDT machinery into the initial
 * bundle. The provider itself has to be imported dynamically, wherever it is
 * really used.
 */

/** Every locally cached classroom is stored within its own IndexedDB
 * database, which is named `${PERSIST_PREFIX}-${docId(...)}`.
 */
export const PERSIST_PREFIX = 'lia-classroom'

/** Identify the local cache of one classroom.
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

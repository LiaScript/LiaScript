import * as Y from 'yjs'

/** Replace at index `i`, padding any gap below it with `null`. Each peer only
 * ever writes its own array (see `CRDT.getOwnSectionArray`), so a plain
 * delete+insert is safe - no concurrent-edit races to reconcile.
 *
 * Yjs refuses `undefined` as array content (it dereferences
 * `c.constructor`), so padding with `undefined` threw as soon as a peer
 * answered question 2 of a section before question 1 - the answer never
 * reached the CRDT and was gone after the next reload. Readers treat both
 * `null` and `undefined` as "no answer", see `CRDT.getSection`.
 */
export function setArrayValue(section: Y.Array<any>, i: number, value: any) {
  if (section.length > i) {
    section.delete(i, 1)
  } else {
    while (section.length < i) section.push([null])
  }
  section.insert(i, [value])
}

# Classroom Persistence: Dexie-backed Transport Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop persistent classrooms from opening a brand-new, raw IndexedDB database via `y-generic`'s `IndexedDBTransport` — which triggers this project's Dexie security-guard patch to pop up a native "An external script is requesting permission to use IndexedDB" confirm dialog on every connect/delete — by storing the cached Yjs updates as rows inside the **same already-approved per-course Dexie database** that `code`/`quiz`/`survey`/`classrooms` already use.

**Architecture:** Replace `y-generic`'s `IndexedDBTransport` with a small custom `Transport` (per `y-generic`'s own minimal interface) backed by three new `LiaDB` → `Connector` → `Database`-service passthrough methods, mirroring the exact layering already built for the `classrooms` table. The new transport never calls the raw `indexedDB` API itself — it goes through `LiaDB.open_()`, the same trusted, already-approved per-course Dexie connection every other table uses — so the guard patch never sees it as a new/unknown database and never prompts.

**Tech Stack:** Same as the parent plan (Elm, TypeScript, Dexie, Yjs/y-generic). This plan only touches TypeScript.

## Context

While live-browser-testing the persistent-classrooms feature (see `docs/superpowers/plans/2026-07-27-persistent-classrooms.md` and its fix wave), every single "Connect" (with "Remember this classroom" checked) and every "Delete" of a saved classroom triggered a native browser `confirm()` dialog: *"An external script is requesting permission to use IndexedDB... Database: lia-classroom-\<course\>::\<backend\>::\<room\>... Do you want to allow this?"*.

Root cause, confirmed by reading `patches/dexie+4.2.1.patch`: this project patches `dexie.mjs` to replace the **global** `window.indexedDB` with a `Proxy` that gates every `open`/`deleteDatabase`/`databases`/`cmp` call — not just Dexie's own internal calls, but literally any code on the page that touches the raw `indexedDB` API. A database name is auto-approved only if it's `'Index'` (hardcoded), or opened within 3 seconds of page load, or already approved once. The guard's own message makes its purpose clear: it exists to stop a malicious or buggy course script (LiaScript courses can embed executable JS) from silently touching IndexedDB — not to gate the app's own legitimate storage.

`y-generic`'s `IndexedDBTransport` (used by `Base.Sync.connect()` since the parent plan's Task 4, and by `delete_classroom` since Task 5) calls the raw `indexedDB.open()`/`deleteDatabase()` API directly, for a brand-new database name, triggered by a user action long after the 3-second init window. That combination guarantees the dialog fires every time, for every real user — this is a genuine UX regression, not a sandbox artifact.

Whitelisting a `lia-classroom-*` name pattern in the patch would defeat the guard's purpose (any embedded script could bypass it the same way). The correct fix — confirmed with the project owner — is to never open a new raw IndexedDB database for this feature at all: store the cached Yjs updates inside the **same per-course Dexie database** that's already implicitly trusted (it's opened during normal course loading, and/or already approved once), using the exact `LiaDB` → `Connector` → `Database`-service layering already built for the `classrooms` table in the parent plan's Tasks 1-3.

This also happens to resolve two loose ends from the parent plan's final review:
- The fragile hard-coded `../../../../node_modules/y-generic/dist/providers/indexeddb/index` import path (flagged as Minor in both Task 4/5's reviews) disappears entirely — no more y-generic IndexedDB dependency anywhere in this feature.
- The "`deleteIndex` can hang indefinitely if another tab holds a `lia-classroom-*` database open" Minor finding from the final review's fix-wave re-review disappears too — there's no longer a separate database to hold open across tabs; the cached updates live inside the per-course Dexie database, which gets deleted wholesale by the existing `Dexie.delete(uidDB)` call.

## Global Constraints

- No JS/TS unit-test harness exists in this repo. Verification is TypeScript build correctness (`npm run build:base`) plus careful manual/static read-throughs, same as the parent plan.
- Follow the exact `getClassrooms`/`saveClassroom`/`deleteClassroom` three-layer pattern (`LiaDB` → `Connector` (`Base`+`Browser`) → `Database` service) for the new `yjsUpdates` methods — same fresh-`open_()`-per-call style, same `if (connector)`/`return` conventions.
- The new transport must implement `y-generic`'s `Transport` interface exactly (`connect`, `disconnect`, `send`, `onMessage`, `isConnected`) — read `node_modules/y-generic/dist/transport.d.ts` before writing it.
- Only import `y-generic`'s `Transport` type with `import type { ... }` (erased at compile time, zero runtime weight) — never a runtime import of anything from `y-generic`/`yjs` in a file that must stay dependency-free (`sync/Base/persist.ts`, `liascript/service/Sync.ts`).
- `Database` (the service singleton, not the type) may be imported as a plain module-level `import` into `sync/Base/dexieTransport.ts` — it is already eagerly loaded by `liascript/index.ts` regardless of this feature, so this adds no new weight to the initial bundle; verify this claim by checking `liascript/index.ts`'s existing imports before relying on it.

---

### Task 1: `LiaDB` `yjsUpdates` table + CRUD, remove `deleteClassroomCaches`

**Files:**
- Modify: `src/typescript/connectors/Browser/database.ts`

**Interfaces:**
- Produces: `LiaDB.getYjsUpdates(uidDB: string, key: string): Promise<Uint8Array[]>`, `LiaDB.appendYjsUpdate(uidDB: string, key: string, data: Uint8Array): Promise<void>`, `LiaDB.clearYjsUpdates(uidDB: string, key: string): Promise<void>` — consumed by Task 2.

- [ ] **Step 1: Add the `yjsUpdates` table (schema version 5)**

The existing chain already goes through `version(4)` (`database.ts:59-72`, the `classrooms` compound-key migration). Add a new version — Dexie only requires the new/changed stores, existing ones carry forward automatically:

```ts
    db.version(5).stores({
      yjsUpdates: '++id, key',
    })
```

Insert this right after the existing `db.version(4).stores({...})` block (`database.ts:70-72`), inside `open_()`.

- [ ] **Step 2: Add the three CRUD methods**

Insert after `deleteClassroom` (currently ending around `database.ts:417`), following the exact fresh-`open_()`-per-call pattern used throughout this file:

```ts
  /** Return all cached Yjs update chunks for one classroom, in the order they
   * were written, so they can be replayed to reconstruct the document.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   */
  async getYjsUpdates(uidDB: string, key: string): Promise<Uint8Array[]> {
    const db = this.open_(uidDB)
    await db.open()

    const rows = await db['yjsUpdates'].where('key').equals(key).toArray()

    return rows.map((row: { data: Uint8Array }) => row.data)
  }

  /** Append one Yjs update chunk to a classroom's local cache.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   * @param data - one raw Yjs update
   */
  async appendYjsUpdate(uidDB: string, key: string, data: Uint8Array) {
    const db = this.open_(uidDB)
    await db.open()

    await db['yjsUpdates'].add({ key, data, created: new Date().getTime() })
  }

  /** Remove all cached Yjs updates for one classroom.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   */
  async clearYjsUpdates(uidDB: string, key: string) {
    const db = this.open_(uidDB)
    await db.open()

    await db['yjsUpdates'].where('key').equals(key).delete()
  }
```

- [ ] **Step 3: Remove `deleteClassroomCaches` and simplify `deleteIndex`**

The cached Yjs updates now live inside the same per-course Dexie database that `deleteIndex` already deletes wholesale (`Dexie.delete(uidDB)`) — no separate cache database exists anymore to hunt down and delete.

Replace `deleteIndex` (currently `database.ts:425-434`):

```ts
  /** Delete all entries for all versions of a certain course defined by its
   * URL. This removes all state information as well as the course from the
   * main index.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   */
  async deleteIndex(uidDB: string) {
    await Promise.all([
      this.dbIndex['courses'].delete(uidDB),
      Dexie.delete(uidDB),
    ])
  }
```

Delete the entire `deleteClassroomCaches` private method (currently `database.ts:436-469`) — it is no longer called from anywhere.

- [ ] **Step 4: Verify**

Run: `npm run build:base`, confirm no TypeScript errors, and confirm (via `grep -rn deleteClassroomCaches src/typescript`) that no references remain.

- [ ] **Step 5: Commit**

```bash
git add src/typescript/connectors/Browser/database.ts
git commit -m "feat: store cached Yjs updates in the per-course Dexie DB instead of a separate IndexedDB database"
```

---

### Task 2: `Connector` + `Database` service passthrough

**Files:**
- Modify: `src/typescript/connectors/Base/index.ts`
- Modify: `src/typescript/connectors/Browser/index.ts`
- Modify: `src/typescript/liascript/service/Database.ts`

**Interfaces:**
- Consumes: `LiaDB.getYjsUpdates/appendYjsUpdate/clearYjsUpdates` (Task 1).
- Produces: `Connector.getYjsUpdates/appendYjsUpdate/clearYjsUpdates`, `Database.getYjsUpdates/appendYjsUpdate/clearYjsUpdates` — consumed by Task 3's `DexieTransport`.

- [ ] **Step 1: Base `Connector` stubs**

Add to `src/typescript/connectors/Base/index.ts`, near the existing `getClassrooms`/`saveClassroom`/`deleteClassroom` stubs:

```ts
  async getYjsUpdates(_uidDB: string, _key: string): Promise<Uint8Array[]> {
    return []
  }

  async appendYjsUpdate(_uidDB: string, _key: string, _data: Uint8Array) {
    console.log('appendYjsUpdate not implemented')
  }

  async clearYjsUpdates(_uidDB: string, _key: string) {
    console.log('clearYjsUpdates not implemented')
  }
```

- [ ] **Step 2: Browser `Connector` implementation**

Add to `src/typescript/connectors/Browser/index.ts`, near the existing `getClassrooms`/`saveClassroom`/`deleteClassroom` implementations:

```ts
  async getYjsUpdates(uidDB: string, key: string) {
    return this.database.getYjsUpdates(uidDB, key)
  }

  async appendYjsUpdate(uidDB: string, key: string, data: Uint8Array) {
    return this.database.appendYjsUpdate(uidDB, key, data)
  }

  async clearYjsUpdates(uidDB: string, key: string) {
    return this.database.clearYjsUpdates(uidDB, key)
  }
```

(Note: `return` the underlying promise — Task 4 of the parent plan's final-review fix wave already fixed the sibling `saveClassroom`/`deleteClassroom` methods to do this; match that convention here from the start, don't repeat the fire-and-forget mistake.)

- [ ] **Step 3: `Database` service passthrough**

Add to `src/typescript/liascript/service/Database.ts`'s `Service` object, near `getClassrooms`/`saveClassroom`/`deleteClassroom`:

```ts
  getYjsUpdates: async function (uidDB: string, key: string) {
    if (connector) {
      return connector.getYjsUpdates(uidDB, key)
    }
    return []
  },

  appendYjsUpdate: async function (uidDB: string, key: string, data: Uint8Array) {
    if (connector) {
      return connector.appendYjsUpdate(uidDB, key, data)
    }
  },

  clearYjsUpdates: async function (uidDB: string, key: string) {
    if (connector) {
      return connector.clearYjsUpdates(uidDB, key)
    }
  },
```

- [ ] **Step 4: Verify**

Run: `npm run build:base`, confirm no TypeScript errors.

- [ ] **Step 5: Commit**

```bash
git add src/typescript/connectors/Base/index.ts src/typescript/connectors/Browser/index.ts src/typescript/liascript/service/Database.ts
git commit -m "feat: expose Yjs update cache CRUD through Connector and Database service"
```

---

### Task 3: `DexieTransport` + wire into `Base.Sync.connect()`

**Files:**
- Create: `src/typescript/sync/Base/dexieTransport.ts`
- Modify: `src/typescript/sync/Base/index.ts`
- Modify: `src/typescript/sync/Base/persist.ts`

**Interfaces:**
- Consumes: `Database.getYjsUpdates/appendYjsUpdate/clearYjsUpdates` (Task 2), `y-generic`'s `Transport` type (`node_modules/y-generic/dist/transport.d.ts`), `GenericProvider` (already used in `Base/index.ts`).
- Produces: `DexieTransport` class — consumed only by `Base/index.ts`'s `connect()`.

- [ ] **Step 1: Read the exact `Transport` interface first**

Read `node_modules/y-generic/dist/transport.d.ts` in full before writing the class — it defines exactly `connect(config: ConnectionConfig): Promise<void>`, `disconnect(): void`, `send(data: Uint8Array): void | Promise<void>`, `onMessage(callback: (data: Uint8Array) => void): () => void`, `readonly isConnected: boolean` (plus optional `onPeerConnect`/`preferredBatchMs`, not needed here). `ConnectionConfig` is `{ room: string; password?: string; [key: string]: any }` — the extra-keys escape hatch is how `uidDB` gets passed through (see Step 3).

**Import-path caution (same class of issue as the parent plan's Task 4/5):** this repo has no `tsconfig.json`, so `import type { Transport } from '...'` is erased entirely by Parcel's TS transform before bundling — the exact specifier does not need to resolve for the build to succeed, since no runtime import survives. Don't assume `'y-generic/dist/transport'` (as written below) is correct without checking; if it doesn't resolve cleanly (e.g. an editor/IDE complains, or you want extra certainty), inline the two or three fields actually used (`ConnectionConfig`'s `room`/`uidDB`, the method signatures) as a local type instead of importing them — this file does not need the full `y-generic` type surface, only the shape of what it consumes.

- [ ] **Step 2: Write `DexieTransport`**

```ts
// src/typescript/sync/Base/dexieTransport.ts
import type { Transport, ConnectionConfig } from 'y-generic/dist/transport'
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
```

- [ ] **Step 3: Wire it into `Base.Sync.connect()`, pass `uidDB` through, drop `IndexedDBTransport`**

Replace the `Base/index.ts` imports (currently lines 1-8):

```ts
import Lia from '../../liascript/types/lia.d'
import { GenericProvider } from 'y-generic'
import { DexieTransport } from './dexieTransport'
import * as helper from '../../helper'
import { CRDT } from './db'

import { encode, decode } from 'uint8-to-base64'
import { docId } from './persist'
```

(`PERSIST_PREFIX` is no longer used anywhere — drop the import and the re-export on the old line 17; keep `export { docId }` since it's still consumed elsewhere.)

Replace the `if (data.persistent) { ... }` block inside `connect()` (currently `Base/index.ts:199-216`):

```ts
    if (data.persistent) {
      const transport = new DexieTransport()
      this.persistProvider = new GenericProvider(this.db.doc, transport)
      this.persistReady = this.persistProvider.connect({
        // the local cache is identified by the local database-name, not by
        // the (possibly normalized) network identity of the course
        room: docId(
          data.uidDB || data.course,
          data.room,
          data.fullBackend || '',
        ),
        uidDB: data.uidDB || data.course,
      })

      // the promise itself is passed on to the subclasses, this only prevents
      // an unhandled rejection, if nobody else is listening
      this.persistReady.catch((e: any) => {
        console.warn('Sync: local persistence unavailable ->', e?.message || e)
      })
    } else {
      this.persistReady = Promise.resolve()
    }
```

- [ ] **Step 4: Update `persist.ts`'s documentation**

`docId`'s doc comment (`persist.ts:11-14`) currently says the id names a raw IndexedDB database — update it to describe the new Dexie-row-key role. Also drop the now-unused `PERSIST_PREFIX` export and its doc comment (`persist.ts:1-14`):

```ts
/** Identifiers for the local (Dexie-backed) classroom cache.
 *
 * This module is intentionally free of any dependency — especially of `yjs`
 * and of `y-generic` — so that it can be imported from the eagerly loaded
 * parts of LiaScript (e.g. `liascript/service/Sync.ts`) without dragging the
 * entire CRDT machinery into the initial bundle.
 */

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
```

- [ ] **Step 5: Verify**

Run: `npm run build:base`, confirm no TypeScript errors, and confirm (via `grep -rn "IndexedDBTransport\|PERSIST_PREFIX" src/typescript`) that no reference to either remains anywhere in `src/typescript` (Task 4 removes the one remaining usage in `Sync.ts`, so a leftover hit there at this point is expected — re-check after Task 4 instead).

- [ ] **Step 6: Commit**

```bash
git add src/typescript/sync/Base/dexieTransport.ts src/typescript/sync/Base/index.ts src/typescript/sync/Base/persist.ts
git commit -m "feat: add DexieTransport, replace y-generic IndexedDBTransport in Base.Sync"
```

---

### Task 4: Simplify `Sync.ts`'s `delete_classroom`

**Files:**
- Modify: `src/typescript/liascript/service/Sync.ts`

**Interfaces:**
- Consumes: `Database.clearYjsUpdates` (Task 2), `docId` (`sync/Base/persist.ts`, unchanged import path).

- [ ] **Step 1: Drop the y-generic import, use `Database.clearYjsUpdates`**

Replace the top-of-file import (currently `Sync.ts:1-4`):

```ts
import log from '../log'
import { docId } from '../../sync/Base/persist'
```

Replace the `delete_classroom` case body (currently `Sync.ts:366-388`):

```ts
      case 'delete_classroom': {
        const { course, room, backend } = event.message.param

        try {
          if (Database) {
            await Database.deleteClassroom(course, room, backend)
            await Database.clearYjsUpdates(course, docId(course, room, backend))
          }
        } catch (e: any) {
          log.warn('could not delete classroom ->', e?.message || e)
          sendError(event, `could not delete classroom: ${e?.message || e}`)
        }

        break
      }
```

- [ ] **Step 2: Verify**

Run: `npm run build:base`, confirm no TypeScript errors. Run `grep -rn "IndexedDBTransport\|PERSIST_PREFIX" src/typescript` — confirm **zero** matches anywhere now (this is the definitive check that the feature no longer touches raw IndexedDB at all).

- [ ] **Step 3: Commit**

```bash
git add src/typescript/liascript/service/Sync.ts
git commit -m "feat: delete_classroom clears the Dexie-backed Yjs cache instead of a separate IndexedDB database"
```

---

### Task 5: Live browser re-verification (manual, not a subagent task)

This task has no code changes — it re-runs the exact live-browser walkthrough already performed for the parent plan, this time checking specifically that **no `window.confirm` dialog appears** at any point.

- [ ] Start `npm run watch:dev` (or `npx parcel serve src/entry/dev/index.html`), open a course.
- [ ] Open the Classroom modal, connect to "Own Notes (offline)" with the browser's dialog-handling disabled/observed — confirm **no confirm dialog fires**, connection still succeeds, write a chat message.
- [ ] Reload, reopen "Own Notes" — confirm the message is still there (persistence still works) and again **no dialog fires**.
- [ ] Connect to a normal backend (e.g. WebSocket) with "Remember this classroom" checked — confirm **no dialog fires**, and after a reload the room still appears under "Saved Classrooms".
- [ ] Delete a saved classroom — confirm **no dialog fires**, the entry disappears, and after a reload it's still gone.
- [ ] Delete the entire course from the index page — confirm it completes without hanging (this exercises the simplified `deleteIndex`, which no longer depends on a cross-tab-blockable `IndexedDBTransport.deleteDatabase` call).
- [ ] Check DevTools → Application → IndexedDB: confirm no `lia-classroom-*` databases are created anymore — only the per-course database (named by the course URL) and the global `Index` database should exist.

# Persistent Classrooms Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a LiaScript classroom (P2P sync session) be made persistent via a checkbox: its config is remembered in a new per-course `classrooms` Dexie table, its Yjs content (chat/quiz/survey/code) is cached locally through the already-installed but unused `y-generic` `IndexedDBTransport`, and a special offline-only "own notes" classroom becomes available.

**Architecture:** All 11 sync backends (Gun, WebSocket, PeerJS, …) already share one `Y.Doc` owned by `Base.Sync` (`src/typescript/sync/Base/index.ts`). Local persistence is added exactly once, in `Base.Sync.connect()`, as a second `GenericProvider` running an `IndexedDBTransport` in parallel with whatever network transport a subclass sets up — no per-backend changes needed. A new `Local` backend (no network transport at all) reuses this same mechanism to implement the offline notes room. Saved-classroom metadata (name/backend/password) lives in a new Dexie table scoped to the course, mirroring the existing `courses` table pattern in the global `Index` DB.

**Tech Stack:** Elm (parser/UI, `elm-test`), TypeScript (sync backends, Dexie/IndexedDB persistence), Yjs + `y-generic` (already a dependency).

## Global Constraints

- No JS/TS unit-test harness exists in this repo (confirmed: only `npx elm-test` under `tests/`). TS tasks are verified by type-correctness (the project builds) and manual exercise via `npm run watch` + browser DevTools (Application → IndexedDB), not fabricated unit tests. Do not invent a TS test runner.
- Elm pure-function changes (decoders, `Via` encode/decode) get real `elm-test` coverage — run with `npx elm-test tests/<Path>.elm`.
- Follow existing patterns exactly instead of introducing new ones: `courses` table shape (`database.ts:32`) for the new `classrooms` table, `addMisc`/`getMisc` (`database.ts:318-354`, `Base/index.ts:109-120`, `Browser/index.ts:69-80`, `Database.ts:230-251`) for new Connector/Service methods, `Index.View.Popup` for delete confirmation, `Lia.Sync.Via.checkbox` for checkboxes.
- Naming: the new cross-backend "remember & cache this room" flag is called `persistent` throughout Elm/TS. Do not confuse it with GUN's own unrelated `Via.GUN.persistent` field (`src/elm/Lia/Sync/Via.elm:26`, GUN's own storage layer) — leave that one untouched.
- IndexedDB persistence identity: always build the local-cache key as `` `${course}::${room}` `` via the shared `docId()` helper (Task 4) and the fixed prefix `'lia-classroom'` — never inline the template string in more than one place.

---

### Task 1: Dexie `classrooms` table + `LiaDB` CRUD methods

**Files:**
- Modify: `src/typescript/connectors/Browser/database.ts:48-60` (`open_`), and add new methods after `getMisc` (currently ends at line 354).

**Interfaces:**
- Produces: `LiaDB.getClassrooms(uidDB: string): Promise<Array<{room: string, backend: string, password: string|null, created: number, updated: number}>>`, `LiaDB.saveClassroom(uidDB: string, entry: {room: string, backend: string, password?: string}): Promise<void>`, `LiaDB.deleteClassroom(uidDB: string, room: string): Promise<void>` — consumed by Task 2.

- [ ] **Step 1: Add the `classrooms` store to the per-course Dexie schema**

Dexie only requires the *changed/new* stores in a later `.version()` call — existing stores (`code`/`quiz`/`survey`/`task`/`offline`) carry forward automatically, so existing users' databases upgrade in place without redefining them.

```ts
  private open_(uidDB: string): Dexie {
    let db = new Dexie(uidDB)

    db.version(1).stores({
      code: '[id+version], version',
      quiz: '[id+version], version',
      survey: '[id+version], version',
      task: '[id+version], version',
      offline: '[id+version], version',
    })

    db.version(2).stores({
      classrooms: '&room, updated',
    })

    return db
  }
```

- [ ] **Step 2: Add `getClassrooms`/`saveClassroom`/`deleteClassroom` to `LiaDB`**

Insert after the existing `getMisc` method (after line 354), following the exact same fresh-`open_()`-per-call pattern used by `addMisc`/`getMisc`/`restore`:

```ts
  /** Return all saved classrooms for a course, most recently updated first.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   */
  async getClassrooms(uidDB: string) {
    const db = this.open_(uidDB)
    await db.open()

    return await db['classrooms'].orderBy('updated').reverse().toArray()
  }

  /** Insert or update a saved classroom entry for a course.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param entry - room name (primary key), full encoded backend string, optional password
   */
  async saveClassroom(
    uidDB: string,
    entry: { room: string; backend: string; password?: string }
  ) {
    const db = this.open_(uidDB)
    await db.open()

    const existing = await db['classrooms'].get(entry.room)
    const now = new Date().getTime()

    await db['classrooms'].put({
      room: entry.room,
      backend: entry.backend,
      password: entry.password || null,
      created: existing ? existing.created : now,
      updated: now,
    })
  }

  /** Remove a saved classroom entry for a course.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param room - the classroom's room name (primary key)
   */
  async deleteClassroom(uidDB: string, room: string) {
    const db = this.open_(uidDB)
    await db.open()

    await db['classrooms'].delete(room)
  }
```

- [ ] **Step 3: Verify it compiles and behaves correctly**

Run: `npm run watch:app` (or `npm run build`), open the app in a browser, open DevTools console and run:

```js
// exercise the new store directly to confirm schema + CRUD work end to end
const dbg = new Dexie(window.location.href.split('#')[0])
```

Simpler: just confirm the build succeeds with no TypeScript errors (`npx tsc --noEmit -p .` if a root tsconfig exists, otherwise rely on the Parcel build's type-checking output) — full functional verification happens in Task 10's end-to-end check once the UI can trigger these calls.

- [ ] **Step 4: Commit**

```bash
git add src/typescript/connectors/Browser/database.ts
git commit -m "feat: add classrooms table and CRUD to LiaDB"
```

---

### Task 2: Connector plumbing (`Base.Connector` stubs + `Browser.Connector` implementation)

**Files:**
- Modify: `src/typescript/connectors/Base/index.ts` (after `getMisc`, line 109-120)
- Modify: `src/typescript/connectors/Browser/index.ts` (after `getMisc`, line 69-80)

**Interfaces:**
- Consumes: `LiaDB.getClassrooms/saveClassroom/deleteClassroom` from Task 1.
- Produces: `Connector.getClassrooms(uidDB)`, `Connector.saveClassroom(uidDB, entry)`, `Connector.deleteClassroom(uidDB, room)` — consumed by Task 3.

- [ ] **Step 1: Add stub methods to the base `Connector` class**

```ts
  async getClassrooms(_uidDB: string): Promise<any[]> {
    return []
  }

  async saveClassroom(
    _uidDB: string,
    _entry: { room: string; backend: string; password?: string }
  ) {
    console.log('saveClassroom not implemented')
  }

  async deleteClassroom(_uidDB: string, _room: string) {
    console.log('deleteClassroom not implemented')
  }
```

- [ ] **Step 2: Implement them in the Browser connector**

```ts
  async getClassrooms(uidDB: string) {
    return this.database.getClassrooms(uidDB)
  }

  async saveClassroom(
    uidDB: string,
    entry: { room: string; backend: string; password?: string }
  ) {
    this.database.saveClassroom(uidDB, entry)
  }

  async deleteClassroom(uidDB: string, room: string) {
    this.database.deleteClassroom(uidDB, room)
  }
```

- [ ] **Step 3: Verify build**

Run: `npm run build:base` (or `npm run watch`) — confirm no TypeScript errors (the `Connector` base class and `Browser.Connector` subclass must stay structurally compatible).

- [ ] **Step 4: Commit**

```bash
git add src/typescript/connectors/Base/index.ts src/typescript/connectors/Browser/index.ts
git commit -m "feat: expose classroom CRUD through the Connector interface"
```

---

### Task 3: `Database` service exposes classroom methods

**Files:**
- Modify: `src/typescript/liascript/service/Database.ts` (after `getMisc`, currently ending at line 251)

**Interfaces:**
- Consumes: `Connector.getClassrooms/saveClassroom/deleteClassroom` from Task 2.
- Produces: `Database.getClassrooms(uidDB)`, `Database.saveClassroom(uidDB, entry)`, `Database.deleteClassroom(uidDB, room)` — consumed by Task 5 (`Sync.ts`), the same way `Torrent.init(elmSend, Database)` already lets the `Torrent` service call into `Database` (see `src/typescript/liascript/index.ts:212`).

- [ ] **Step 1: Add the three methods to the `Service` object**

Insert right after the existing `getMisc` method (before the closing `}` of the `Service` object, line 251):

```ts
  getClassrooms: async function (uidDB: string) {
    if (connector) {
      return connector.getClassrooms(uidDB)
    }
    return []
  },

  saveClassroom: async function (
    uidDB: string,
    entry: { room: string; backend: string; password?: string }
  ) {
    if (connector) {
      connector.saveClassroom(uidDB, entry)
    }
  },

  deleteClassroom: async function (uidDB: string, room: string) {
    if (connector) {
      connector.deleteClassroom(uidDB, room)
    }
  },
```

- [ ] **Step 2: Verify build**

Run: `npm run build:base`, confirm no TypeScript errors.

- [ ] **Step 3: Commit**

```bash
git add src/typescript/liascript/service/Database.ts
git commit -m "feat: expose classroom CRUD on the Database service"
```

---

### Task 4: Local IndexedDB persistence in `Base.Sync` (backend-agnostic)

**Files:**
- Modify: `src/typescript/sync/Base/index.ts`

**Interfaces:**
- Consumes: `GenericProvider` (`y-generic/providers/generic/index`, already imported), `IndexedDBTransport` (`y-generic/providers/indexeddb`, new import).
- Produces: exported `PERSIST_PREFIX: string` and `docId(course: string, room: string): string` — consumed by Task 5 (delete-classroom cache cleanup) and implicitly by every backend subclass via inherited `connect()`/`destroy()`.

- [ ] **Step 1: Import `IndexedDBTransport` and add the exported helpers**

At the top of the file, alongside the existing `GenericProvider` import:

```ts
import { GenericProvider } from 'y-generic/providers/generic/index'
import { IndexedDBTransport } from 'y-generic/providers/indexeddb'
```

Add near the top-level exports (alongside `uint8_to_base64`/`base64_to_unit8`, e.g. after line 13):

```ts
export const PERSIST_PREFIX = 'lia-classroom'

export function docId(course: string, room: string): string {
  return `${course}::${room}`
}
```

- [ ] **Step 2: Add a `persistProvider` field and wire it up in `connect()`**

```ts
  public db: CRDT
  public provider?: GenericProvider
  protected persistProvider?: GenericProvider
```

Replace the existing `connect()` method (lines 168-179):

```ts
  connect(data: {
    course: string
    room: string
    password?: string
    persistent?: boolean
    config?: any
  }) {
    this.room = data.room
    this.course = data.course
    this.password = data.password

    this.isConnected = true

    if (data.persistent) {
      const transport = new IndexedDBTransport({ prefix: PERSIST_PREFIX })
      this.persistProvider = new GenericProvider(this.db.doc, transport)
      this.persistProvider.connect({ room: docId(data.course, data.room) })
    }
  }
```

- [ ] **Step 3: Clean up the persistence provider on destroy**

Replace the existing `destroy()` method (lines 181-185):

```ts
  destroy() {
    this.persistProvider?.disconnect()
    this.persistProvider = undefined
    this.db.destroy()
    this.cbConnection('disconnect', this.token)
    this.isConnected = false
  }
```

Every backend subclass's own `destroy()` override already calls `super.destroy()` first (see `src/typescript/sync/Gun/index.ts:29-37`), so this cleanup applies to all backends automatically — no subclass changes needed.

- [ ] **Step 4: Verify build**

Run: `npm run build:base`, confirm no TypeScript errors. Manually smoke-test in the browser: connect to any classroom with an existing backend (e.g. WebSocket against a local `y-websocket` server, or GUN) — behavior must be unchanged when `persistent` is not sent (it's `undefined`/falsy, so the `if` block is skipped and nothing new happens).

- [ ] **Step 5: Commit**

```bash
git add src/typescript/sync/Base/index.ts
git commit -m "feat: add backend-agnostic local IndexedDB persistence to Base.Sync"
```

---

### Task 5: `Local` backend (offline notes) + `Sync.ts` wiring

**Files:**
- Create: `src/typescript/sync/Local/index.ts`
- Modify: `src/typescript/liascript/service/Sync.ts`
- Modify: `src/typescript/liascript/index.ts:210`

**Interfaces:**
- Consumes: `Base.Sync` (Task 4), `Base.docId`/`Base.PERSIST_PREFIX` (Task 4), `Database.getClassrooms/saveClassroom/deleteClassroom` (Task 3).
- Produces: TS-side handling of `backend: 'local'` in the `connect` event, and new `list_classrooms`/`delete_classroom` cmds on the `sync` port — consumed by Elm Tasks 8-9 (`Service.Sync.listClassrooms`/`deleteClassroom`).

- [ ] **Step 1: Create the `Local` backend**

```ts
// src/typescript/sync/Local/index.ts
import * as Base from '../Base/index'

/** A classroom backend with no network transport at all. Base.Sync already
 * wires up local IndexedDB persistence when `persistent` is set, so this
 * class only needs to report success immediately — there is no peer
 * handshake to wait for.
 */
export class Sync extends Base.Sync {
  connect(data: {
    course: string
    room: string
    password?: string
    persistent?: boolean
    config?: any
  }) {
    super.connect(data)
    this.sendConnect()
  }
}
```

- [ ] **Step 2: Wire `Local` into `Sync.ts`'s dispatch**

Add `'local'` to the `supported` array (`src/typescript/liascript/service/Sync.ts:30-45`, it needs no `hasRTCPeerConnection()` guard since it never touches the network):

```ts
  supported: [
    'edrys',
    'gun',
    'ipfs',
    'local',
    'mqtt',
    'nostr',
    'pubnub',
    hasRTCPeerConnection() ? 'peerjs' : '',
    hasRTCPeerConnection() ? 'simplepeer' : '',
    'torrent',
    'websocket',
  ],
```

Add a lazy-import module var near the other backend vars (line 6-15):

```ts
var Local
```

Add a case to the backend switch inside `handle()`'s `'connect'` branch (alongside the `'gun'` case, `src/typescript/liascript/service/Sync.ts:100-116`):

```ts
            case 'local':
              if (!Local) {
                import('../../sync/Local/index').then((e) => {
                  Local = e
                  Service.handle(event)
                })
                return
              }

              sync = new Local.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false,
              )
              break
```

- [ ] **Step 3: Store a `Database` reference and auto-save on persistent connect**

Change `init` to accept the `Database` service (mirrors `Torrent.init(elmSend, Database)`):

```ts
var Database: any

const Service = {
  ...
  init: function (elmSend_: Lia.Send, database_: any) {
    elmSend = elmSend_
    Database = database_

    if (window['LIA']) {
      window['LIA']['classroom'] = {
        connected: false,

        publish,
        subscribe,
        unsubscribe,
        on,
      }
    }
  },
```

Right after `if (sync) sync.connect(event.message.param.config)` (`src/typescript/liascript/service/Sync.ts:269`), add the auto-save:

```ts
        if (sync) {
          sync.connect(event.message.param.config)

          const config = event.message.param.config
          if (config.persistent && Database) {
            Database.saveClassroom(config.course, {
              room: config.room,
              backend: config.fullBackend,
              password: config.password,
            })
          }
        }
```

- [ ] **Step 4: Add `list_classrooms` and `delete_classroom` cmds**

Import at the top of the file:

```ts
import { IndexedDBTransport } from 'y-generic/providers/indexeddb'
import * as Base from '../../sync/Base/index'
```

Add two new cases to the top-level `switch (event.message.cmd)` in `handle()`, alongside `'connect'`/`'disconnect'` (`src/typescript/liascript/service/Sync.ts:63-294`):

```ts
      case 'list_classrooms': {
        const course = event.message.param
        const list = Database ? await Database.getClassrooms(course) : []

        if (elmSend) {
          elmSend({
            ...event,
            message: { cmd: 'classrooms', param: list },
            reply: true,
          })
        }

        break
      }

      case 'delete_classroom': {
        const { course, room } = event.message.param

        if (Database) await Database.deleteClassroom(course, room)
        await IndexedDBTransport.deleteDatabase(
          Base.docId(course, room),
          Base.PERSIST_PREFIX,
        )

        break
      }
```

- [ ] **Step 5: Update the call site**

`src/typescript/liascript/index.ts:210`:

```ts
    Sync.init(elmSend, Database)
```

- [ ] **Step 6: Verify build + manual smoke test**

Run: `npm run watch:app`. In the browser: open the classroom modal (once Tasks 6-9 land you can drive this from the UI; until then, you can call `window.LIA.send` manually from DevTools to fire a `{service:'sync', message:{cmd:'connect', param:{backend:'local', config:{course:'test', room:'notes', persistent:true, fullBackend:'Local'}}}}` event and confirm a `lia-classroom-test::notes` IndexedDB database appears in DevTools → Application → IndexedDB after writing a chat message).

- [ ] **Step 7: Commit**

```bash
git add src/typescript/sync/Local/index.ts src/typescript/liascript/service/Sync.ts src/typescript/liascript/index.ts
git commit -m "feat: add Local offline backend and classroom list/delete/persist wiring"
```

---

### Task 6: Elm `Lia.Sync.Via` — add the `Local` backend variant

**Files:**
- Modify: `src/elm/Lia/Sync/Via.elm`

**Interfaces:**
- Produces: `Via.Backend` gains a `Local` constructor; `Via.toString True Local == "Local"`, `Via.fromString "local" == Just Local`, `Via.icon Local` renders `icon-pencil`. Consumed by Task 7 (round-trip test) and Task 9 (notes-tile message).

`Backend` is matched exhaustively (no wildcard) in `toString`, `icon`, and `infoOn` — all three **must** get a new case or the module fails to compile once `Local` is added to the type.

- [ ] **Step 1: Add the constructor**

```elm
type Backend
    = Edrys
    | GUN { urls : String, persistent : Bool }
    | P2PT String
    | IPFS
    | PubNub { pubKey : String, subKey : String }
    | NoStr
    | MQTT
    | Torrent
    | WebSocket { url : String }
    | PeerJS { host : String, port_ : String, path : String, iceServers : String }
    | SimplePeer { signaling : String, iceServers : String }
    | Local
```

- [ ] **Step 2: `toString`**

Add before the final case (anywhere in the `case via of` block):

```elm
        Local ->
            "Local"
```

- [ ] **Step 3: `icon`**

```elm
            Local ->
                "icon-pencil icon-xs"
```

- [ ] **Step 4: `fromString`**

Add alongside the other single-token cases:

```elm
        [ "local" ] ->
            Just Local
```

- [ ] **Step 5: `infoOn`**

Add a case (this function is matched exhaustively over all 11→12 constructors, second tuple element is `_`):

```elm
            ( Local, _ ) ->
                [ Html.text "This is a purely local classroom — nothing is sent over the network. "
                , Html.text "Your notes are written to this browser's storage only and never shared with anyone."
                ]
```

- [ ] **Step 6: Verify it compiles**

Run: `npx elm make src/elm/Main.elm --output=/dev/null` — confirm no missing-pattern compiler errors for `Via.elm`.

- [ ] **Step 7: Commit**

```bash
git add src/elm/Lia/Sync/Via.elm
git commit -m "feat: add Local backend variant to Lia.Sync.Via"
```

---

### Task 7: Elm `Lia.Sync.Classroom` module (saved-entry type + decoder) + test

**Files:**
- Create: `src/elm/Lia/Sync/Classroom.elm`
- Create: `tests/Sync/Classroom.elm`

**Interfaces:**
- Consumes: `Lia.Sync.Via.fromString`/`toString` (Task 6).
- Produces: `Classroom.Entry { room : String, backend : String, password : Maybe String, updated : Int }`, `Classroom.decoder : JD.Decoder (List Entry)` — consumed by Task 9 (`Lia.Sync.Update`/`Types`).

- [ ] **Step 1: Write the module**

```elm
module Lia.Sync.Classroom exposing (Entry, decoder)

import Json.Decode as JD


{-| A saved classroom, as stored in the per-course `classrooms` Dexie table
and returned by the `sync` service's `"classrooms"` reply. `backend` is the
full pipe-encoded string produced by `Lia.Sync.Via.toString True` — decode it
back into a `Via.Backend` with `Via.fromString` when the user picks this
entry to reconnect.
-}
type alias Entry =
    { room : String
    , backend : String
    , password : Maybe String
    , updated : Int
    }


decoder : JD.Decoder (List Entry)
decoder =
    JD.list entryDecoder


entryDecoder : JD.Decoder Entry
entryDecoder =
    JD.map4 Entry
        (JD.field "room" JD.string)
        (JD.field "backend" JD.string)
        (JD.field "password" (JD.nullable JD.string))
        (JD.field "updated" JD.int)
```

- [ ] **Step 2: Write the failing test**

```elm
module Sync.Classroom exposing (suite)

import Expect
import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Via as Via
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Sync.Classroom"
        [ test "decodes a list of saved classrooms" <|
            \_ ->
                let
                    json =
                        JE.list identity
                            [ JE.object
                                [ ( "room", JE.string "my-room" )
                                , ( "backend", JE.string (Via.toString True (Via.WebSocket { url = "wss://example.com" })) )
                                , ( "password", JE.string "secret" )
                                , ( "updated", JE.int 1234 )
                                ]
                            , JE.object
                                [ ( "room", JE.string "__notes__" )
                                , ( "backend", JE.string (Via.toString True Via.Local) )
                                , ( "password", JE.null )
                                , ( "updated", JE.int 5678 )
                                ]
                            ]
                in
                json
                    |> JD.decodeValue Classroom.decoder
                    |> Expect.equal
                        (Ok
                            [ { room = "my-room"
                              , backend = "WebSocket|wss://example.com"
                              , password = Just "secret"
                              , updated = 1234
                              }
                            , { room = "__notes__"
                              , backend = "Local"
                              , password = Nothing
                              , updated = 5678
                              }
                            ]
                        )
        , test "the stored backend string round-trips through Via.fromString" <|
            \_ ->
                Via.toString True (Via.WebSocket { url = "wss://example.com" })
                    |> Via.fromString
                    |> Expect.equal (Just (Via.WebSocket { url = "wss://example.com" }))
        , test "Local round-trips through Via.fromString" <|
            \_ ->
                Via.toString True Via.Local
                    |> Via.fromString
                    |> Expect.equal (Just Via.Local)
        ]
```

- [ ] **Step 3: Run it and confirm it passes**

Run: `npx elm-test tests/Sync/Classroom.elm`
Expected: `3 passed`. (There is no "make it fail first" step here since the module and test are written together — but do run it once before Step 4 to confirm the decoder's field order/shape actually matches, since a mismatched `JD.map4` field order is a common silent bug.)

- [ ] **Step 4: Commit**

```bash
git add src/elm/Lia/Sync/Classroom.elm tests/Sync/Classroom.elm
git commit -m "feat: add Lia.Sync.Classroom entry type and decoder"
```

---

### Task 8: Elm `Service.Sync` — `persistent`/`fullBackend` in connect, `listClassrooms`, `deleteClassroom`

**Files:**
- Modify: `src/elm/Service/Sync.elm`

**Interfaces:**
- Consumes: `Via.toString` (existing).
- Produces: `Service.Sync.connect : {backend, course, room, password, persistent} -> Event` (signature changes — one new field), `Service.Sync.listClassrooms : String -> Event`, `Service.Sync.deleteClassroom : String -> String -> Event` — consumed by Task 9.

- [ ] **Step 1: Extend `connect`'s parameter record and payload**

Replace the type signature and body (lines 10-100) — only the parameter record and the `config` object's field list change; the backend-specific `case param.backend of ...` block (lines 41-95) stays exactly as-is:

```elm
connect :
    { backend : Via.Backend
    , course : String
    , room : String
    , password : String
    , persistent : Bool
    }
    -> Event
connect param =
    [ ( "backend"
      , param.backend
            |> Via.toString False
            |> String.toLower
            |> JE.string
      )
    , ( "config"
      , JE.object
            [ ( "course"
              , param.course
                    |> IPFS.origin
                    |> Maybe.withDefault param.course
                    |> JE.string
              )
            , ( "room", JE.string param.room )
            , ( "password"
              , if String.isEmpty param.password then
                    JE.null

                else
                    JE.string param.password
              )
            , ( "persistent", JE.bool param.persistent )
            , ( "fullBackend", JE.string (Via.toString True param.backend) )
            , ( "config"
              , case param.backend of
                    Via.GUN { urls, persistent } ->
                        JE.object
                            [ ( "persistent", JE.bool persistent )
                            , ( "urls"
                              , urls
                                    |> String.split ","
                                    |> List.map String.trim
                                    |> List.filter (String.isEmpty >> not)
                                    |> JE.list JE.string
                              )
                            ]

                    Via.PubNub { pubKey, subKey } ->
                        JE.object
                            [ ( "publishKey", JE.string pubKey )
                            , ( "subscribeKey", JE.string subKey )
                            ]

                    Via.P2PT urls ->
                        urls
                            |> String.split ","
                            |> JE.list (String.trim >> JE.string)

                    Via.WebSocket { url } ->
                        JE.object
                            [ ( "url", JE.string url )
                            ]

                    Via.PeerJS { host, port_, path, iceServers } ->
                        JE.object
                            [ ( "host", JE.string host )
                            , ( "port", JE.string port_ )
                            , ( "path", JE.string path )
                            , ( "iceServers", JE.string iceServers )
                            ]

                    Via.SimplePeer { signaling, iceServers } ->
                        JE.object
                            [ ( "signaling", JE.string signaling )
                            , ( "iceServers", JE.string iceServers )
                            ]

                    _ ->
                        JE.null
              )
            ]
      )
    ]
        |> JE.object
        |> publish "connect"
```

- [ ] **Step 2: Add `listClassrooms` and `deleteClassroom`**

Add near `disconnect`/`join` (after line 108):

```elm
listClassrooms : String -> Event
listClassrooms course =
    course
        |> JE.string
        |> publish "list_classrooms"


deleteClassroom : String -> String -> Event
deleteClassroom course room =
    [ ( "course", JE.string course )
    , ( "room", JE.string room )
    ]
        |> JE.object
        |> publish "delete_classroom"
```

- [ ] **Step 3: Update the exposing list**

```elm
module Service.Sync exposing (chat, code, codes, connect, cursor, deleteClassroom, disconnect, join, listClassrooms, publish, quiz, survey)
```

- [ ] **Step 4: Verify it compiles**

Run: `npx elm make src/elm/Main.elm --output=/dev/null`. This will show a compile error at every call site of `Service.Sync.connect` that doesn't yet pass `persistent` — that's expected; Task 9 fixes the one real call site in `Lia.Sync.Update`.

- [ ] **Step 5: Commit**

```bash
git add src/elm/Service/Sync.elm
git commit -m "feat: add persistent/fullBackend to Service.Sync.connect, add listClassrooms/deleteClassroom"
```

---

### Task 9: Elm `Lia.Sync.Types`/`Lia.Sync.Update` — model, messages, modal-open hook

**Files:**
- Modify: `src/elm/Lia/Sync/Types.elm`
- Modify: `src/elm/Lia/Sync/Update.elm`
- Modify: `src/elm/Lia/Settings/Update.elm:57-58` (type signature) and `:185-193` (`Toggle Sync`)
- Modify: `src/elm/Lia/Update.elm:423-441` (the `Settings.update` call site)

**Interfaces:**
- Consumes: `Lia.Sync.Classroom.Entry`/`decoder` (Task 7), `Service.Sync.listClassrooms/deleteClassroom/connect` (Task 8), `Via.Local`/`Via.fromString` (Task 6).
- Produces: `Settings.persistent : Bool`, `Settings.saved : List Classroom.Entry`, `Settings.deletePopup : Maybe String`, messages `TogglePersistent`, `AskDeleteClassroom`, `CancelDeleteClassroom`, `ConfirmDeleteClassroom`, `LoadClassroom`, `OpenNotes` — consumed by Task 10 (`View.elm`).

- [ ] **Step 1: Extend `Settings` in `Types.elm`**

```elm
type alias Settings =
    { sync : Sync
    , state : State
    , room : String
    , password : String
    , peers : Set String
    , error : Maybe String
    , data : Data
    , scriptsEnabled : Bool
    , persistent : Bool
    , saved : List Classroom.Entry
    , deletePopup : Maybe String
    }
```

Add the import (alongside the other `Lia.Sync.*` imports, near line 28):

```elm
import Lia.Sync.Classroom as Classroom
```

Update `init` (add three fields at the end of the record, after `scriptsEnabled = False`):

```elm
    , scriptsEnabled = False
    , persistent = False
    , saved = []
    , deletePopup = Nothing
    }
```

- [ ] **Step 2: Add messages to `Lia.Sync.Update`**

```elm
type Msg
    = Room String
    | Password String
    | Backend SyncMsg
    | Connect
    | Disconnect
    | Handle Event
    | Random_Generate
    | Random_Result String
    | EnabledScript Bool
    | TogglePersistent
    | LoadClassrooms
    | LoadClassroom Classroom.Entry
    | AskDeleteClassroom String
    | CancelDeleteClassroom
    | ConfirmDeleteClassroom String
    | OpenNotes
```

Add the import:

```elm
import Lia.Sync.Classroom as Classroom
import Json.Decode as JD
```

(`Json.Decode` is already imported — do not duplicate; only add `Lia.Sync.Classroom`.)

- [ ] **Step 3: Handle the new messages in `update`**

Add these cases to the `case msg of` block in `update` (anywhere after `EnabledScript`, e.g. right before `Connect`):

```elm
        TogglePersistent ->
            { model | sync = { sync | persistent = not sync.persistent } }
                |> Return.val

        LoadClassrooms ->
            model
                |> Return.val
                |> Return.batchEvent (Service.Sync.listClassrooms model.readme)

        LoadClassroom entry ->
            case Via.fromString entry.backend of
                Just backend ->
                    { model
                        | sync =
                            { sync
                                | sync = { sync.sync | select = Just ( True, backend ), open = False }
                                , room = entry.room
                                , password = entry.password |> Maybe.withDefault ""
                                , persistent = True
                            }
                    }
                        |> Return.val

                Nothing ->
                    model |> Return.val

        OpenNotes ->
            { model
                | sync =
                    { sync
                        | sync = { sync.sync | select = Just ( True, Backend.Local ), open = False }
                        , room = notesRoomName
                        , password = ""
                        , persistent = True
                    }
            }
                |> Return.val

        AskDeleteClassroom room ->
            { model | sync = { sync | deletePopup = Just room } }
                |> Return.val

        CancelDeleteClassroom ->
            { model | sync = { sync | deletePopup = Nothing } }
                |> Return.val

        ConfirmDeleteClassroom room ->
            { model
                | sync =
                    { sync
                        | deletePopup = Nothing
                        , saved = List.filter (\entry -> entry.room /= room) sync.saved
                    }
            }
                |> Return.val
                |> Return.batchEvent (Service.Sync.deleteClassroom model.readme room)
```

Add the constant near the bottom of the module (alongside `closeSelect`/`isConnected`):

```elm
notesRoomName : String
notesRoomName =
    "__notes__"
```

- [ ] **Step 4: Wire `persistent` into `Connect`, and handle the `"classrooms"` reply in `Handle`**

Update the `Connect` case (lines 240-252) to pass `persistent`:

```elm
        Connect ->
            case ( sync.sync.select, sync.state ) of
                ( Just ( True, backend ), Disconnected ) ->
                    { model | sync = { sync | state = Pending, sync = closeSelect sync.sync } }
                        |> Return.val
                        |> Return.batchEvent
                            (Service.Sync.connect
                                { backend = backend
                                , course = model.readme
                                , room = sync.room
                                , password = sync.password
                                , persistent = sync.persistent
                                }
                            )

                _ ->
                    model |> Return.val
```

Add a case inside the `Handle event -> case Event.message event of` block (alongside the existing `"update"`/`"error"`/`"connect"`/`"disconnect"` cases, e.g. right after `"disconnect"`):

```elm
                ( "classrooms", param ) ->
                    { model
                        | sync =
                            { sync
                                | saved =
                                    param
                                        |> JD.decodeValue Classroom.decoder
                                        |> Result.withDefault sync.saved
                            }
                    }
                        |> Return.val
```

- [ ] **Step 5: Trigger `LoadClassrooms` when the Sync modal opens**

In `src/elm/Lia/Settings/Update.elm`, add `readme : String` to the `main` record type (line 57-58):

```elm
update :
    Maybe { title : String, comment : Inlines, effectID : Maybe Int, logo : Maybe String, readme : String }
    -> Msg
    -> Settings
```

Add the import (if not already present — `Service.Database`, `Service.Share`, `Service.Slide`, `Service.TTS`, `Service.Translate` are already imported at the top; add):

```elm
import Service.Sync
```

Update the `Toggle Sync` case (lines 185-193) to fire `listClassrooms` on the closed→open transition, mirroring how `Toggle Sound`/`Toggle Chat` already conditionally batch events based on the pre-toggle state:

```elm
        Toggle Sync ->
            no_log Nothing { model | sync = Maybe.map not model.sync }
                |> Return.batchCmd
                    (if model.sync == Just False then
                        [ scheduleFocus Nothing Ignore "lia-modal-focus" ]

                     else
                        []
                    )
                |> Return.batchEvent
                    (if model.sync == Just False then
                        main
                            |> Maybe.map .readme
                            |> Maybe.withDefault ""
                            |> Service.Sync.listClassrooms

                     else
                        Event.none
                    )
```

In `src/elm/Lia/Update.elm`, update the `Settings.update` call site (lines 423-441) to pass `readme`:

```elm
                    Settings.update
                        (Just
                            { title = model.title
                            , comment = model.definition.comment
                            , effectID =
                                sec
                                    |> Maybe.map .effect_model
                                    |> Maybe.map .visible
                            , logo =
                                model.definition.logo
                                    |> (\logo ->
                                            if String.isEmpty logo then
                                                Nothing

                                            else
                                                Just logo
                                       )
                            , readme = model.readme
                            }
                        )
                        childMsg
                        model.settings
```

- [ ] **Step 6: Verify it compiles**

Run: `npx elm make src/elm/Main.elm --output=/dev/null`. Fix any remaining call sites (there should be none beyond what Steps 4-5 already updated, since `Service.Sync.connect`'s only call site is the one just changed).

- [ ] **Step 7: Commit**

```bash
git add src/elm/Lia/Sync/Types.elm src/elm/Lia/Sync/Update.elm src/elm/Lia/Settings/Update.elm src/elm/Lia/Update.elm
git commit -m "feat: model, messages and modal-open hook for persistent classrooms"
```

---

### Task 10: Elm `Lia.Sync.View` UI — checkbox, saved list, delete popup, notes tile + end-to-end verification

**Files:**
- Modify: `src/elm/Lia/Sync/View.elm`

**Interfaces:**
- Consumes: everything from Task 9 (`Settings.persistent/saved/deletePopup`, the new `Msg` variants).

- [ ] **Step 1: Add the "remember this classroom" checkbox**

In `view`, inside the `Just ( support, via ) ->` branch, right after the existing scripts-enabled checkbox block (lines 96-103):

```elm
                    , Html.div []
                        [ Backend.checkbox
                            { active =
                                open
                                    && support
                                    && (via /= Backend.Local)
                            , msg = TogglePersistent
                            , label = Html.text "Remember this classroom (saves settings and caches its content locally)"
                            , value = settings.persistent || via == Backend.Local
                            }
                        ]
```

(`via == Backend.Local` forces the checkbox visually checked-and-disabled for the notes backend, matching design decision 6 — notes are always persistent.)

- [ ] **Step 2: Add the saved-classrooms list + notes tile**

Add a new function and call it from `view`, right after the `select open settings.sync` line (line 51), before the `case settings.sync.select of` block:

```elm
        , savedList settings
```

```elm
savedList : Sync.Settings -> Html Msg
savedList settings =
    case settings.state of
        Sync.Disconnected ->
            Html.div [ Attr.style "margin-block-start" "2rem" ]
                [ Html.span [ Attr.class "lia-label" ] [ Html.text "Saved Classrooms" ]
                , Html.div []
                    (notesTile :: List.map (savedItem settings.deletePopup) settings.saved)
                ]

        _ ->
            Html.text ""


notesTile : Html Msg
notesTile =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "align-items" "center"
        , Attr.style "justify-content" "space-between"
        , Attr.style "padding" "5px 0"
        ]
        [ Html.button
            [ Event.onClick OpenNotes
            , Attr.class "lia-btn lia-btn--transparent"
            ]
            [ Backend.icon Backend.Local
            , Html.text "Own Notes (offline)"
            ]
        ]


savedItem : Maybe String -> Classroom.Entry -> Html Msg
savedItem deletePopup entry =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "align-items" "center"
        , Attr.style "justify-content" "space-between"
        , Attr.style "padding" "5px 0"
        ]
        [ Html.button
            [ Event.onClick (LoadClassroom entry)
            , Attr.class "lia-btn lia-btn--transparent"
            ]
            [ entry.backend
                |> Backend.fromString
                |> Maybe.map Backend.icon
                |> Maybe.withDefault (Html.text "")
            , Html.text entry.room
            ]
        , case deletePopup of
            Just room ->
                if room == entry.room then
                    Popup.view
                        { text = "Delete this saved classroom and its locally cached content? This cannot be undone."
                        , action = { msg = ConfirmDeleteClassroom entry.room, text = "Delete" }
                        , escape = CancelDeleteClassroom
                        }

                else
                    deleteBtn entry.room

            Nothing ->
                deleteBtn entry.room
        ]


deleteBtn : String -> Html Msg
deleteBtn room =
    btnIcon
        { msg = Just (AskDeleteClassroom room)
        , title = "Delete this saved classroom"
        , tabbable = True
        , icon = "icon-trash"
        }
        [ Attr.class "lia-btn--tag lia-btn--transparent text-red-dark border-red-dark px-1" ]
```

Add the needed imports at the top of `View.elm`:

```elm
import Index.View.Popup as Popup
import Lia.Sync.Classroom as Classroom
```

(`Backend.fromString`/`Backend.icon` are already exposed from `Lia.Sync.Via`, already imported as `Backend`.)

- [ ] **Step 2b: Confirmed `Popup.view`'s type**

`src/elm/Index/View/Popup.elm:20` — `view : { escape : msg, text : String, action : { msg : msg, text : String } } -> Html msg`. This matches the call in Step 2 exactly (`{ text = ..., action = { msg = ConfirmDeleteClassroom entry.room, text = "Delete" }, escape = CancelDeleteClassroom }`); no adjustment needed. Note `Popup.view` uses a module-level constant `groupID = "lia-popup"` for focus-group management shared with `Index.View.Card`'s usage — harmless here since the Sync modal and the Index course-list page are never rendered at the same time, and `Settings.deletePopup : Maybe String` guarantees at most one popup is open within the Sync modal itself.

- [ ] **Step 3: Verify it compiles**

Run: `npx elm make src/elm/Main.elm --output=/dev/null`.

- [ ] **Step 4: Full end-to-end manual verification**

Run: `npm run watch` (this serves the richest "dev" entry with hot reload), open the served URL in a browser with DevTools open (Application → IndexedDB):

1. Open a course, open the Classroom modal (header menu → "Classroom"). Confirm the "Saved Classrooms" section shows only the "Own Notes (offline)" tile (nothing saved yet).
2. Pick e.g. WebSocket backend (or any backend you can actually reach), type a room name, check "Remember this classroom", click Connect. Confirm connection succeeds as before (no regression).
3. Reload the page, reopen the Classroom modal. Confirm the room now appears in "Saved Classrooms". Click it — form should prefill with the same backend/room/password. Click Connect — confirm it reconnects and that chat history (if any was written) reappears instantly, before any remote peer round-trip, by checking DevTools → Application → IndexedDB for a database named `lia-classroom-<course>::<room>`.
4. Connect to a *different* room **without** checking "Remember this classroom". Reload, reopen the modal — confirm this room does **not** appear in the saved list.
5. Click the trash icon on a saved entry, confirm the popup, confirm it disappears from the list and its `lia-classroom-...` IndexedDB database is gone.
6. Click "Own Notes (offline)", connect, write a chat message, disconnect network (browser DevTools → Network → offline), reload the page, reopen the modal, click "Own Notes (offline)" again, connect — confirm the message is still there and no connection error appears (no network is ever attempted for `Local`).
7. Run `npm test` (full Elm test suite) and confirm it is still green.

- [ ] **Step 5: Commit**

```bash
git add src/elm/Lia/Sync/View.elm
git commit -m "feat: saved-classrooms list, persistence checkbox and notes tile in the Classroom modal"
```

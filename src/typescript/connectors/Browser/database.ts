// @ts-ignore
import Dexie from 'dexie'

import log from '../../liascript/log'

import { Record } from '../Base/index'

if (process.env.NODE_ENV === 'development') {
  // @ts-ignore
  Dexie.debug = true
}

class LiaDB {
  private dbIndex: Dexie

  private db: any
  private version: number

  /** One shared, already-opened connection per course database, see
   * `openShared_()`. */
  private dbCache: { [uidDB: string]: Promise<Dexie> } = {}

  /** Create a DexieDB instance that stores all states for:
   *
   * - quizzes
   * - code
   * - tasks
   * - surveys
   * - offline version of the course
   * - **and also offers an index for all courses**
   *
   */
  constructor() {
    this.dbIndex = new Dexie('Index')
    this.dbIndex.version(1).stores({
      courses: '&id,updated,author,created,title',
    })

    this.version = 0
  }

  /** Open the base collection of Dexie-stores that are used to by LiaScript.
   * If there is no such store, these are created. This is used as an internal
   * helper also to quickly setup all stores.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @returns Return a Dexie database instance with the "tables" =>
   *          `{code, quiz, survey, task, offline}`
   * @example
   *    open_('https://.../README.md')
   */
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
      classrooms: '[room+backend], updated',
      yjsUpdates: '++id, key',
      keys: '&id',
    })

    return db
  }

  /** Open — and from then on re-use — one connection per course database.
   *
   * `open_()` builds a *brand new* `Dexie` instance on every call, and none of
   * its callers ever close it again. That is acceptable for the rare
   * classroom-list queries, but `appendYjsUpdate()` runs for every single Yjs
   * frame (several per second while a classroom is connected, plus one per
   * replayed frame on connect) — leaking that many IndexedDB connections
   * exhausts the browser's connection budget, and every one of them has to
   * pass the `indexedDB.open` security guard from `patches/dexie+4.2.1.patch`
   * again.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   */
  private async openShared_(uidDB: string): Promise<Dexie> {
    let opening = this.dbCache[uidDB]

    if (!opening) {
      const db = this.open_(uidDB)

      opening = db.open().then(() => db)

      // a failed open must not be cached, otherwise the course would stay
      // broken for the rest of the session
      opening.catch(() => {
        delete this.dbCache[uidDB]
      })

      this.dbCache[uidDB] = opening
    }

    return opening
  }

  /** Open the initial database connection, that is used during the entire
   * session. All passed states are stored in the future, if the version number
   * is larger than 0. Otherwise this will be used as an filter, not to store
   * all the stuff, since we are dealing with some kind of development version.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param versionDB - A version number
   * @param init - This can be a record, which is used for an initial query
   * @returns The result of the query, otherwise it will be `unknown`
   * @example
   *    open('https://...raw../README.md', 1, {table: 'code', id: 12})
   */
  async open(uidDB: string, versionDB: number, init?: Record) {
    this.version = versionDB

    try {
      // the session connection is the very same instance that `openShared_()`
      // hands out, so `deleteIndex()` only has to close one of them
      this.db = await this.openShared_(uidDB)
    } catch (e: any) {
      log.warn('DB: open -> ', e.message)
      this.db = null
    }

    if (init && this.db) {
      const item = await this.db[init.table].get({
        id: init.id,
        version: versionDB,
      })

      return item
    }
  }

  /** Store any kind of data within one of the existing tables, `open()` has to
   * be called previously. The trailing version number is only used to overwrite
   * the default version number that has been defined previously.
   *
   * @param record - to be stored within the database
   * @param versionDB - optional version number for the database entry
   * @example
   *    store({table: 'quiz', id: 12, data: {...any}})
   */
  async store(record: Record, versionDB?: number) {
    if (!this.db || this.version === 0) return

    log.warn(
      `liaDB: event(store), table(${record.table}), id(${record.id}), data(${record.data})`
    )

    await this.db[record.table].put({
      id: record.id,
      version: versionDB != null ? versionDB : this.version,
      data: record.data,
      created: new Date().getTime(),
    })
  }

  /** Load an entry for a specific table and id from IndexedDB.
   *
   * @param record - information about the table and the id
   * @param versionDB - optional version number for the database entry
   * @returns The stored value, if it exists, otherwise it returns `unknown`
   * @example
   *    load({table: 'task', id: 12})
   */
  async load(record: Record, versionDB?: number) {
    if (!this.db) return

    log.info('loading => ', record.table, record.id)

    const item = await this.db[record.table].get({
      id: record.id,
      version: versionDB != undefined ? versionDB : this.version,
    })

    if (item) {
      log.info('restore table', record.table)

      return item.data
    }
    return null
  }

  /** This is a shorthand for updating the stored slide number within the
   * offline table of the currents database
   *
   * @param id - slide number
   */
  async slide(id: number) {
    try {
      let item = await this.db.offline.get({
        id: 0,
        version: this.version,
      })

      item.data.section_active = id

      await this.db.offline.put(item)
    } catch (e) {
      log.warn('DB: could not update slide => ', id)
    }
  }

  /** Use this to apply modifiers to certain records. This is mostly used to
   * handle the peculiar changes for the 'code' entries. Thus you have to be
   * aware of the internal structure of your entries!
   *
   * @param record - information about the table and the id
   * @param modify - transformation function
   */
  async transaction(record: Record, modify: (data: any) => any) {
    if (!this.db || this.version === 0) return

    let db = this.db

    await db.transaction('rw', db[record.table], async () => {
      const vector = await db[record.table].get({
        id: record.id,
        version: this.version,
      })

      if (vector.data) {
        vector.data = modify(vector.data)
        await db[record.table].put(vector)
      }
    })
  }

  /** If the course cannot be loaded and requires to be restored from the
   * browser, then this method needs to be called. It checks if the course has
   * been loaded before and then retrieves the course content from the
   * `offline` table.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param versionDB - An optional version number, if not defined the default is used.
   * @returns The pre-parsed JSON of the course, that can be directly loaded by LiaScript.
   * @example
   *    restore("httsp://.../README.md")
   */
  async restore(uidDB: string, versionDB?: number) {
    const course = await this.dbIndex['courses'].get(uidDB)

    if (course) {
      let db = await this.openShared_(uidDB)

      const offline = await db['offline'].get({
        id: 0,
        version: versionDB != null ? versionDB : this.version,
      })

      return offline === undefined ? null : offline.data
    }
  }

  /** Get the main course information stored within the index-db for a
   * particular course
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @returns
   */
  async getIndex(uidDB: string) {
    try {
      return await this.dbIndex['courses'].get(uidDB)
    } catch (e: any) {
      log.warn('DB: getIndex -> ', e.message)
    }
    return null
  }

  /** Return the entire list of courses within the index in order.
   *
   * @param order - Refers to the index entries (i.e., 'author', 'id', 'title', **the default is 'updated'**, etc.)
   * @param desc - Defines the order, by default `desc = false`
   * @returns
   */
  async listIndex(order = 'updated', desc = false) {
    const courses = await this.dbIndex['courses'].orderBy(order).toArray()

    if (!desc) {
      courses.reverse()
    }

    return courses
  }

  /** This method handles all functionality for storing and thus preserving an
   * entire course within the local index as well as making it offline
   * accessible.
   *
   * @param data - This is the entire preprocessed course with sections and meta-information
   * @returns
   */
  async storeIndex(data: any) {
    if (!this.dbIndex.isOpen()) {
      log.warn('DB: storeIndex ... db is closed')
      return
    }

    const date = new Date()
    let item = await this.dbIndex['courses'].get(data.readme)

    // If there is no item, then create an initial one
    if (!item) {
      item = {
        id: data.readme,
        title: data.definition.str_title,
        author: data.definition.author,
        created: date.getTime(),
        updated: null,
        updated_str: null,
        // this is a dictionary that will store all courses with their version
        // as a unique id
        data: {},
      }
    }

    item.updated = date.getTime()
    item.updated_str = date.toLocaleDateString()

    // check if the current version is already stored
    if (!item.data[data.version]) {
      item.data[data.version] = data.definition
      item.data[data.version]['title'] = data.title

      log.info('storing new version to index', item)

      // NOT `this.db`: `Database.ts`'s `index_store` fires `connector.open()`
      // without awaiting it and calls `storeToIndex()` right after, so by the
      // time we get here `open()` is usually still inside its asynchronous
      // `openShared_()` handshake - `this.db` would be `undefined` on the very
      // first course of a session, and still point at the PREVIOUS course on
      // every later one. `openShared_()` hands out the exact same connection
      // `open()` is waiting for, keyed by the course URL, so this is both safe
      // and race-free.
      let db = await this.openShared_(data.readme)

      await db['offline'].put({
        id: 0,
        version: data.version,
        data: data,
        created: date.getTime(),
        misc: {},
      })
    } else if (item.data[data.version].version !== data.definition.version) {
      item.data[data.version] = data.definition
      item.data[data.version]['title'] = data.title

      log.info('storing new version to index', item)

      let db = await this.openShared_(data.readme)

      await db['offline'].put({
        id: 0,
        version: data.version,
        data: data,
        created: date.getTime(),
        misc: {},
      })
    }

    this.dbIndex['courses'].put(item).then(function (result: any) {
      log.info('DB: storeIndex', result)
    })
  }

  async addMisc(
    uidDB: string,
    versionDB: number | null,
    key: string,
    value: any
  ) {
    const db = await this.openShared_(uidDB)

    await db.transaction('rw', db['offline'], async () => {
      let item = await db['offline'].get({
        id: 0,
        version: versionDB || this.version,
      })

      if (item) {
        item.misc[key] = value
        await db['offline'].put(item)
      }
    })
  }

  async getMisc(uidDB: string, versionDB: number | null, key?: string) {
    const db = await this.openShared_(uidDB)

    const item = await db['offline'].get({
      id: 0,
      version: versionDB || this.version,
    })

    if (key) {
      return item?.misc[key]
    }

    return item?.misc
  }

  /** Return all saved classrooms for a course, most recently updated first.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   */
  async getClassrooms(uidDB: string) {
    const db = await this.openShared_(uidDB)

    return await db['classrooms'].orderBy('updated').reverse().toArray()
  }

  /** Insert or update a saved classroom entry for a course.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param entry - room name and full encoded backend string (primary key), optional password.
   *   `mode` is stored too (not just cosmetic) - it is folded into the
   *   network room identity (see `Sync.uniqueID`), so reconnecting under a
   *   different mode joins a different room and loses the CRDT ownership
   *   history.
   */
  async saveClassroom(
    uidDB: string,
    entry: {
      room: string
      backend: string
      password?: string
      name?: string
      title?: string
      notes?: string
      mode?: number
      ownerTokenHash?: string
    }
  ) {
    const db = await this.openShared_(uidDB)

    const existing = await db['classrooms'].get([entry.room, entry.backend])
    const now = new Date().getTime()

    await db['classrooms'].put({
      room: entry.room,
      backend: entry.backend,
      password: entry.password || null,
      name: entry.name || null,
      title: entry.title || null,
      notes: entry.notes || null,
      mode: entry.mode || 0,
      ownerTokenHash: entry.ownerTokenHash || existing?.ownerTokenHash || null,
      created: existing ? existing.created : now,
      updated: now,
    })
  }

  /** Partially update an already-saved classroom entry, without touching
   * its password/mode/connection settings. Only the keys actually present
   * in `meta` are written - e.g. a title/notes edit (from the saved-
   * classrooms card grid) must not clobber the `owner` flag written
   * separately once a connection resolves CRDT ownership, and vice versa.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param room - the classroom's room name (part of the primary key)
   * @param backend - the full encoded backend string (part of the primary key)
   */
  async updateClassroomMeta(
    uidDB: string,
    room: string,
    backend: string,
    meta: {
      title?: string
      notes?: string
      name?: string
      owner?: boolean
      ownerTokenHash?: string
    }
  ) {
    const db = await this.openShared_(uidDB)
    const changes: {
      title?: string | null
      notes?: string | null
      name?: string | null
      owner?: boolean
      ownerTokenHash?: string | null
    } = {}

    if (meta.title !== undefined) changes.title = meta.title || null
    if (meta.notes !== undefined) changes.notes = meta.notes || null
    if (meta.name !== undefined) changes.name = meta.name || null
    if (meta.owner !== undefined) changes.owner = meta.owner
    if (meta.ownerTokenHash !== undefined)
      changes.ownerTokenHash = meta.ownerTokenHash || null

    await db['classrooms'].update([room, backend], changes)
  }

  /** Remove a saved classroom entry for a course.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param room - the classroom's room name (part of the primary key)
   * @param backend - the full encoded backend string (part of the primary key)
   */
  async deleteClassroom(uidDB: string, room: string, backend: string) {
    const db = await this.openShared_(uidDB)

    await db['classrooms'].delete([room, backend])
  }

  /** Return all cached Yjs update chunks for one classroom, in the order they
   * were written, so they can be replayed to reconstruct the document.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   */
  async getYjsUpdates(uidDB: string, key: string): Promise<Uint8Array[]> {
    const db = await this.openShared_(uidDB)

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
    const db = await this.openShared_(uidDB)

    await db['yjsUpdates'].add({ key, data, created: new Date().getTime() })
  }

  /** Atomically replace *all* cached Yjs updates of one classroom by a single
   * one. Used by `DexieTransport` to compact the cache right after it has
   * replayed the previously stored rows into the document: the replacement is
   * a full document snapshot that is equivalent to all of them together, so
   * nothing is lost — but only if the delete and the insert cannot be
   * separated, hence the transaction.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   * @param data - one raw Yjs update that supersedes everything stored so far
   */
  async replaceYjsUpdates(uidDB: string, key: string, data: Uint8Array) {
    const db = await this.openShared_(uidDB)

    await db.transaction('rw', db['yjsUpdates'], async () => {
      await db['yjsUpdates'].where('key').equals(key).delete()
      await db['yjsUpdates'].add({ key, data, created: new Date().getTime() })
    })
  }

  /** Remove all cached Yjs updates for one classroom.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param key - identifies one classroom, see `sync/Base/persist.ts`'s `docId`
   */
  async clearYjsUpdates(uidDB: string, key: string) {
    const db = await this.openShared_(uidDB)

    await db['yjsUpdates'].where('key').equals(key).delete()
  }

  /** Look up one classroom key/keypair cached for a course, see `putKey()`.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param id - identifies one key, see `sync/Base/keyStore.ts`'s `getOrCreateKey`
   */
  async getKey(uidDB: string, id: string): Promise<any> {
    const db = await this.openShared_(uidDB)

    const row = await db['keys'].get(id)

    return row?.value
  }

  /** Cache one classroom `CryptoKey`/`CryptoKeyPair` for a course, so it can
   * be reused across reconnects instead of regenerated - see
   * `sync/Base/keyStore.ts`'s `getOrCreateKey`. Not scoped by `this.version`:
   * classroom keys are per-room, not per-course-version.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param id - identifies one key, see `sync/Base/keyStore.ts`'s `getOrCreateKey`
   * @param value - a `CryptoKey` or `CryptoKeyPair`, directly structured-cloneable
   */
  async putKey(uidDB: string, id: string, value: any) {
    const db = await this.openShared_(uidDB)

    await db['keys'].put({ id, value })
  }

  /** Delete all entries for all versions of a certain course defined by its
   * URL. This removes all state information as well as the course from the
   * main index.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   */
  async deleteIndex(uidDB: string) {
    // an open connection blocks `Dexie.delete()`, so the shared one has to be
    // dropped first, see `openShared_()`
    const shared = this.dbCache[uidDB]

    if (shared) {
      delete this.dbCache[uidDB]

      try {
        ; (await shared).close()
      } catch (e) { }
    }

    // `open()` keeps a second reference to that very same instance. Closing a
    // Dexie does not neutralize it - `autoOpen` is on by default, so a later
    // `store()`/`slide()` through the stale `this.db` would re-create the
    // database that is being deleted right here.
    if (this.db?.name === uidDB) {
      this.db = null
    }

    await Promise.all([
      this.dbIndex['courses'].delete(uidDB),
      Dexie.delete(uidDB),
    ])
  }

  /** Delete all state information for a particular course and a particular version.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param versionDB - The version number of the course
   */
  async reset(uidDB: string, versionDB: number) {
    const db = await this.openShared_(uidDB)

    await Promise.all([
      db['code'].where('version').equals(versionDB).delete(),
      db['quiz'].where('version').equals(versionDB).delete(),
      db['survey'].where('version').equals(versionDB).delete(),
      db['task'].where('version').equals(versionDB).delete(),
    ])
  }
}

export { LiaDB }

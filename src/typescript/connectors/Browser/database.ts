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

    return db
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
    this.db = this.open_(uidDB)

    try {
      await this.db.open()
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
      let db = this.open_(uidDB)

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

      await this.db.offline.put({
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

      let db = this.open_(data.readme)
      await db.open()

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
    const db = this.open_(uidDB)
    await db.open()

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
    const db = this.open_(uidDB)
    await db.open()

    const item = await db['offline'].get({
      id: 0,
      version: versionDB || this.version,
    })

    if (key) {
      return item?.misc[key]
    }

    return item?.misc
  }

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

  /** Delete all state information for a particular course and a particular version.
   *
   * @param uidDB - A string URL or URI, which identifies the source of a course.
   * @param versionDB - The version number of the course
   */
  async reset(uidDB: string, versionDB: number) {
    const db = this.open_(uidDB)
    await db.open()

    await Promise.all([
      db['code'].where('version').equals(versionDB).delete(),
      db['quiz'].where('version').equals(versionDB).delete(),
      db['survey'].where('version').equals(versionDB).delete(),
      db['task'].where('version').equals(versionDB).delete(),
    ])
  }
}

export { LiaDB }

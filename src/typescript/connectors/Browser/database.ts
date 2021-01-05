import Dexie from 'dexie'

import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'
import log from '../../liascript/log'


if (process.env.NODE_ENV === 'development') {
  Dexie.debug = true
}

class LiaDB {
  private send: Lia.Send
  private dbIndex: Dexie

  private db: any
  private version: number

  constructor(send: Lia.Send) {
    this.send = send

    this.dbIndex = new Dexie('Index')
    this.dbIndex.version(1).stores({
      courses: '&id,updated,author,created,title'
    })

    this.version = 0
  }

  open_(uidDB: string) {
    let db = new Dexie(uidDB)

    db.version(1).stores({
      code: '[id+version], version',
      quiz: '[id+version], version',
      survey: '[id+version], version',
      offline: '[id+version], version'
    })

    return db
  }

  async open(uidDB: string, versionDB: number, init?: Lia.Event) {
    this.version = versionDB
    this.db = this.open_(uidDB)
    await this.db.open()

    if (init) {
      const item = await this.db[init.topic].get({
        id: init.section,
        version: versionDB
      })

      if (!!item) {
        if (item.data) {
          init.message.message = item.data
        }
        this.send(init)
      }
    }
  }

  async store(event: Lia.Event, versionDB?: number) {
    if (!this.db || this.version === 0) return

    log.warn(`liaDB: event(store), table(${event.topic}), id(${event.section}), data(${event.message})`)

    await this.db[event.topic].put({
      id: event.section,
      version: versionDB != null ? versionDB : this.version,
      data: event.message,
      created: new Date().getTime()
    })
  }

  async load(event: Lia.Event, versionDB?: number) {
    if (!this.db) return

    log.info('loading => ', event.topic, event.section)

    const item = await this.db[event.topic].get({
      id: event.section,
      version: versionDB != undefined ? versionDB : this.version
    })

    if (item) {
      log.info('restore table', event.topic) //, e._value.data)
      event.message = {
        topic: Port.RESTORE,
        section: -1,
        message: item.data
      }
      this.send(event)
    } else if (event.topic === Port.CODE) {
      event.message = {
        topic: Port.RESTORE,
        section: -1,
        message: null
      }
      this.send(event)
    }
  }

  del() {
    if (!this.db) return

    const name = this.db.name

    this.db.delete()
      .then(() => {
        log.info('database deleted: ', name)
      })
      .catch((err: Error) => {
        log.error('error deleting database: ', name, err)
      })
  }

  async slide(id: number) {
    try {
      let data = await this.db.offline.get({
        id: 0,
        version: this.version
      })

      data.data.section_active = id

      await this.db.offline.put(data)
    } catch (e) { }
  }

  async update(event: Lia.Event, slide: number) {
    if (!this.db || this.version === 0) return

    let db = this.db
    await db.transaction('rw', db.code, async () => {
      const vector = await db.code.get({
        id: slide,
        version: this.version
      })

      if (vector.data) {
        let project = vector.data[event.section]

        switch (event.topic) {
          case 'flip': {
            if (event.message.topic === 'view') {
              project.file[event.message.section].visible = event.message.message
            } else if (event.message.topic === 'fullscreen') {
              project.file[event.message.section].fullscreen = event.message.message
            }
            break
          }
          case 'load': {
            let e_ = event.message
            project.version_active = e_.version_active
            project.log = e_.log
            project.file = e_.file
            break
          }
          case 'version_update': {
            let e_ = event.message
            project.version_active = e_.version_active
            project.log = e_.log
            project.version[e_.version_active] = e_.version
            break
          }
          case 'version_append': {
            let e_ = event.message
            project.version_active = e_.version_active
            project.log = e_.log
            project.file = e_.file
            project.version.push(e_.version)
            project.repository = {
              ...project.repository,
              ...e_.repository
            }
            break
          }
          default: {
            log.warn('unknown update cmd: ', event)
          }
        }

        vector.data[event.section] = project

        await (db.code.put(vector))
      }
    })
  }

  async restore(uidDB: string, versionDB?: number) {
    const course = await this.dbIndex.courses.get(uidDB)

    if (course) {
      // let latest = parseInt(Object.keys(course.data).sort().reverse())

      let db = this.open_(uidDB)

      const offline = await db.offline.get({
        id: 0,
        version: versionDB != null ? versionDB : this.version
      })

      this.send({
        topic: Port.RESTORE,
        message: offline === undefined ? null : offline.data,
        section: -1
      })
    }
  }

  async getIndex(uidDB: string) {
    const course = await this.dbIndex.courses.get(uidDB)

    this.send({
      topic: 'getIndex',
      message: {
        id: uidDB,
        course: course
      },
      section: -1
    })
  }

  async listIndex(order = 'updated', desc = false) {
    const courses = await this.dbIndex.courses.orderBy(order).toArray()

    if (!desc) {
      courses.reverse()
    }

    this.send({
      topic: Port.INDEX,
      section: -1,
      message: {
        list: courses
      }
    })
  }

  async storeIndex(data: any) {
    let date = new Date()
    let item = await this.dbIndex.courses.get(data.readme)

    if (!item) {
      item = {
        id: data.readme,
        title: data.definition.str_title,
        author: data.definition.author,
        data: {},
        created: date.getTime(),
        updated: null,
        updated_str: null
      }
    }

    item.updated = date.getTime()
    item.updated_str = date.toLocaleDateString()

    if (!item.data[data.version]) {
      item.data[data.version] = data.definition
      item.data[data.version]['title'] = data.title

      log.info('storing new version to index', item)

      await this.db.offline.put({
        id: 0,
        version: data.version,
        data: data,
        created: date.getTime()
      })
    } else if (item.data[data.version].version !== data.definition.version) {
      item.data[data.version] = data.definition
      item.data[data.version]['title'] = data.title

      log.info('storing new version to index', item)

      let db = this.open_(data.readme)
      await db.open()

      await db.offline.put({
        id: 0,
        version: data.version,
        data: data,
        created: date.getTime()
      })
    }

    this.dbIndex.courses.put(item)
  }

  async deleteIndex(uidDB: string) {
    await Promise.all([
      this.dbIndex.courses.delete(uidDB),
      Dexie.delete(uidDB)
    ])
  }

  async reset(uidDB: string, versionDB: number) {
    let db = this.open_(uidDB)
    await db.open()

    await Promise.all([
      db.code.where('version').equals(versionDB).delete(),
      db.quiz.where('version').equals(versionDB).delete(),
      db.survey.where('version').equals(versionDB).delete()
    ])
  }
};

export {
  LiaDB
}

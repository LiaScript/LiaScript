import Dexie from 'dexie'


if (process.env.NODE_ENV === 'development') {
  Dexie.debug = true
}

import {
  lia
} from './logger'

class LiaDB {
  constructor (send = null, channel = null) {
    this.channel = channel
    this.send = send

        // this.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

    this.dbIndex = new Dexie("Index")
    this.dbIndex.version(1).stores({courses: '&id,updated,author,created,title'})
  }

  open_ (uidDB) {
    let db = new Dexie(uidDB)

    db.version(1).stores({
      code: '[id+version], version',
      quiz: '[id+version], version',
      survey: '[id+version], version',
      offline: '[id+version], version'
    })

    return db
  }

  async open (uidDB, versionDB, init) {

    if (this.channel) return

    return

    this.version = versionDB
    this.db = this.open_(uidDB)
    await this.db.open()

    if(init) {
      const item = await this.db[init.topic].get({
        id: init.section,
        version: versionDB
      })

      if(!!item) {
        if (item.data) {
          init.message.message = item.data
        }
        this.send(init)
      }
    }
  }

  async store (event, versionDB = null) {
    if (this.channel) {
      storeChannel(event)
      return
    }

    if (!this.db || this.version == 0) return

    lia.warn(`liaDB: event(store), table(${event.topic}), id(${event.section}), data(${event.message})`)

    await this.db[event.topic].put({
      id: event.section,
      version: versionDB != null ? versionDB : this.version,
      data: event.message,
      created: new Date().getTime()
    })
  }

  storeChannel (event) {
    this.channel.push('lia', {
      store: event.topic,
      slide: event.section,
      data: event.message
    })
      .receive('ok', e => {
        lia.log('ok', e)
      })
      .receive('error', e => {
        lia.log('error', e)
      })
  }

  async load (event, versionDB = null) {
    if (this.channel) {
      this.loadChannel(event)
      return
    }

    if (!this.db) return

    lia.log('loading => ', event.topic, event.section)

    const item = await this.db[event.topic].get({
      id: event.section,
      version: versionDB != null ? versionDB : this.version,
    })

    if(item) {
      lia.log('restore table', event.topic)//, e._value.data)
      event.message = {
        topic: 'restore',
        section: -1,
        message: item.data
      }
      this.send(event)
    } else if (event.topic === 'code') {
      event.message = {
        topic: 'restore',
        section: -1,
        message: null
      }
      this.send(event)
    }
  }

  loadChannel(event) {
    let send = this.send

    this.channel.push('lia', {
      load: event.topic,
      slide: event.section
    })
      .receive('ok', e => {
        event.message = {
          topic: 'restore',
          section: -1,
          message: e.date
        }
        send(event)
      })
      .receive('error', e => {
        lia.error(e)
      })
  }

  del () {
    if (this.channel || !this.db) return

    let name = db.name

    this.db.delete()
      .then(() => { lia.log('database deleted: ', name) })
      .catch((err) => { lia.error('error deleting database: ', name) })
  }

  async slide (idx) {
    try{
      let data = await this.db.offline.get({
        id: 0,
        version: this.version
      })

      data.data.section_active = idx

      await this.db.offline.put(data)
    } catch (e) {}
  }


  async update (event, slide) {
    if (this.channel) {
      this.channel.push('lia', {
        update: event,
        slide: slide
      })
      return
    }

    if (!this.db || this.version == 0) return

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
            project.repository = { ...project.repository, ...e_.repository }
            break
          }
          default: {
            lia.warn('unknown update cmd: ', event)
          }
        }

        vector.data[event.section] = project

        await (db.code.put(vector))
      }
    })
  }

  async restore(uidDB, versionDB = null) {
    const course = await this.dbIndex.courses.get(uidDB)

    if (course) {
      let latest = parseInt( Object.keys(course.data).sort().reverse() )

      let db = this.open_(uidDB)

      const offline = await db.offline.get({
        id: 0,
        version: versionDB != null ? versionDB : this.version
      })

      this.send({
        topic: "restore",
        message: offline == undefined ? null : offline.data,
        section: -1
      });
    }
  }

  async getIndex(uidDB) {
    const course = await this.dbIndex.courses.get(uidDB)

    this.send({
      topic: "getIndex",
      message: {
        id: uidDB,
        course: course
      },
      section: -1
    });
  }

  async listIndex(order = 'updated', desc = false) {
    if (this.channel) return

    const courses = await this.dbIndex.courses.orderBy(order).toArray()

    if(!desc) {
      courses.reverse()
    }

    this.send({
      topic: 'index',
      section: -1,
      message: { list: courses }
    })
  }

  async storeIndex(data) {
    if (this.channel) return

    let date = new Date()
    let item = await this.dbIndex.courses.get(data.readme)

    if (!item) {
      item = {
        id: data.readme,
        title: data.definition.str_title,
        author: data.definition.author,
        data: { },
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

      lia.log('storing new version to index', item)

      await this.db.offline.put({
        id: 0,
        version: data.version,
        data: data,
        created: date.getTime()
      })

    } else if (item.data[data.version].version !== data.definition.version) {
        item.data[data.version] = data.definition
        item.data[data.version]['title'] = data.title

        lia.log('storing new version to index', item)

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

  async deleteIndex(uidDB) {
    if (this.channel) return

    await Promise.all([
      this.dbIndex.courses.delete(uidDB),
      Dexie.delete(uidDB)
    ])
  }

  async reset(uidDB, versionDB) {
    let db = this.open_(uidDB)
    await db.open()

    await Promise.all([
      db.code.where("version").equals(versionDB).delete(),
      db.quiz.where("version").equals(versionDB).delete(),
      db.survey.where("version").equals(versionDB).delete()
    ])
  }

};

export { LiaDB }

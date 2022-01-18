import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'
import log from '../../liascript/log'

import { LiaDB } from './database'
import { Connector as Base, Record } from '../Base/index'

class Connector extends Base {
  private database: LiaDB

  constructor() {
    super()
    this.database = new LiaDB()
  }

  hasIndex() {
    return true
  }

  async open(uidDB: string, versionDB: number, slide: number) {
    return await this.database.open(uidDB, versionDB, {
      table: 'code',
      id: slide,
    })
  }

  load(record: Record) {
    return this.database.load(record)
  }

  store(record: Record) {
    return this.database.store(record)
  }

  update(cmd: string, record: Record, id: number) {
    if (this.database) {
      /** let project = vector.data[event.track[0][1]]

        switch (event.track[0][0]) {
          case 'flip': {
            if (event.track[1][0] === 'view') {
              project.file[event.track[1][1]].visible = event.message
            } else if (
              event.track[1][0] === 'fullscreen' &&
              event.track[1][1] !== -1
            ) {
              project.file[event.track[1][1]].fullscreen = event.message
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
              ...e_.repository,
            }
            break
          }
          default: {
            log.warn('unknown update cmd: ', event)
          }
        }

        vector.data[event.track[0][1]] = project */

      let fn = (a: any) => a

      switch (cmd) {
        default:
          log.warn('unknown update cmd: ', record)
      }

      if (fn) this.database.transaction(record, fn)
    }
  }

  slide(id: number) {
    this.database.slide(id)
  }

  async getIndex() {
    return await this.database.listIndex()
  }

  deleteFromIndex(uidDB: string) {
    this.database.deleteIndex(uidDB)
  }

  storeToIndex(json: any) {
    this.database.storeIndex(json)
  }

  restoreFromIndex(uidDB: string, versionDB?: number) {
    return this.database.restore(uidDB, versionDB)
  }

  async reset(uidDB?: string, versionDB?: number) {
    if (uidDB && versionDB) {
      await this.database.reset(uidDB, versionDB)

      log.info('DB: reset => ', uidDB, versionDB)
    }
  }

  getFromIndex(uidDB: string) {
    return this.database.getIndex(uidDB)
  }
}

export { Connector }

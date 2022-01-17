import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'
import log from '../../liascript/log'

import { LiaDB } from './database'
import { Connector as Base } from '../Base/index'

class Connector extends Base {
  private database?: LiaDB

  hasIndex() {
    return true
  }

  connect(send: Lia.Send | null) {
    if (send) {
      this.send = send
    }

    this.database = new LiaDB()
    this.initSettings(this.getSettings(), true)
  }

  open(uidDB: string, versionDB: number, slide: number, _data?: Lia.Event) {
    if (this.database)
      this.database.open(uidDB, versionDB, {
        reply: true,
        track: [
          [Port.CODE, slide],
          [Port.RESTORE, -1],
        ],
        service: null,
        message: null,
      })
  }

  async load(event: Lia.Event) {
    if (this.database) {
      const item = await this.database.load(event.message.param)

      if (item) {
        event.message.param = item
        this.send(event)
      }
    }
  }

  store(event: Lia.Event) {
    if (this.database) {
      this.database.store(event.message.param)
    }
  }

  update(event: Lia.Event, id: number) {
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

      let fn

      switch (event.message.cmd) {
        default:
          log.warn('unknown update cmd: ', event)
      }

      if (fn) this.database.transaction(event.message.param, fn)
    }
  }

  slide(id: number) {
    if (this.database) this.database.slide(id)
  }

  async getIndex() {
    if (this.database) {
      return await this.database.listIndex()
    }
  }

  deleteFromIndex(uidDB: string) {
    if (this.database) this.database.deleteIndex(uidDB)
  }

  storeToIndex(json: any) {
    if (this.database) this.database.storeIndex(json)
  }

  restoreFromIndex(uidDB: string, versionDB?: number) {
    if (this.database) this.database.restore(uidDB, versionDB)
  }

  async reset(uidDB?: string, versionDB?: number) {
    if (this.database && uidDB && versionDB) {
      await this.database.reset(uidDB, versionDB)

      log.info('DB: resetting => ', uidDB, versionDB)
    }
  }

  getFromIndex(uidDB: string) {
    if (this.database) {
      return this.database.getIndex(uidDB)
    }
  }
}

export { Connector }

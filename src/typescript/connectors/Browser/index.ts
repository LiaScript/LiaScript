import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'

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

    this.database = new LiaDB(this.send)
    this.initSettings(this.getSettings(), true)
  }

  open(uidDB: string, versionDB: number, slide: number, _data?: Lia.Event) {
    if (this.database)
      this.database.open(
        uidDB,
        versionDB, {
          topic: Port.CODE,
          section: slide,
          message: {
            topic: Port.RESTORE,
            section: -1,
            message: null
          }
        })
  }

  load(event: Lia.Event) {
    if (this.database)
      this.database.load(event)
  }

  store(event: Lia.Event) {
    if (this.database)
      this.database.store(event)
  }

  update(event: Lia.Event, id: number) {
    if (this.database)
      this.database.update(event, id)
  }

  slide(id: number) {
    if (this.database)
      this.database.slide(id)
  }

  getIndex() {
    if (this.database)
      this.database.listIndex()
  }

  deleteFromIndex(uidDB: string) {
    if (this.database)
      this.database.deleteIndex(uidDB)
  }

  storeToIndex(json: any) {
    if (this.database)
      this.database.storeIndex(json)
  }

  restoreFromIndex(uidDB: string, versionDB?: number) {
    if (this.database)
      this.database.restore(uidDB, versionDB)
  }

  reset(uidDB?: string, versionDB?: number) {
    if (this.database && uidDB && versionDB)
      this.database.reset(uidDB, versionDB)
  }

  getFromIndex(uidDB: string) {
    if (this.database)
      this.database.getIndex(uidDB)
  }
}

export {
  Connector
}

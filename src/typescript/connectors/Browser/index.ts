import Lia from '../../liascript/types/lia.d'
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

  update(record: Record, mapping: (project: any) => any) {
    this.database.transaction(record, mapping)
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

import log from '../../liascript/log'

import * as DB from './database'
import * as Base from '../Base/index'

class Connector extends Base.Connector {
  private database: DB.LiaDB

  constructor() {
    super()
    this.database = new DB.LiaDB()
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

  load(record: Base.Record) {
    return this.database.load(record)
  }

  store(record: Base.Record) {
    return this.database.store(record)
  }

  update(record: Base.Record, mapping: (project: any) => any) {
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

  async addMisc(
    uidDB: string,
    versionDB: number | null,
    key: string,
    value: any
  ) {
    this.database.addMisc(uidDB, versionDB, key, value)
  }

  async getMisc(uidDB: string, versionDB: number | null) {
    return this.database.getMisc(uidDB, versionDB)
  }
}

export { Connector }

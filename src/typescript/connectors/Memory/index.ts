import * as Base from '../Base/index'

// one array per table (code, quiz, survey, task), the index is the id
export type DB = { [table: string]: any[] }

/**
 * Keeps all states (code, quiz, survey, task) in memory, such that they can be
 * exported and imported as JSON. Every change is reported via `onStore`.
 */
export class Connector extends Base.Connector {
  private db: DB = {}
  private onStore: (record: Base.Record) => void

  constructor(onStore: (record: Base.Record) => void = () => {}) {
    super()
    this.onStore = onStore
  }

  load(record: Base.Record) {
    return this.db[record.table]?.[record.id] ?? null
  }

  loadAll(table: string) {
    return (this.db[table] || []).flatMap((data, id) =>
      data == null ? [] : [{ id, data }]
    )
  }

  store(record: Base.Record) {
    ;(this.db[record.table] ??= [])[record.id] = record.data
    this.onStore(record)
  }

  update(record: Base.Record, fn: (a: any) => any) {
    const data = this.db[record.table]?.[record.id]
    if (data != null) {
      this.store({ ...record, data: fn(data) })
    }
  }

  toJSON(): DB {
    return JSON.parse(JSON.stringify(this.db))
  }

  fromJSON(db: DB = {}) {
    this.db = JSON.parse(JSON.stringify(db))
  }
}

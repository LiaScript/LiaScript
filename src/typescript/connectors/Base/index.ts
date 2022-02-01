import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'

import { LiaStorage } from './storage'
import { initSettings, defaultSettings } from './settings'

/** Internal abstraction to query the database. All entries are organized with
 * tables, which represent either `code`, `quiz`, `survey`, `task`, `offline`.
 * Since LiaScript communicates the via slides, the slide numbers are also used
 * as the `id` for an entry. And the data per slide is mostly also organized as
 * and array, where each element has to be identified separately.
 */
export type Record = {
  table: string
  id: number
  data?: any
}

export class Connector {
  constructor() {}

  hasIndex() {
    return false
  }

  storage() {
    return new LiaStorage()
  }

  initSettings(data: Lia.Settings | null, local = false) {
    return initSettings(data ? data : undefined, local)
  }

  setSettings(data: Lia.Settings) {
    localStorage.setItem(Port.SETTINGS, JSON.stringify(data))
  }

  getSettings() {
    const data = localStorage.getItem(Port.SETTINGS)
    let json: Lia.Settings | null = null

    if (typeof data === 'string') {
      try {
        json = JSON.parse(data)
      } catch (e) {
        console.warn('getSettings =>', e)
      }

      if (!json) {
        json = defaultSettings
      }

      if (window.innerWidth <= 768) {
        json.table_of_contents = false
      }
    }

    return json
  }

  open(_uidDB: string, _versionDB: number, _slide: number) {}

  load(_record: Record) {}

  store(_record: Record) {}

  update(_record: Record, _fn: (a: any) => any) {}

  slide(_id: number) {}

  getIndex() {}

  deleteFromIndex(_uidDB: string) {}

  storeToIndex(_json: any) {}

  restoreFromIndex(_uidDB: string, _versionDB?: number) {}

  reset(_uidDB?: string, _versionDB?: number) {
    this.initSettings(null, true)
  }

  getFromIndex(_uidDB: string) {}
}

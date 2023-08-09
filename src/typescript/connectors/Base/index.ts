import Lia from '../../liascript/types/lia.d'

import * as STORAGE from './storage'
import { Settings } from './settings'
import log from '../../liascript/log'

/**
 * **private helper:** defines a couple of transaction only for the data stored
 * in the "code" table.
 *
 * @param def
 * @returns a function that modifies a certain sub-entry within the database
 */
export function transform(
  transaction: {
    cmd: string
    id: number
    data: any
  },
  project: any
) {
  switch (transaction.cmd) {
    // update the current version and logs
    case 'version':
      project[transaction.id].version_active = transaction.data.version_active
      project[transaction.id].log = transaction.data.log
      project[transaction.id].version[transaction.data.version_active] =
        transaction.data.version

      break

    // append a new version of files and logs
    case 'append':
      project[transaction.id].version_active = transaction.data.version_active
      project[transaction.id].log = transaction.data.log
      project[transaction.id].file = transaction.data.file
      project[transaction.id].version.push(transaction.data.version)
      project[transaction.id].repository = {
        ...project[transaction.id].repository,
        ...transaction.data.repository,
      }

      break

    // change the active version of the project
    case 'active':
      project[transaction.id].version_active = transaction.data.version_active
      project[transaction.id].log = transaction.data.log
      project[transaction.id].file = transaction.data.file

      break

    case 'flip_view':
      project[transaction.id].file[transaction.data.file_id].visible =
        transaction.data.value

      break

    case 'flip_fullscreen':
      project[transaction.id].file[transaction.data.file_id].fullscreen =
        transaction.data.value

      break

    default:
      log.warn('unknown update cmd: ', transaction.cmd)
  }

  return project
}

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

/** This Abstract class shall be implemented by any Connector-Class. If any the
 * base class is used instead, that means, that no data ist stored.
 *
 */
export class Connector {
  constructor() {}

  /** If your connector defines functionalities to store and cache entire
   * courses, then set this to `true`. This will result in an home-button
   * within the table of contents and an overview on all previously loaded
   * courses.
   *
   * If this this is true, then all the other methods within the INDEX part
   * have to be implemented too.
   *
   * @returns boolean (default `false`)
   */
  hasIndex(): boolean {
    return false
  }

  hideIndex() {
    return false
  }

  storage() {
    return new STORAGE.LiaStorage()
  }

  initSettings(data: Lia.Settings | null, local = false) {
    return Settings.init(data, local, this.setSettings)
  }

  setSettings(data: Lia.Settings) {
    try {
      localStorage.setItem(Settings.PORT, JSON.stringify(data))
    } catch (e) {
      console.warn('cannot write to localStorage')
    }
  }

  getSettings() {
    let data: string | null = ''

    try {
      data = localStorage.getItem(Settings.PORT)
    } catch (e) {
      console.warn('cannot write to localStorage')
    }

    let json: Lia.Settings | null = null

    if (typeof data === 'string') {
      try {
        json = JSON.parse(data)
      } catch (e) {
        console.warn('getSettings =>', e)
      }

      if (!json) {
        json = Settings.data
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

  update(
    _transaction: {
      cmd: string
      id: number
      data: any
    },
    _record: Record
  ) {}

  slide(_id: number) {}

  // ----------------------- INDEX functionalities ----------------------------

  getIndex() {}

  deleteFromIndex(_uidDB: string) {}

  storeToIndex(_json: any) {}

  restoreFromIndex(_uidDB: string, _versionDB?: number) {}

  reset(_uidDB?: string, _versionDB?: number) {
    this.initSettings(null, true)
  }

  async getFromIndex(_uidDB: string) {
    return null
  }
}

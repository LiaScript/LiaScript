import Lia from '../../liascript/types/lia.d'

import * as STORAGE from './storage'
import { Settings } from './settings'

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

  storage() {
    return new STORAGE.LiaStorage()
  }

  initSettings(data: Lia.Settings | null, local = false) {
    return Settings.init(data, local, this.setSettings)
  }

  setSettings(data: Lia.Settings) {
    Settings.update(data)
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

  update(_record: Record, _fn: (a: any) => any) {}

  slide(_id: number) {}

  // ----------------------- INDEX functionalities ----------------------------

  getIndex() {}

  deleteFromIndex(_uidDB: string) {}

  async storeToIndex(_json: any) {}

  restoreFromIndex(_uidDB: string, _versionDB?: number) {}

  reset(_uidDB?: string, _versionDB?: number) {
    this.initSettings(null, true)
  }

  async getFromIndex(_uidDB: string) {
    return null
  }

  async addMisc(
    _uidDB: string,
    _versionDB: number | null,
    _key: string,
    _value: any
  ) {
    console.log('addMisc not implemented')
  }

  async getMisc(_uidDB: string, _versionDB: number | null, _key?: string) {
    console.log('getMisc not implemented')
  }

  async getClassrooms(_uidDB: string): Promise<any[]> {
    return []
  }

  async saveClassroom(
    _uidDB: string,
    _entry: {
      room: string
      backend: string
      password?: string
      name?: string
      title?: string
      notes?: string
    }
  ) {
    console.log('saveClassroom not implemented')
  }

  async updateClassroomMeta(
    _uidDB: string,
    _room: string,
    _backend: string,
    _meta: { title?: string; notes?: string; owner?: boolean }
  ) {
    console.log('updateClassroomMeta not implemented')
  }

  async deleteClassroom(_uidDB: string, _room: string, _backend: string) {
    console.log('deleteClassroom not implemented')
  }

  // The classroom/Yjs persistence below is - exactly like `addMisc`/`getMisc`
  // above - a Browser-connector-only feature: SCORM, xAPI and H5P have no
  // IndexedDB-backed course database, so they intentionally no-op these
  // methods instead of implementing them.

  async getYjsUpdates(_uidDB: string, _key: string): Promise<Uint8Array[]> {
    return []
  }

  async appendYjsUpdate(_uidDB: string, _key: string, _data: Uint8Array) {
    console.log('appendYjsUpdate not implemented')
  }

  async replaceYjsUpdates(_uidDB: string, _key: string, _data: Uint8Array) {
    console.log('replaceYjsUpdates not implemented')
  }

  async clearYjsUpdates(_uidDB: string, _key: string) {
    console.log('clearYjsUpdates not implemented')
  }
}

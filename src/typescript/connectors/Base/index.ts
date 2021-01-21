import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'

import { LiaStorage } from './storage'
import { initSettings, defaultSettings } from './settings'


export class Connector {

  protected send: Lia.Send

  constructor() {
    this.send = (_) => null
  }

  hasIndex() {
    return false
  }

  connect(send: Lia.Send | null) {
    if (send)
      this.send = send
  }

  storage() {
    return new LiaStorage()
  }

  initSettings(data: Lia.Settings | null, local = false) {
    initSettings(this.send, data ? data : undefined, local)
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

      if (window.innerWidth <= 620) {
        json.table_of_contents = false
      }
    }

    return json
  }

  open(_uidDB: string, _versionDB: number, _slide: number, _data?: Lia.Event) { }

  load(_event: Lia.Event) { }

  store(_event: Lia.Event) { }

  update(_event: Lia.Event, _id: number) { }

  slide(_id: number) { }

  getIndex() { }

  deleteFromIndex(_uidDB: string) { }

  storeToIndex(_json: any) { }

  restoreFromIndex(_uidDB: string, _versionDB?: number) { }

  reset(_uidDB?: string, _versionDB?: number) {
    this.initSettings(null, true)
  }

  getFromIndex(_uidDB: string) {
    this.send({
      topic: Port.RESTORE,
      message: null,
      section: -1
    })
  }
}

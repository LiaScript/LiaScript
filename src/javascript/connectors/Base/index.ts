import Lia from '../../liascript/types.d'

import { LiaStorage } from './storage'
import { SETTINGS, initSettings, defaultSettings } from './settings'

export class Connector {

  private send: Lia.Send

  constructor () {
    this.send = (_) => null
  }

  hasIndex () {
    return false
  }

  connect (send: Lia.Send | null) {
    if (send)
      this.send = send
  }

  storage () {
    return new LiaStorage()
  }

  initSettings (data?: Lia.Settings, local = false) {
    initSettings(this.send, data, local)
  }

  setSettings (data: Lia.Settings) {
    localStorage.setItem(SETTINGS, JSON.stringify(data))
  }

  getSettings () {
    const data = localStorage.getItem(SETTINGS)
    let json: Lia.Settings | null = null

    if(typeof data === 'string') {
      try {
        json = JSON.parse(data)
      } catch(e) {
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

  open (_uidDB: string, _versionDB: number, _slide: number, _data?: Lia.Event) {}

  load (_event: Lia.Event) {}

  store (_event: Lia.Event) {}

  update (_event: Lia.Event, _id: number) {}

  slide (_id: number) {}

  getIndex () {}

  deleteFromIndex (_msg: Lia.Event) {}

  storeToIndex (_json: any) {}

  restoreFromIndex (_uidDB: string, _versionDB?: number) {}

  reset (_uidDB: string, _versionDB?: number) {
    this.initSettings(undefined, true)
  }

  getFromIndex (_uidDB: string) {
    this.send({
      topic: 'restore',
      message: null,
      section: -1
    })
  }
}

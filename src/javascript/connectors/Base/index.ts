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

  open (uidDB: string, versionDB: number, slide: number, data?: Lia.Event) {}

  load (event: Lia.Event) {}

  store (event: Lia.Event) {}

  update (event: Lia.Event, id: number) {}

  slide (id: number) {}

  getIndex () {}

  deleteFromIndex (msg: Lia.Event) {}

  storeToIndex (json: any) {}

  restoreFromIndex (uidDB: string, versionDB?: number) {}

  reset (uidDB: string, versionDB?: number) {
    this.initSettings(undefined, true)
  }

  getFromIndex (uidDB: string) {
    this.send({
      topic: 'restore',
      message: null,
      section: -1
    })
  }
}

import log from '../../liascript/log'

import * as Base from '../Base/index'

export class Connector {
  constructor() {}

  hasIndex() {
    return true
  }

  hideIndex() {
    return true
  }

  async initSettings(
    data: Promise<Lia.Settings> | Lia.Settings | null,
    local = false
  ) {
    try {
      data = await data
    } catch (e) {}

    return await this.postAwait('initSettings', { data, local })
  }

  setSettings(data: Lia.Settings) {
    this.post('setSettings', data)
  }

  async getSettings() {
    return await this.postAwait('getSettings', null)
  }

  async open(uidDB: string, versionDB: number, slide: number) {
    return await this.postAwait('open', { uidDB, versionDB, slide })
  }

  async load(record: Base.Record) {
    return await this.postAwait('load', record)
  }

  async store(record: Base.Record) {
    return await this.postAwait('store', record)
  }

  update(record: Base.Record, mapping: (project: any) => any) {
    this.post('update', record)
  }

  slide(id: number) {
    this.post('slide', id)
  }

  post(cmd: string, param: any) {
    window.parent.postMessage(
      JSON.stringify({
        cmd,
        param,
      }),
      '*'
    )
  }

  postAwait(cmd: string, param: any): Promise<any> {
    return new Promise((res, rej) => {
      const channel = new MessageChannel()

      channel.port1.onmessage = ({ data }) => {
        channel.port1.close()

        if (data.reject) {
          rej(data.reject)
        } else {
          res(JSON.parse(data.resolve))
        }
      }

      window.parent.postMessage(
        JSON.stringify({
          cmd,
          param,
        }),
        '*',
        [channel.port2]
      )
    })
  }

  /****************************************** */

  storage() {
    return null
  }

  getIndex() {}

  deleteFromIndex(_uidDB: string) {}

  storeToIndex(json: any) {
    this.post('storeToIndex', json)
  }

  async restoreFromIndex(uidDB: string, versionDB?: number) {
    return await this.postAwait('restoreFromIndex', { uidDB, versionDB })
  }

  reset(_uidDB?: string, _versionDB?: number) {
    this.initSettings(null, true)
  }

  async getFromIndex(uidDB: string) {
    return await this.postAwait('getFromIndex', { uidDB })
  }
}
import * as Base from '../Base/index'

export function postAwait(cmd: string, param: any, id: string): Promise<any> {
  return new Promise((res, rej) => {
    const channel = new MessageChannel()

    channel.port1.onmessage = ({ data }) => {
      channel.port1.close()

      if (data.reject) {
        rej(data.reject)
      } else {
        res(data.resolve === undefined ? null : JSON.parse(data.resolve))
      }
    }

    window.parent.postMessage(
      JSON.stringify({
        cmd,
        param,
        id,
      }),
      '*',
      [channel.port2]
    )
  })
}

export class Connector extends Base.Connector {
  private id: string
  constructor(id: string) {
    super()
    this.id = id
  }

  hasIndex() {
    return true
  }

  hideIndex() {
    return true
  }

  async initSettings(data: Lia.Settings | null, local = false) {
    return await this.postAwait('initSettings', { data, local })
  }

  postAwait(cmd: string, param: any) {
    return postAwait(cmd, param, this.id)
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

  store(record: Base.Record) {
    return this.post('store', record)
  }

  update(
    transaction: {
      cmd: string
      id: number
      data: any
    },
    record: Base.Record
  ) {
    this.post('update', { transaction, record })
  }

  slide(id: number) {
    this.post('slide', id)
  }

  post(cmd: string, param: any) {
    window.parent.postMessage(
      JSON.stringify({
        cmd,
        param,
        id: this.id,
      }),
      '*'
    )
  }

  /****************************************** */

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

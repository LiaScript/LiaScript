import { connect } from 'echarts'
import * as Browser from '../Browser/index'

export function resolve(event: MessageEvent<any>, json: any) {
  event.ports[0].postMessage({ resolve: JSON.stringify(json) })
}

export function reject(event: MessageEvent<any>, e: any) {
  event.ports[0].postMessage({ reject: e.message })
}

export class Connector {
  constructor(parentID: string) {
    const conn = new Browser.Connector()

    window.addEventListener(
      'message',
      async (event) => {
        try {
          const { cmd, param, id } = JSON.parse(event.data)

          if (parentID !== id) {
            return
          }

          switch (cmd) {
            case 'initSettings': {
              try {
                resolve(event, conn.initSettings(param.data, param.local))
              } catch (e) {
                reject(event, e)
              }

              break
            }

            case 'getSettings': {
              try {
                resolve(event, conn.getSettings())
              } catch (e) {
                reject(event, e)
              }

              break
            }

            case 'setSettings': {
              conn.setSettings(param)
              break
            }

            case 'open': {
              try {
                resolve(
                  event,
                  await conn.open(param.uidDB, param.versionDB, param.slide)
                )
              } catch (e) {
                reject(event, e)
              }

              break
            }

            case 'load': {
              try {
                resolve(event, await conn.load(param))
              } catch (e) {
                reject(event, e)
              }

              break
            }

            case 'update': {
              conn.update(param.transaction, param.record)
              break
            }

            case 'store': {
              conn.store(param)

              break
            }

            case 'slide': {
              try {
                conn.slide(param)
              } catch (e) {
                console.warn('Connector: IFrame, slide', e.message)
              }
              break
            }

            case 'storeToIndex': {
              try {
                conn.storeToIndex(param)
              } catch (e) {
                console.warn('Connector: IFrame, storeToIndex', e.message)
              }
              break
            }

            case 'getFromIndex': {
              try {
                resolve(event, (await conn.getFromIndex(param.uidDB)) || null)
              } catch (e) {
                reject(event, e)
              }
              break
            }

            case 'restoreFromIndex': {
              try {
                resolve(
                  event,
                  await conn.restoreFromIndex(param.uidDB, param.versionDB)
                )
              } catch (e) {
                reject(event, e)
              }
              break
            }

            default: {
              console.warn('Connector: IFrame, unknown command', cmd)
            }
          }
        } catch (e) {
          console.warn('Connector: ERROR', event.data.cmd, e.message)
        }
      },
      false
    )
  }
}

import * as Base from '../Base/index'
import { encode, decode } from 'uint8-to-base64'

export class Sync extends Base.Sync {
  private subject: string = 'liasync'
  private connected: boolean = false
  private listener?: (e: MessageEvent<any>) => void

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    super.connect(data)

    this.init(true)
  }

  destroy() {
    if (this.listener) window.removeEventListener('message', this.listener)
    super.destroy()
  }

  init(ok: boolean, error?: string) {
    if (ok) {
      this.subject = this.room || 'liasync'

      let self = this

      this.listener = function (e) {
        try {
          // Get the sent data
          let event = e.data

          switch (event.subject) {
            case 'init': {
              if (event.body) {
                self.connected = true
                self.sendConnect()
              }

              break
            }
            default: {
              if (event.body) {
                self.applyUpdate(decode(event.body))
              }
            }
          }
        } catch (error) {
          console.warn('Edrys', error.message)
        }
      }

      window.addEventListener('message', this.listener)

      this.broadcast(null, 'init')

      setTimeout(function () {
        if (!self.connected) {
          self.sendDisconnectError('This seems not to be an Edrys classroom')
        }
      }, 2000)
    }
  }

  broadcast(data: Uint8Array | null, topic?: string) {
    window.parent.postMessage(
      { subject: topic || this.subject, body: data ? encode(data) : null },
      '*'
    )
  }
}

import * as Base from '../Base/index'
import { encode, decode } from 'uint8-to-base64'

export class Sync extends Base.Sync {
  private subject: string = 'liasync'
  private connected: boolean = false

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
    // TODO: release event Handler
    super.destroy()
  }

  init(ok: boolean, error?: string) {
    if (ok) {
      this.subject = this.room || 'liasync'

      let self = this

      window.addEventListener('message', function (e) {
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
              event.body = JSON.parse(event.body)

              if (event.body.message.param.id !== self.token) {
                if (event.body) {
                  self.applyUpdate(decode(event.body))
                }
              }
            }
          }
        } catch (error) {
          console.warn('Edrys', error.message)
        }
      })

      window.parent.postMessage({ subject: 'init', body: '' }, '*')

      setTimeout(function () {
        if (!self.connected) {
          self.sendDisconnectError('This seems not to be an Edrys classroom')
        }
      }, 2000)
    }
  }

  broadcast(data: Uint8Array | null) {
    window.parent.postMessage(
      { subject: this.subject, body: data ? encode(data) : null },
      '*'
    )
  }
}

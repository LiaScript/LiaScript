import * as Base from '../Base/index'

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

  init(ok: boolean, error?: string) {
    if (ok) {
      this.subject = this.room

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
                self.sendToLia(event.body)
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
      }, 1234)
    }
  }

  disconnect(event: Object) {
    this.publish(null)
    this.publish(event)

    // todo release event-handler
  }

  publish(message: Object | null) {
    window.parent.postMessage({ subject: this.subject, body: message }, '*')
  }
}

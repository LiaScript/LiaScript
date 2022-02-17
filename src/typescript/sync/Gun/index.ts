import { Gun } from './gun.d'
import { Sync as Base } from '../Base/index'
import { Crypto } from '../Crypto'

export class Sync extends Base {
  private gun?: Gun
  private store: string = ''
  private gunServer: string[] = []

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    super.connect(data)
    this.gunServer = data.config

    if (window.Gun) {
      this.init(true)
    } else {
      this.load(
        [
          '//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/gun.min.js',
          //'//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/axe.min.js',
          //'//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/sea.min.js',
          Crypto.url,
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    if (this.gunServer.length == 0) {
      return this.sendDisconnectError(
        'You have to provide at least one relay server.'
      )
    }

    if (ok && window.Gun) {
      this.gun = window.Gun({ peers: this.gunServer })

      this.store = btoa(this.uniqueID())

      Crypto.init(this.password)

      let self = this
      this.gun
        .get(this.store)
        .on(function (data: { msg: string }, key: string) {
          try {
            let event = Crypto.decode(data.msg)

            if (event) {
              // prevent looping
              if (event.message.param.id !== self.token) {
                self.sendToLia(event)
              }
            }
          } catch (e) {
            console.warn('GunDB', e.message)
          }
        })

      this.publish(null)
      this.sendConnect()
    }
  }

  disconnect(event: Object) {
    this.publish(null)
    this.publish(event)

    delete this.gun
  }

  publish(message: Object | null) {
    if (this.gun) {
      this.gun.get(this.store).put({
        msg: Crypto.encode(message),
      })
    }
  }
}

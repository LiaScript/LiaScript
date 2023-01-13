import { Gun } from './gun.d'
import * as Base from '../Base/index'
import { Crypto } from '../Crypto'

export class Sync extends Base.Sync {
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
          'https://cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/gun.min.js',
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
            const [token, event] = Crypto.decode(data.msg)

            console.warn('SSSSSSSSSSSSSSS', event)

            if (token != self.token && event != null) {
              self.rxEvent(event)
            }
          } catch (e) {
            console.warn('GunDB', e.message)
          }
        })

      this.publish(null)
      this.sendConnect()
    }
  }

  disconnect(event: Lia.Event) {
    this.publish(null)
    this.publish(event)

    delete this.gun
  }

  publish(message: Lia.Event | null) {
    if (this.gun) {
      if (message != null) {
        message = this.txEvent(message)
      }

      console.warn('-----------------', message)

      this.gun.get(this.store).put({
        msg: Crypto.encode([this.token, message]),
      })
    }
  }
}

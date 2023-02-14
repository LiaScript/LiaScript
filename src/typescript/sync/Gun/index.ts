import { Gun } from './gun.d'
import * as Base from '../Base/index'
import { Crypto } from '../Crypto'

export class Sync extends Base.Sync {
  private gun?: Gun
  private store: string = ''
  private gunServer: string[] = []

  destroy() {
    this.gunServer = []
    delete this.gun

    super.destroy()
  }

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
          'https://cdn.jsdelivr.net/npm/gun/gun.js',
          //'https://cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/gun.min.js',
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

    const id = this.uniqueID()

    if (ok && window.Gun && id) {
      this.gun = window.Gun({ peers: this.gunServer })

      this.store = btoa(id)

      Crypto.init(this.password)

      let self = this
      this.gun
        .get(this.store)
        .on(function (data: { msg: string }, key: string) {
          try {
            const [token, message] = Crypto.decode(data.msg)

            if (token != self.token && message != null) {
              self.applyUpdate(Base.base64_to_unit8(message))
            }
          } catch (e) {
            console.warn('GunDB', e.message)
          }
        })

      this.broadcast(null)
      this.sendConnect()
    } else {
      console.warn('Could not load resource:', error)
    }
  }

  broadcast(data: null | Uint8Array): void {
    if (this.gun) {
      const message = data == null ? null : Base.uint8_to_base64(data)

      this.gun.get(this.store).put({
        msg: Crypto.encode([this.token, message]),
      })
    }
  }
}

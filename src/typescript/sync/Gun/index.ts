import { Gun } from './gun.d'
import * as Base from '../Base/index'
import { Crypto } from '../Crypto'

// Working solution to deal with GunDB i.map(...).flat is not a function
// https://stackoverflow.com/questions/50993498/flat-is-not-a-function-whats-wrong
Object.defineProperty(Array.prototype, 'flat', {
  value: function (depth = 1) {
    return this.reduce(function (flat, toFlatten) {
      return flat.concat(
        Array.isArray(toFlatten) && depth > 1
          ? toFlatten.flat(depth - 1)
          : toFlatten
      )
    }, [])
  },
})

export class Sync extends Base.Sync {
  private gun?: Gun
  private store: string = ''
  private gunServer: string[] = []
  private persistent: boolean = false

  destroy() {
    this.gunServer = []
    delete this.gun

    super.destroy()
  }

  uniqueID(): string | null {
    const id = super.uniqueID()

    if (id) {
      return btoa(id + (this.persistent ? 'p' : ''))
    }

    return null
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: { urls: string[]; persistent: boolean }
  }) {
    super.connect(data)
    this.gunServer = data.config?.urls || []
    this.persistent = data.config?.persistent || false

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

      this.store = id

      Crypto.init(this.password)

      let self = this
      if (this.persistent) {
        this.gun.get(this.store).once((data) => {
          if (data && data.msg) {
            try {
              const [_, message] = Crypto.decode(data.msg)

              setTimeout(function () {
                self.gun?.get(self.store).put({
                  msg: Crypto.encode(['', message]),
                })
              }, 1000)
            } catch (e) {
              console.warn('GunDB:', e.message)
            }
          }
        })
      }

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

      // store for realtime messages
      this.gun
        .get(this.store + 'pubsub')
        .on(function (data: { msg: string }, key: string) {
          try {
            const [token, message] = Crypto.decode(data.msg)

            if (token != self.token && message != null) {
              self.pubsubReceive(Base.base64_to_unit8(message))
            }
          } catch (e) {
            console.warn('GunDB', e.message)
          }
        })

      if (!this.persistent) {
        this.broadcast(true, null)
        this.broadcast(false, null)
      }

      this.sendConnect()
    } else {
      let message = 'GunDB unknown error'

      if (error) {
        message = 'Could not load resource: ' + error
      } else if (!window.Gun) {
        message = 'Could not load GunDB interface'
      }

      this.sendDisconnectError(message)
    }
  }

  broadcast(state: boolean, data: null | Uint8Array): void {
    if (this.gun) {
      const message = data == null ? null : Base.uint8_to_base64(data)

      this.gun
        .get(this.store + (state ? '' : 'pubsub'))
        .put({ msg: Crypto.encode(['', message]) })
    }
  }
}

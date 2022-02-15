import { Gun } from './gun.d'
import { Sync as Base } from '../Base/index'

function encode(msg: any): string {
  return cypher
    ? cypher.encrypt(btoa(encodeURIComponent(JSON.stringify(msg))))
    : JSON.stringify(msg)
}

function decode(msg: string): any {
  return cypher
    ? JSON.parse(decodeURIComponent(atob(cypher.decrypt(msg))))
    : JSON.parse(msg)
}

var cypher = null
export class Sync extends Base {
  private gun?: Gun
  private store: string = ''
  private gunServer: string = 'https://lia-gun.herokuapp.com/gun'

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    super.connect(data)

    if (window.Gun) {
      this.init(true)
    } else {
      this.load(
        [
          '//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/gun.min.js',
          //'//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/axe.min.js',
          //'//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/sea.min.js',
          '//cdn.jsdelivr.net/npm/simple-crypto-js@2.5.0/dist/SimpleCrypto.min.js',
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.Gun) {
      this.gun = window.Gun({ peers: [this.gunServer] })

      this.store = btoa(this.uniqueID())

      cypher = this.password ? new SimpleCrypto(this.password) : null

      let self = this
      this.gun
        .get(this.store)
        .on(function (data: { msg: string }, key: string) {
          try {
            let event = decode(data.msg)

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
        msg: encode(message),
      })
    }
  }
}

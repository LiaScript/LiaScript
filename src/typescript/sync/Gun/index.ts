import { Gun } from './gun.d'
import { Sync as Base } from '../Base/index'

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
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.Gun) {
      this.gun = window.Gun({ peers: [this.gunServer] })
      this.publish(null)

      this.store = btoa(this.uniqueID())

      let self = this

      this.gun
        .get(this.store)
        .on(function (data: { msg: string }, key: string) {
          try {
            let event = JSON.parse(data.msg)

            if (event !== null) {
              // prevent looping
              if (event.message.param.id !== self.token) {
                self.sendToLia(event)
              }
            }
          } catch (e) {
            console.warn('GunDB', e)
          }
        })

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
      this.gun.get(this.store).put({ msg: JSON.stringify(message) })
    }
  }
}

import Lia from '../../liascript/types/lia.d'

import { Gun } from './gun.d'

import { Sync as Base } from '../Base/index'

export class Sync extends Base {
  private gun?: Gun
  private store: string

  constructor(send: Lia.Send) {
    super(send)
    this.store = ''
  }

  async connect(data: {
    course: string
    room: string
    username: string
    password?: string
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
      this.gun = window.Gun({ peers: ['https://lia-gun.herokuapp.com/gun'] })
      this.publish(null)

      this.store = btoa(this.uniqueID())

      let self = this

      this.gun
        .get(this.store)
        .on(function (data: { msg: string }, key: string) {
          try {
            let message = JSON.parse(data.msg)

            if (message !== null) {
              if (message.id !== self.token) self.send(message)
            }
          } catch (e) {
            console.warn('GunDB', e)
          }
        })

      this.sync('connect', this.token)
    }
  }

  disconnect() {
    this.publish(this.syncMsg('leave', this.token))
    this.publish(null)

    this.sync('disconnect')

    delete this.gun
  }

  publish(message: Object | null) {
    if (this.gun) {
      this.gun.get(this.store).put({ msg: JSON.stringify(message) })
    }
  }
}

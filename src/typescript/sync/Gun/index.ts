import Lia from '../../liascript/types/lia.d'

import { Sync as Base } from '../Base/index'

export class Sync extends Base {
  private gun: any
  private db: any
  private store: string
  private user: any

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
          '//cdnjs.cloudflare.com/ajax/libs/gun/0.2020.1235/sea.min.js',
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.Gun) {
      this.gun = window.Gun(['//lia-gun.herokuapp.com/gun'])

      this.store = btoa(this.uniqueID())

      this.db = this.gun.get(this.store)

      this.user = this.db.user()

      let self = this

      this.db.on('auth', async (event: any) => {
        const alias = await self.user.get('alias')
        console.log('auth:', alias)
      })

      this.user.create(this.token, 'aölskfdjasfdiasfsa234')
      this.user.auth(this.token, 'aölskfdjasfdiasfsa234')

      this.db.map().on(async (data, id) => {
        if (data) {
          //const key = '#foo'

          //var message = {
          //  who: await self.db.user(data).get('alias'),
          //  what: (await SafeArray.decrypt(data.what, key)) + '',
          //  when: window.Gun.state.is(data, 'what'),
          //}

          console.log('SUB:', data)
        }
      })

      this.sync('connect', this.token)
    }
  }

  disconnect() {
    this.publish(this.syncMsg('leave', this.token))

    this.sync('disconnect')
  }

  async publish(message: Object) {
    if (this.db) {
      console.log('PUB: ', message.message)
      //const secret = await SEA.encrypt(message.message)

      this.db.get(this.store).put(JSON.stringify(message))
    }
  }
}

import Lia from '../../liascript/types/lia.d'

import * as Base from '../Base/index'

export class Sync extends Base.Sync {
  private client: any

  private login?: {
    user_id: string
    device_id: string
    access_token: string
    home_server: string
  }

  constructor(send: Lia.Send) {
    super(send)
  }

  async connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {
    super.connect(data)

    if (window.matrixcs) {
      this.init(true)
    } else {
      this.load(['vendor/browser-matrix.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.matrixcs) {
      this.client = window.matrixcs.createClient('https://matrix.org')

      let self = this

      this.client.registerGuest({ username: this.token }).then((login: any) => {
        self.login = login

        console.warn('checking', self)
      })
    }
  }
}

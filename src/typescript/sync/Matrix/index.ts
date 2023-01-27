//import { MatrixProvider } from "matrix-crdt";
import * as Base from '../Base/index'

export class Sync extends Base.Sync {
  private client: any

  private config: {
    user_id: string
    device_id: string
    access_token: string
    home_server: string
  }

  connect(data: {
    course: string
    room: string
    password?: string
    config: {
      baseURL: string
      userId: string
      accessToken: string
    }
  }) {
    super.connect(data)

    if (window['matrixcs']) {
      this.init(true)
    } else {
      this.load(
        [
          'https://cdn.jsdelivr.net/npm/matrix-js-sdk@23.1.1/lib/browser-index.min.js',
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window['matrixcs']) {
      this.client = window['matrixcs'].createClient('https://matrix.org')

      let self = this

      this.client.registerGuest({ username: this.token }).then((login: any) => {
        self.login = login

        console.warn('checking', self)
      })
    }
  }
}

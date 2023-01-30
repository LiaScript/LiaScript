import { MatrixProvider } from 'matrix-crdt'
import { MatrixClient } from 'matrix-js-sdk'
import * as Base from '../Base/index'

/**
 * Implemented according to:
 *
 * <https://github.com/yousefED/matrix-crdt>
 */

export class Sync extends Base.Sync {
  private client: MatrixClient
  private provider: any

  private config: {
    baseURL: string
    userId: string
    accessToken: string
  }

  constructor(
    cbConnection: (topic: string, msg: string) => void,
    cbRelay: (data: Lia.Event) => void
  ) {
    // do not use the default update-observer
    super(cbConnection, cbRelay, false)
  }

  destroy() {
    this.client
    super.destroy()
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
    this.config = data.config

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
    const id = this.uniqueID()

    if (ok && window['matrixcs'] && id) {
      try {
        this.client = window['matrixcs'].createClient(this.config)

        // Extra configuration needed for certain matrix-js-sdk
        // calls to work without calling sync start functions
        try {
          // @ts-ignore
          this.client.canSupportVoip = false
          // @ts-ignore
          this.client.clientOpts = {
            lazyLoadMembers: true,
          }
        } catch (e) {
          console.warn('Matrix set protected params failed:', e.message)
        }

        this.provider = new MatrixProvider(this.db.doc, this.client, {
          type: 'alias',
          alias: id,
        })
        this.provider.initialize()

        const self = this
        this.db.doc.on('update', (event: any, origin: string) => {
          if (origin === 'exit') {
            self.destroy()
          } else {
            self.update()
          }
        })
        this.sendConnect()
      } catch (e) {
        this.sendDisconnectError('Could not connect to Matrix: ' + e.message)
      }
    } else {
      this.sendDisconnectError('Could not load Matrix browser lib. ' + error)
    }
  }

  // Avoid annoying warnings
  broadcast(data: Uint8Array): void {}
}

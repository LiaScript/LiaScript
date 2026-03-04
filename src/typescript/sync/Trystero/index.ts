import * as Base from '../Base/index'
import { TrysteroTransport } from '../../../../node_modules/y-generic/dist/providers/trystero/index'
import { GenericProvider } from 'y-generic'

type Backend = 'nostr' | 'mqtt' | 'torrent' | 'ipfs'

const joinRoomFns: Record<Backend, any> = {
  nostr: null,
  mqtt: null,
  torrent: null,
  ipfs: null,
}

export class Sync extends Base.Sync {
  private transport?: TrysteroTransport
  private backend: Backend
  private syncFallbackTimer: ReturnType<typeof setTimeout> | null = null

  constructor(
    backend: Backend,
    cbConnection: (topic: string, msg: string) => void,
    cbRelay: (data: Lia.Event) => void,
    onConnect: () => void,
    onReceive: (topic: string, message: any) => void,
    replyOnReceive: boolean = false,
    useInternalCallback: boolean = true,
  ) {
    super(
      cbConnection,
      cbRelay,
      onConnect,
      onReceive,
      replyOnReceive,
      useInternalCallback,
    )
    this.backend = backend
  }

  destroy() {
    if (this.syncFallbackTimer !== null) {
      clearTimeout(this.syncFallbackTimer)
      this.syncFallbackTimer = null
    }
    super.destroy()
    this.provider?.disconnect()
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: string[]
  }) {
    super.connect(data)

    if (joinRoomFns[this.backend]) {
      this.init(true)
      return
    }

    const load = (module: Promise<any>) => {
      module
        .then((e) => {
          joinRoomFns[this.backend] = e.joinRoom
          this.init(true)
        })
        .catch((e) => this.init(false, e.message))
    }

    switch (this.backend) {
      case 'nostr':
        load(import('./trystero-nostr.min.js'))
        break
      case 'mqtt':
        load(import('./trystero-mqtt.min.js'))
        break
      case 'torrent':
        load(import('./trystero-torrent.min.js'))
        break
      case 'ipfs':
        load(import('./trystero-ipfs.min.js'))
        break
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID()

    if (ok && id) {
      const stun = JSON.parse(process.env.STUN_SERVER || 'null')

      this.transport = new TrysteroTransport({
        joinRoom: joinRoomFns[this.backend],
        appId: 'liascript',
        password: this.password,
        ...(stun ? { rtcConfig: stun } : {}),
      })

      this.provider = new GenericProvider(this.db.doc, this.transport)

      // Wire awareness for ephemeral peer presence and cursors.
      this.db.setAwareness(this.provider.awareness)

      // Same two-path connect as Gun:
      //  A) First peer: 'synced' never fires (no remote to exchange SyncStep2).
      //     Fallback timer fires after 2 s.
      //  B) Joining peer: 'synced' fires as soon as state-vector diff arrives.
      let syncedOnce = false

      const doConnect = () => {
        if (syncedOnce) return
        syncedOnce = true
        if (this.syncFallbackTimer !== null) {
          clearTimeout(this.syncFallbackTimer)
          this.syncFallbackTimer = null
        }
        this.sendConnect()
      }

      this.provider.on('synced', (event: any) => {
        console.log('Trystero: document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`Trystero status: ${status}`)

        if (status === 'connected') {
          this.syncFallbackTimer = setTimeout(() => {
            console.log('Trystero: sync fallback, proceeding as first peer')
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('Trystero: disconnected')
        }
      })

      this.provider.connect({ room: id })
    } else {
      let message = this.backend + ' unknown error'
      if (error) message = 'Could not load resource: ' + error
      this.sendDisconnectError(message)
    }
  }

  broadcast(_state: boolean, _data: null | Uint8Array): void {
    // GenericProvider handles all sync automatically via the transport.
    // This override intentionally left empty.
  }
}

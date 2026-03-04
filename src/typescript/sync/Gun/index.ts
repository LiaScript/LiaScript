import * as Base from '../Base/index'
import { GunTransport } from '../../../../node_modules/y-generic/dist/providers/gun/index'
import { GenericProvider } from 'y-generic'

// Working solution to deal with GunDB i.map(...).flat is not a function
// https://stackoverflow.com/questions/50993498/flat-is-not-a-function-whats-wrong
Object.defineProperty(Array.prototype, 'flat', {
  value: function (depth = 1) {
    return (this as Array<any>).reduce(function (
      flat: any[],
      toFlatten: any,
    ): any[] {
      return flat.concat(
        Array.isArray(toFlatten) && depth > 1
          ? toFlatten.flat(depth - 1)
          : toFlatten,
      )
    }, [])
  },
})

export class Sync extends Base.Sync {
  private transport?: GunTransport
  private store: string = ''
  private gunServer: string[] = []
  private persistent: boolean = false
  private syncFallbackTimer: ReturnType<typeof setTimeout> | null = null

  destroy() {
    if (this.syncFallbackTimer !== null) {
      clearTimeout(this.syncFallbackTimer)
      this.syncFallbackTimer = null
    }
    super.destroy()
    this.gunServer = []
    this.provider?.disconnect()
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
      this.load(['https://cdn.jsdelivr.net/npm/gun/gun.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (this.gunServer.length == 0) {
      return this.sendDisconnectError(
        'You have to provide at least one relay server.',
      )
    }

    const id = this.uniqueID()

    if (ok && window.Gun && id) {
      this.transport = new GunTransport({
        gun: window.Gun,
        peers: this.gunServer,
        debug: false,
        batchInterval: 200,
        gunOptions: {
          localStorage: false,
          radisk: false,
        },
      })
      this.store = id

      this.provider = new GenericProvider(this.db.doc, this.transport)

      // Hand awareness to the CRDT so peer presence and cursors are
      // handled ephemerally instead of via persistent Y.Map entries.
      this.db.setAwareness(this.provider.awareness)

      // sendConnect() must only be called once, after the Yjs state-vector
      // exchange is complete so that db.init() (triggered by LiaScript's
      // 'join' response) reads a fully populated CRDT.
      //
      // Two cases:
      //  A) First peer in an empty room: 'synced' is never emitted because
      //     there is no remote peer to send SyncStep2. The fallback timer
      //     fires after 2 s and proceeds immediately (nothing to sync anyway).
      //  B) Joining peer: 'synced' fires as soon as the full state-vector
      //     diff arrives from an existing peer — well before the timer.
      //
      // The syncedOnce flag ensures only one path fires sendConnect().
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
        console.log('Document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`Status changed: ${status}`, 'info')

        if (status === 'connected') {
          // Start the fallback timer for the first-peer case.
          // Cleared immediately if 'synced' fires first.
          this.syncFallbackTimer = setTimeout(() => {
            console.log(
              'Sync fallback: no remote peers, proceeding as first peer',
            )
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('Disconnected from GunDB relay server')
        } else {
          console.warn(`GunDB status: ${status}`)
        }
      })

      this.provider.connect({ room: this.store })
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
}

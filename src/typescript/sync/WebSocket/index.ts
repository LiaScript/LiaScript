import * as Base from '../Base/index'
import { WebSocketTransport } from '../../../../node_modules/y-generic/dist/providers/websocket/index'
import { GenericProvider } from 'y-generic'
import { wrapTransport } from '../Base/security'
import { Crypto } from '../Crypto'

export class Sync extends Base.Sync {
  private transport?: WebSocketTransport
  private serverUrl?: string
  private syncFallbackTimer: ReturnType<typeof setTimeout> | null = null

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
    config?: { url: string }
    name: string
    mode: number
  }) {
    super.connect(data)

    console.warn(
      'WebSocket sync is experimental. Please report any issues you encounter.',
      data.config,
    )

    this.serverUrl = data.config?.url || process.env.WEBSOCKET_SERVER

    if (!this.serverUrl) {
      return this.sendDisconnectError(
        'You have to provide a WebSocket server URL.',
      )
    }

    if (this.password && !window['SimpleCrypto']) {
      this.load([Crypto.url], this)
    } else {
      this.init(true)
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID(this.password)

    if (ok && id) {
      if (this.password) Crypto.init(this.password)

      this.transport = new WebSocketTransport()

      this.provider = new GenericProvider(
        this.db.doc,
        // WebSocketTransport strips/re-adds GenericProvider's 4-byte CRC32
        // header internally (wire-compat with plain y-websocket) - tell the
        // wrapper so it doesn't corrupt our ciphertext, see security.ts.
        wrapTransport(this.transport, this.password, 4),
        {
          verifyUpdates: false,
        },
      )

      this.db.setAwareness(this.provider.awareness, this.name)

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
        console.log('WebSocket: document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`WebSocket status: ${status}`)

        if (status === 'connected') {
          this.syncFallbackTimer = setTimeout(() => {
            console.log('WebSocket: sync fallback, proceeding as first peer')
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('WebSocket: disconnected')
        }
      })

      this.provider.pubsub.subscribe('*', (message: any, topic: string) => {
        this.onReceive?.(topic, message)
      })

      this.provider.connect({
        serverUrl: this.serverUrl!,
        room: id,
      }).catch((e: any) => {
        console.warn('WebSocket: initial connect failed ->', e?.message || e)
      })
    } else {
      let message = 'WebSocket unknown error'
      if (error) message = 'Could not connect: ' + error
      this.sendDisconnectError(message)
    }
  }

  pubsubSend(topic: string, message: any): void {
    if (this.provider) {
      this.provider.pubsub.publish(topic, message)
      if (this.replyOnReceive) {
        this.onReceive?.(topic, message)
      }
    }
  }
}

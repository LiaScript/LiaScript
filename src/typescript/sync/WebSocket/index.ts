import * as Base from '../Base/index'
import { WebSocketTransport } from '../../../../node_modules/y-generic/dist/providers/websocket/index'
import { GenericProvider } from 'y-generic'

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
  }) {
    super.connect(data)

    console.warn(
      'WebSocket sync is experimental. Please report any issues you encounter.',
      data.config,
    )

    this.serverUrl = data.config?.url

    if (!this.serverUrl) {
      return this.sendDisconnectError(
        'You have to provide a WebSocket server URL.',
      )
    }

    this.init(true)
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID(this.password)

    if (ok && id) {
      this.transport = new WebSocketTransport()

      this.provider = new GenericProvider(this.db.doc, this.transport, {
        verifyUpdates: false,
      })

      this.db.setAwareness(this.provider.awareness)

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

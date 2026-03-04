import * as Base from '../Base/index'
import { SimplePeerTransport } from '../../../../node_modules/y-generic/dist/providers/simple-peer/index'
import { GenericProvider } from 'y-generic'

export class Sync extends Base.Sync {
  private transport?: SimplePeerTransport
  private signaling?: string[]
  private iceServers?: any[]
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
    config?: { signaling?: string; iceServers?: string }
  }) {
    super.connect(data)

    this.signaling = data.config?.signaling
      ? data.config.signaling
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean)
      : undefined

    if (!this.signaling || this.signaling.length === 0) {
      return this.sendDisconnectError(
        'You have to provide at least one signaling server URL (e.g. wss://your-signaling-server.example.com). See https://github.com/yjs/y-webrtc for setup instructions.',
      )
    }

    if (data.config?.iceServers) {
      try {
        this.iceServers = JSON.parse(data.config.iceServers)
      } catch {
        console.warn(
          'SimplePeer: invalid iceServers JSON, ignoring:',
          data.config.iceServers,
        )
      }
    }

    if (window['SimplePeer']) {
      this.init(true)
    } else {
      this.load(['//unpkg.com/simple-peer@9.11.1/simplepeer.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    const raw = this.uniqueID()

    if (ok && window['SimplePeer'] && raw) {
      hashID(raw).then((id) => {
        const stun =
          this.iceServers ?? JSON.parse(process.env.STUN_SERVER || 'null')

        this.transport = new SimplePeerTransport({
          peer: window['SimplePeer'],
          ...(this.signaling ? { signaling: this.signaling } : {}),
          ...(stun ? { iceServers: stun } : {}),
          ...(this.password ? { password: this.password } : {}),
        })

        this.provider = new GenericProvider(this.db.doc, this.transport)

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
          console.log('SimplePeer: document synchronized', event.synced)
          doConnect()
        })

        this.provider.on('status', (event: any) => {
          const status = event.state
          console.log(`SimplePeer status: ${status}`)

          if (status === 'connected') {
            this.syncFallbackTimer = setTimeout(() => {
              console.log('SimplePeer: sync fallback, proceeding as first peer')
              doConnect()
            }, 2000)
          } else if (status === 'disconnected') {
            console.warn('SimplePeer: disconnected')
          }
        })

        this.provider.connect({
          room: id,
          ...(this.password ? { password: this.password } : {}),
        } as any)
      })
    } else {
      let message = 'SimplePeer unknown error'
      if (error) message = 'Could not load resource: ' + error
      else if (!window['SimplePeer'])
        message = 'Could not load SimplePeer library'
      this.sendDisconnectError(message)
    }
  }
}

async function hashID(id: string): Promise<string> {
  const encoded = new TextEncoder().encode(id)
  const buf = await crypto.subtle.digest('SHA-256', encoded)
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

import * as Base from '../Base/index'
import { PeerJSTransport } from '../../../../node_modules/y-generic/dist/providers/peerjs/index'
import { GenericProvider } from 'y-generic'
import { wrapTransport } from '../Base/security'
import { Crypto } from '../Crypto'

export class Sync extends Base.Sync {
  private transport?: PeerJSTransport
  private host?: string
  private port?: number
  private peerPath?: string
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
    name: string
    mode: number
    config?: {
      host?: string
      port?: string
      path?: string
      iceServers?: string
    }
  }) {
    super.connect(data)

    this.host = data.config?.host || undefined
    this.port = data.config?.port ? parseInt(data.config.port, 10) : undefined
    this.peerPath = data.config?.path || undefined

    const iceServersRaw = data.config?.iceServers || process.env.WEBRTC_ICE_SERVERS
    if (iceServersRaw) {
      try {
        this.iceServers = JSON.parse(iceServersRaw)
      } catch {
        console.warn('PeerJS: invalid iceServers JSON, ignoring:', iceServersRaw)
      }
    }

    const urls: string[] = []
    if (!window['Peer']) urls.push('//unpkg.com/peerjs@1.5.4/dist/peerjs.min.js')
    if (this.password && !window['SimpleCrypto']) urls.push(Crypto.url)

    if (urls.length === 0) {
      this.init(true)
    } else {
      this.load(urls, this)
    }
  }

  init(ok: boolean, error?: string) {
    const raw = this.uniqueID()

    if (ok && window['Peer'] && raw) {
      if (this.password) Crypto.init(this.password)

      hashID(raw).then((id) => {
        const peerOptions: Record<string, any> = {}
        if (this.host) {
          peerOptions.host = this.host
          peerOptions.secure = true
        }
        if (this.port !== undefined) peerOptions.port = this.port
        if (this.peerPath) peerOptions.path = this.peerPath
        if (this.iceServers)
          peerOptions.config = { iceServers: this.iceServers }

        this.transport = new PeerJSTransport({
          peer: window['Peer'],
          ...(Object.keys(peerOptions).length > 0 ? { peerOptions } : {}),
        })

        this.provider = new GenericProvider(
          this.db.doc,
          wrapTransport(this.transport, this.password),
        )

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
          console.log('PeerJS: document synchronized', event.synced)
          doConnect()
        })

        this.provider.on('status', (event: any) => {
          const status = event.state
          console.log(`PeerJS status: ${status}`)

          if (status === 'connected') {
            this.syncFallbackTimer = setTimeout(() => {
              console.log('PeerJS: sync fallback, proceeding as first peer')
              doConnect()
            }, 2000)
          } else if (status === 'disconnected') {
            console.warn('PeerJS: disconnected')
          }
        })

        this.provider.pubsub.subscribe('*', (message: any, topic: string) => {
          this.onReceive?.(topic, message)
        })

        this.provider.connect({
          room: id,
          ...(this.password ? { password: this.password } : {}),
        } as any).then(() => {
          // Wire awareness only once the transport is actually connected, so
          // the initial local-state broadcast isn't dropped by a transport
          // that silently no-ops send() while unconnected.
          this.db.setAwareness(this.provider.awareness, this.name)
        })
      })
    } else {
      let message = 'PeerJS unknown error'
      if (error) message = 'Could not load resource: ' + error
      else if (!window['Peer']) message = 'Could not load PeerJS library'
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

async function hashID(id: string): Promise<string> {
  const encoded = new TextEncoder().encode(id)
  const buf = await crypto.subtle.digest('SHA-256', encoded)
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

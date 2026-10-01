import * as Base from '../Base/index'
import { SimplePeerTransport } from '../../../../node_modules/y-generic/dist/providers/simple-peer/index'
import { ConferenceTransport } from '../../../../node_modules/y-generic/dist/providers/conference/index'
import { GenericProvider } from 'y-generic'
import { wrapTransport } from '../Base/security'
import { Crypto } from '../Crypto'

export class Sync extends Base.Sync {
  private transport?: SimplePeerTransport
  private signaling?: string[]
  private iceServers?: any[]
  private conference: boolean = false
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
    config?: { signaling?: string; iceServers?: string; conference?: boolean }
    name: string
    mode: number
  }) {
    super.connect(data)

    this.conference = data.config?.conference || false

    this.signaling = data.config?.signaling
      ?.split(',')
      .map((s) => s.trim())
      .filter(Boolean)

    if (!this.signaling?.length) {
      this.signaling = process.env.WEBRTC_SIGNALING_SERVERS
        ? JSON.parse(process.env.WEBRTC_SIGNALING_SERVERS)
        : undefined
    }

    if (!this.signaling || this.signaling.length === 0) {
      return this.sendDisconnectError(
        'You have to provide at least one signaling server URL (e.g. wss://your-signaling-server.example.com). See https://github.com/yjs/y-webrtc for setup instructions.',
      )
    }

    const iceServersRaw = data.config?.iceServers || process.env.WEBRTC_ICE_SERVERS
    if (iceServersRaw) {
      try {
        this.iceServers = JSON.parse(iceServersRaw)
      } catch {
        console.warn('SimplePeer: invalid iceServers JSON, ignoring:', iceServersRaw)
      }
    }

    const urls: string[] = []
    if (!window['SimplePeer'])
      urls.push('//unpkg.com/simple-peer@9.11.1/simplepeer.min.js')
    if (this.password && !window['SimpleCrypto']) urls.push(Crypto.url)

    if (urls.length === 0) {
      this.init(true)
    } else {
      this.load(urls, this)
    }
  }

  init(ok: boolean, error?: string) {
    const raw = this.uniqueID()

    if (ok && window['SimplePeer'] && raw) {
      if (this.password) Crypto.init(this.password)

      // A conference room speaks another wire format: keep it on a topic of
      // its own, so a peer that joins without the flag cannot break it.
      hashID(this.conference ? raw + '|conference' : raw).then((id) => {
        const stun =
          this.iceServers ?? JSON.parse(process.env.STUN_SERVER || 'null')

        this.transport = new SimplePeerTransport({
          peer: window['SimplePeer'],
          ...(this.signaling ? { signaling: this.signaling } : {}),
          ...(stun ? { iceServers: stun } : {}),
        })

        // Conference mode: a partial mesh (ln(N) links per peer) relayed as
        // if it were a full one, for rooms that would not fit into N-1
        // RTCPeerConnections per browser. Changes the wire format - every
        // peer of the room has to use it, which the room URL takes care of.
        const transport = this.conference
          ? new ConferenceTransport(this.transport, {
              expectedPeers: CONFERENCE_EXPECTED_PEERS,
            })
          : this.transport

        this.provider = new GenericProvider(
          this.db.doc,
          wrapTransport(transport, this.password),
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

        this.provider.pubsub.subscribe('*', (message: any, topic: string) => {
          this.onReceive?.(topic, message)
        })

        this.provider.connect({
          room: id,
          waitFor: this.persistReady,
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
  pubsubSend(topic: string, message: any): void {
    if (this.provider) {
      this.provider.pubsub.publish(topic, message)
      if (this.replyOnReceive) {
        this.onReceive?.(topic, message)
      }
    }
  }
}

/** Only a hint for the dial rule: too large costs a small room a second hop,
 * too small costs a large room links - neither breaks it. */
const CONFERENCE_EXPECTED_PEERS = 100

async function hashID(id: string): Promise<string> {
  const encoded = new TextEncoder().encode(id)
  const buf = await crypto.subtle.digest('SHA-256', encoded)
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

import * as Base from '../Base/index'
import { NostrTransport } from '../../../../node_modules/y-generic/dist/providers/nostr/index'
import { GenericProvider } from 'y-generic'
import { wrapTransport } from '../Base/security'
import { Crypto } from '../Crypto'

// UMD build of nostr-tools, loaded lazily like every other backend's SDK
// (Ably, GunDB, ...) rather than bundled as an npm dependency. Exposes a
// single global `NostrTools` with `.SimplePool`, `.finalizeEvent`,
// `.getPublicKey`.
const NOSTR_TOOLS_URL =
  'https://cdn.jsdelivr.net/npm/nostr-tools@2/lib/nostr.bundle.js'

export class Sync extends Base.Sync {
  private transport?: NostrTransport
  private relayUrls?: string[]
  private persistent: boolean = false
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
    config?: { relayUrls?: string[]; persistent?: boolean }
    name: string
    mode: number
  }) {
    super.connect(data)

    this.relayUrls = data.config?.relayUrls?.length
      ? data.config.relayUrls
      : undefined
    this.persistent = data.config?.persistent || false

    const urls: string[] = []
    if (!window['NostrTools']) urls.push(NOSTR_TOOLS_URL)
    if (this.password && !window['SimpleCrypto']) urls.push(Crypto.url)

    if (urls.length === 0) {
      this.init(true)
    } else {
      this.load(urls, this)
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID()

    if (ok && window['NostrTools'] && id) {
      if (this.password) Crypto.init(this.password)

      const NostrTools = window['NostrTools']

      this.transport = new NostrTransport({
        finalizeEvent: NostrTools.finalizeEvent,
        getPublicKey: NostrTools.getPublicKey,
        SimplePool: NostrTools.SimplePool,
      })

      this.provider = new GenericProvider(
        this.db.doc,
        // NostrTransport passes GenericProvider's frames through unchanged
        // (no header translation), same as PeerJS/SimplePeer - see
        // security.ts's stripHeaderBytes doc comment.
        wrapTransport(this.transport, this.password),
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
        console.log('Nostr: document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`Nostr status: ${status}`)

        if (status === 'connected') {
          this.syncFallbackTimer = setTimeout(() => {
            console.log('Nostr: sync fallback, proceeding as first peer')
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('Nostr: disconnected')
        }
      })

      this.provider.pubsub.subscribe('*', (message: any, topic: string) => {
        this.onReceive?.(topic, message)
      })

      this.provider.connect({
        room: id,
        relays: this.relayUrls,
        persistent: this.persistent,
        doc: this.persistent ? this.db.doc : undefined,
        waitFor: this.persistReady,
        ...(this.password ? { password: this.password } : {}),
      } as any)
    } else {
      let message = 'Nostr unknown error'
      if (error) message = 'Could not load resource: ' + error
      else if (!window['NostrTools']) message = 'Could not load nostr-tools'
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

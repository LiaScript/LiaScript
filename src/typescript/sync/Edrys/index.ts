import * as Base from '../Base/index'
import type {
  Transport,
  ConnectionConfig,
} from '../../../../node_modules/y-generic/dist/transport'
import { GenericProvider } from 'y-generic'
import { encode, decode } from 'uint8-to-base64'
import { wrapTransport } from '../Base/security'
import { Crypto } from '../Crypto'

/** How long to wait for the embedding Edrys module to answer the handshake. */
const HANDSHAKE_TIMEOUT_MS = 2000

/** Edrys has no network of its own for LiaScript: the course runs inside
 * edrys-labs/module-liascript, which relays every message posted to it to the
 * other users of the Edrys room (Edrys.sendMessage) and posts theirs back.
 *
 * Wire format, shared with the module:
 *
 * - `{subject: 'init', body: null}` -> module answers `{subject: 'init', body: true}`
 * - `{subject: <room>, body: <base64 frame>}` in both directions
 *
 * Edrys already delivers messages to the users of one room only; the subject
 * keeps classrooms of different courses within that room apart.
 */
class EdrysTransport implements Transport {
  private subject = ''
  private connected = false
  private callbacks = new Set<(data: Uint8Array) => void>()
  private listener?: (e: MessageEvent) => void

  get isConnected() {
    return this.connected
  }

  connect(config: ConnectionConfig): Promise<void> {
    this.disconnect()
    this.subject = config.room

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error('This seems not to be an Edrys classroom'))
      }, HANDSHAKE_TIMEOUT_MS)

      this.listener = (e: MessageEvent) => {
        // only the embedding module speaks this protocol
        if (e.source !== window.parent) return

        const { subject, body } = e.data || {}

        if (subject === 'init') {
          if (body && !this.connected) {
            this.connected = true
            clearTimeout(timeout)
            resolve()
          }
        } else if (subject === this.subject && typeof body === 'string') {
          let data: Uint8Array
          try {
            data = decode(body)
          } catch (error) {
            console.warn('Edrys: dropping undecodable frame', error)
            return
          }
          this.callbacks.forEach((callback) => callback(data))
        }
      }

      window.addEventListener('message', this.listener)
      this.post('init', null)
    })
  }

  disconnect() {
    if (this.listener) window.removeEventListener('message', this.listener)
    this.listener = undefined
    this.connected = false
  }

  send(data: Uint8Array) {
    if (this.connected) this.post(this.subject, encode(data))
  }

  onMessage(callback: (data: Uint8Array) => void) {
    this.callbacks.add(callback)
    return () => {
      this.callbacks.delete(callback)
    }
  }

  private post(subject: string, body: string | null) {
    // the module's origin is not known (and may be inlined as data:); the
    // module checks that messages come from this frame
    window.parent.postMessage({ subject, body }, '*')
  }
}

export class Sync extends Base.Sync {
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
    config?: any
    name: string
    mode: number
  }) {
    super.connect(data)

    if (this.password && !window['SimpleCrypto']) {
      this.load([Crypto.url], this)
    } else {
      this.init(true)
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID()

    if (!ok || !id) {
      return this.sendDisconnectError(
        error ? 'Could not load resource: ' + error : 'Edrys unknown error',
      )
    }

    if (this.password) Crypto.init(this.password)

    this.provider = new GenericProvider(
      this.db.doc,
      wrapTransport(new EdrysTransport(), this.password),
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
      console.log('Edrys: document synchronized', event.synced)
      doConnect()
    })

    this.provider.on('status', (event: any) => {
      const status = event.state

      if (status === 'connected') {
        // nobody else in the room answered: proceed as the first peer
        this.syncFallbackTimer = setTimeout(doConnect, 2000)
      } else if (status === 'disconnected') {
        console.warn('Edrys: disconnected')
      }
    })

    this.provider.pubsub.subscribe('*', (message: any, topic: string) => {
      this.onReceive?.(topic, message)
    })

    this.provider
      .connect({ room: id, waitFor: this.persistReady } as any)
      .catch((e: any) => {
        this.sendDisconnectError(
          e?.message || 'This seems not to be an Edrys classroom',
        )
      })
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

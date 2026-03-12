import * as Base from '../Base/index'
import { PubNubTransport } from '../../../../node_modules/y-generic/dist/providers/pubnub/index'
import { GenericProvider } from 'y-generic'

export class Sync extends Base.Sync {
  private transport?: PubNubTransport
  private publishKey?: string
  private subscribeKey?: string
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
  }) {
    super.connect(data)

    this.publishKey = data.config?.publishKey
    this.subscribeKey = data.config?.subscribeKey

    if (window['PubNub']) {
      this.init(true)
    } else {
      this.load(['//cdn.pubnub.com/sdk/javascript/pubnub.10.2.7.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (!this.publishKey || !this.subscribeKey) {
      return this.sendDisconnectError(
        'You have to provide a valid pair of keys',
      )
    }

    const id = this.uniqueID()

    if (ok && window['PubNub'] && id) {
      this.transport = new PubNubTransport()

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
        console.log('PubNub: document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`PubNub status: ${status}`)

        if (status === 'connected') {
          this.syncFallbackTimer = setTimeout(() => {
            console.log('PubNub: sync fallback, proceeding as first peer')
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('PubNub: disconnected')
        }
      })

      this.provider.connect({
        room: id,
        publishKey: this.publishKey,
        subscribeKey: this.subscribeKey,
        ...(this.password ? { cipherKey: this.password } : {}),
      } as any)
    } else {
      let message = 'PubNub unknown error'
      if (error) message = 'Could not load resource: ' + error
      else if (!window['PubNub']) message = 'Could not load PubNub SDK'
      this.sendDisconnectError(message)
    }
  }
}

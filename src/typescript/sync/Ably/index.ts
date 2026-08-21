import * as Base from '../Base/index'
import { AblyTransport } from '../../../../node_modules/y-generic/dist/providers/ably/index'
import { GenericProvider } from 'y-generic'

export class Sync extends Base.Sync {
  private transport?: AblyTransport
  private apiKey?: string
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
    config?: any
    name: string
    mode: number
  }) {
    super.connect(data)

    this.apiKey = data.config?.apiKey || process.env.ABLY_API_KEY || undefined
    this.persistent = data.config?.persistent || false

    const urls: string[] = []
    if (!window['Ably']) urls.push('https://cdn.ably.com/lib/ably.min-2.js')
    if (this.persistent && !window['AblyLiveObjectsPlugin'])
      urls.push('https://cdn.ably.com/lib/liveobjects.umd.min-2.js')

    if (urls.length === 0) {
      this.init(true)
    } else {
      this.load(urls, this)
    }
  }

  init(ok: boolean, error?: string) {
    if (!this.apiKey) {
      return this.sendDisconnectError('You have to provide a valid API key')
    }

    const id = this.uniqueID()

    if (ok && window['Ably'] && id) {
      this.transport = new AblyTransport({
        Realtime: window['Ably'].Realtime,
        LiveObjects: this.persistent
          ? window['AblyLiveObjectsPlugin']
          : undefined,
      })

      this.provider = new GenericProvider(this.db.doc, this.transport)

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
        console.log('Ably: document synchronized', event.synced)
        doConnect()
      })

      this.provider.on('status', (event: any) => {
        const status = event.state
        console.log(`Ably status: ${status}`)

        if (status === 'connected') {
          this.syncFallbackTimer = setTimeout(() => {
            console.log('Ably: sync fallback, proceeding as first peer')
            doConnect()
          }, 2000)
        } else if (status === 'disconnected') {
          console.warn('Ably: disconnected')
        }
      })

      this.provider.connect({
        room: id,
        apiKey: this.apiKey,
        persistent: this.persistent,
        doc: this.persistent ? this.db.doc : undefined,
        ...(this.password ? { password: this.password } : {}),
      } as any)
    } else {
      let message = 'Ably unknown error'
      if (error) message = 'Could not load resource: ' + error
      else if (!window['Ably']) message = 'Could not load Ably SDK'
      this.sendDisconnectError(message)
    }
  }
}

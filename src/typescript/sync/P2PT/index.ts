import * as Base from '../Base/index'
import { Crypto } from '../Crypto'

// https://github.com/ngosang/trackerslist/blob/master/trackers_all_ws.txt

export class Sync extends Base.Sync {
  private p2pt?: any
  private trackersAnnounceURLs: string[] = []

  private peers: { [id: string]: string } = {}
  private tokens: { [id: string]: string } = {}

  destroy() {
    this.trackersAnnounceURLs = []
    this.p2pt?.destroy()

    super.destroy()
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: string[]
  }) {
    super.connect(data)
    this.trackersAnnounceURLs = data.config || []

    if (window['P2PT']) {
      this.init(true)
    } else {
      window['P2PT'] = await import('p2pt')
      this.load([Crypto.url], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (this.trackersAnnounceURLs.length == 0) {
      return this.sendDisconnectError(
        'You have to provide at least one WebTorrent tracker.'
      )
    }

    const id = this.uniqueID()

    if (ok && window['P2PT'] && id) {
      this.p2pt = new window['P2PT'](this.trackersAnnounceURLs, id)

      Crypto.init(this.password)

      const self = this

      this.p2pt.on('trackerconnect', (tracker, stats) => {
        console.log('Connected to tracker : ' + tracker.announceUrl)
        console.log('Tracker stats : ' + JSON.stringify(stats))

        self.sendConnect()
      })

      this.p2pt.on('trackerwarning', (error, stats) => {
        console.log('Connected to tracker : ', error)
        console.log('Tracker stats : ' + JSON.stringify(stats))
      })

      this.p2pt.on('peerconnect', (peer) => {
        console.warn('Peer connected : ' + peer.id, peer)
        self.peers[peer.id] = peer
      })

      this.p2pt.on('peerclose', (peer) => {
        console.warn('Peer disconnected : ' + peer)
        const token = self.tokens[peer.id]
        if (token) {
          self.db.removePeer(token)
          delete self.tokens[peer.id]
        }
        delete self.peers[peer.id]
      })

      this.p2pt.on('msg', (peer, msg) => {
        console.warn(`Got message from ${peer.id} : ${msg}`)

        if (msg) {
          try {
            const [token, state, message] = Crypto.decode(msg)

            if (token != self.token && message != null) {
              if (state) {
                self.applyUpdate(Base.base64_to_unit8(message))
              } else {
                self.pubsubReceive(Base.base64_to_unit8(message))
              }

              if (!self.tokens[peer.id]) {
                self.tokens[peer.id] = token
              }
            }
          } catch (e) {
            console.warn('P2PT', e.message)
          }
        }
      })

      this.p2pt.start()
    } else {
      let message = 'P2PT unknown error'

      if (error) {
        message = 'Could not load resource: ' + error
      } else if (!window['P2PT']) {
        message = 'Could not load P2PT interface'
      }

      this.sendDisconnectError(message)
    }
  }

  broadcast(state: boolean, data: null | Uint8Array): void {
    if (!this.p2pt) {
      return
    }

    const message = data == null ? null : Base.uint8_to_base64(data)
    const msg = Crypto.encode([this.token, state, message])

    for (const id in this.peers) {
      this.p2pt.send(this.peers[id], msg)
    }
  }
}

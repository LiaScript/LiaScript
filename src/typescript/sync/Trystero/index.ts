import * as Base from '../Base/index'

var joinRoom: {
  nostr: any
  mqtt: any
  torrent: any
} = {
  nostr: null,
  mqtt: null,
  torrent: null,
}

export class Sync extends Base.Sync {
  private connection?: any
  private pub?: any
  private sub?: any
  private backend: 'nostr' | 'mqtt' | 'torrent'

  constructor(
    backend: 'nostr' | 'mqtt' | 'torrent',
    cbConnection: (topic: string, msg: string) => void,
    cbRelay: (data: Lia.Event) => void,
    onConnect: () => void,
    onReceive: (topic: string, message: any) => void,
    replyOnReceive: boolean = false,
    useInternalCallback: boolean = true
  ) {
    super(
      cbConnection,
      cbRelay,
      onConnect,
      onReceive,
      replyOnReceive,
      useInternalCallback
    )
    this.backend = backend
  }

  destroy() {
    if (this.connection) {
      this.connection.leave()
    }

    super.destroy()
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: string[]
  }) {
    super.connect(data)

    if (joinRoom[this.backend]) {
      this.init(true)
      return
    }

    switch (this.backend) {
      case 'nostr': {
        import('./trystero-nostr.min.js')
          .then((e) => {
            joinRoom.nostr = e.joinRoom
            this.init(true)
          })
          .catch((e) => {
            this.init(false, e.message)
          })

        break
      }

      case 'mqtt': {
        import('./trystero-mqtt.min.js')
          .then((e) => {
            joinRoom.mqtt = e.joinRoom
            this.init(true)
          })
          .catch((e) => {
            this.init(false, e.message)
          })

        break
      }

      case 'torrent': {
        import('./trystero-torrent.min.js')
          .then((e) => {
            joinRoom.torrent = e.joinRoom
            this.init(true)
          })
          .catch((e) => {
            this.init(false, e.message)
          })

        break
      }
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID()

    if (ok && id) {
      const config = { appId: 'liascript' }

      if (this.password) {
        config['password'] = this.password
      }

      const stun = JSON.parse(process.env.STUN || 'null')
      if (stun) {
        config['rtcConfig'] = stun
      }

      this.connection = joinRoom[this.backend](config, id)

      this.connection.onPeerJoin((peerId) => console.log(`${peerId} joined`))

      this.connection.onPeerLeave((peerId) => console.log(`${peerId} left`))

      const [pub, sub] = this.connection.makeAction('message')

      this.pub = pub
      this.sub = sub

      const self = this
      this.sub((data, peerID) => {
        if (data) {
          try {
            const [state, message, timestamp] = data

            if (state) {
              if (message === null) return

              if (timestamp == self.db.timestamp) {
                self.applyUpdate(Base.base64_to_unit8(message))
              } else if (timestamp > self.db.timestamp) {
                self.broadcast(true, self.db.encode())
              } else {
                self.db.timestamp = timestamp
                self.applyUpdate(Base.base64_to_unit8(message), true)
              }
            } else {
              self.pubsubReceive(Base.base64_to_unit8(message))
            }
          } catch (e) {
            console.warn(self.backend, e.message)
          }
        }
      })

      this.sendConnect()
    } else {
      let message = this.backend + ' unknown error'

      if (error) {
        message = 'Could not load resource: ' + error
      }

      this.sendDisconnectError(message)
    }
  }

  broadcast(state: boolean, data: null | Uint8Array): void {
    if (!this.publish) {
      return
    }

    const message = data == null ? null : Base.uint8_to_base64(data)

    this.pub([state, message, this.db.timestamp])
  }
}

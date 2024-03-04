import * as Base from '../Base/index'

export class Sync extends Base.Sync {
  private connection: any
  private conferenceRoom: any
  private domain?: string
  private users: { [id: string]: string | null } = {}

  destroy() {
    this.connection?.disconnect()
    super.destroy()
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    super.connect(data)
    this.domain = data.config || 'meet.jit.si'

    if (window['JitsiMeetJS']) {
      this.init(true)
    } else {
      this.load(
        [
          //'https://code.jquery.com/jquery-3.5.1.min.js',
          'https://meet.jit.si/libs/lib-jitsi-meet.min.js',
          //'https://meet.jit.si/external_api.js',
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    const id = this.uniqueID()

    if (ok && window['JitsiMeetJS'] && id) {
      if (!window['LIA'].debug)
        window['JitsiMeetJS'].setLogLevel(window['JitsiMeetJS'].logLevels.ERROR)

      // https://codepen.io/chadwallacehart/pen/bGLypLY?editors=1010
      this.connection = new window['JitsiMeetJS'].JitsiConnection(null, null, {
        hosts: {
          domain: this.domain,
          muc: `conference.${this.domain}`,
          focus: `focus.${this.domain}`,
        },
        configOverwrite: { openBridgeChannel: false },
        serviceUrl: `https://${this.domain}/http-bind?room=${btoa(id)}`, // Note: wss not avail on meet.jit.si
        clientNode: 'http://jitsi.org/jitsimeet',
      })

      const self = this
      this.connection.addEventListener(
        window['JitsiMeetJS'].events.connection.CONNECTION_ESTABLISHED,
        function () {
          const confOptions = {
            configOverwrite: { openBridgeChannel: false },
            enableLayerSuspension: true,
            p2p: {
              enabled: true,
            },
          }

          self.conferenceRoom = self.connection.initJitsiConference(
            btoa(id).toLowerCase(),
            confOptions
          )

          self.conferenceRoom.setDisplayName(self.token)

          self.conferenceRoom.on(
            window['JitsiMeetJS'].events.conference.CONFERENCE_JOINED,
            () => {
              self.sendConnect()
            }
          )

          self.conferenceRoom.on(
            window['JitsiMeetJS'].errors.conference.PASSWORD_REQUIRED,
            () => {
              self.sendDisconnectError('password required')
            }
          )

          self.conferenceRoom.on(
            window['JitsiMeetJS'].events.conference.USER_JOINED,
            (id) => {
              if (!self.users[id]) {
                self.users[id] = null
              }
            }
          )

          self.conferenceRoom.on(
            window['JitsiMeetJS'].events.conference.USER_LEFT,
            (id) => {
              const token = self.users[id]

              if (token) {
                self.db.removePeer(token)
              }

              delete self.users[id]
            }
          )

          self.conferenceRoom.on(
            window['JitsiMeetJS'].events.conference.MESSAGE_RECEIVED,
            (id, message) => {
              const participant = self.conferenceRoom.getParticipants()

              for (let i = 0; i < participant.length; i++) {
                if (id === participant[i].getId()) {
                  self.users[id] = participant[i].getDisplayName()
                  break
                }
              }

              const msg = Base.base64_to_unit8(message.slice(1))

              if (message[0] === '1') {
                self.applyUpdate(message)
              } else if (message[0] === '0') {
                self.pubsubReceive(msg)
              }
            }
          )

          self.conferenceRoom.join()
        }
      )

      this.connection.addEventListener(
        window['JitsiMeetJS'].events.connection.CONNECTION_FAILED,
        (e: any) => {
          self.sendDisconnectError('Connection failed' + e)
        }
      )
      this.connection.addEventListener(
        window['JitsiMeetJS'].events.connection.CONNECTION_DISCONNECTED,
        (e: any) => {
          self.disconnect()
        }
      )

      this.connection.connect()
    } else {
      let message = 'Jitsi unknown error'

      if (error) {
        message = 'Could not load resource: ' + error
      } else if (window['JitsiMeetJS'] === undefined) {
        message = 'Could not load Jitsi interface'
      }

      this.sendDisconnectError(message)
    }
  }

  broadcast(state: boolean, data: Uint8Array): void {
    try {
      this.conferenceRoom?.sendTextMessage(
        (state ? '1' : '0') + Base.uint8_to_base64(data)
      )
    } catch (e) {
      console.warn('Jitsi: broadcast =>', e.message)
    }
  }
}

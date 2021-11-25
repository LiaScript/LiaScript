import Lia from '../../liascript/types/lia.d'

import { Sync as Base } from '../Base/index'
//import * from '../../../../node_modules/@types/jitsi-meet/index.d'

export class Sync extends Base {
  private connection: any

  constructor(send: Lia.Send) {
    super(send)

    if (window.JitsiMeetJS) {
      this.init(true)
    } else {
      this.load(
        [
          '//code.jquery.com/jquery-3.5.1.min.js',
          '//meet.jit.si/libs/lib-jitsi-meet.min.js',
        ],
        this
      )
    }
  }

  init(ok: boolean, error?: string) {
    window.JitsiMeetJS.init()

    this.connection = new window.JitsiMeetJS.JitsiConnection(null, null, {
      clientNode: 'http://jitsi.org/jitsimeet',
      hosts: {
        // XMPP domain.
        domain: 'https://localhost:1234',

        // When using authentication, domain for guest users.
        // anonymousdomain: 'guest.example.com',

        // Domain for authenticated users. Defaults to <domain>.
        // authdomain: 'jitsi-meet.example.com',

        // Focus component domain. Defaults to focus.<domain>.
        // focus: 'focus.jitsi-meet.example.com',

        // XMPP MUC domain. FIXME: use XEP-0030 to discover it
      },
    })

    this.connection.addEventListener(
      window.JitsiMeetJS.events.connection.CONNECTION_ESTABLISHED,
      function () {
        console.warn('Conn established')
      }
    )

    this.connection.addEventListener(
      window.JitsiMeetJS.events.connection.CONNECTION_FAILED,
      function (e) {
        console.warn('Conn failed', e)
      }
    )
    this.connection.addEventListener(
      window.JitsiMeetJS.events.connection.CONNECTION_DISCONNECTED,
      function (e) {
        console.warn('Conn disconnected', e)
      }
    )

    console.warn('###########################################', this.connection)

    this.connection.connect()
  }

  connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {}

  disconnect() {}

  publish(message: Object) {}
}

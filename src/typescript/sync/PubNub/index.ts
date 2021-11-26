import Lia from '../../liascript/types/lia.d'

import { Sync as Base } from '../Base/index'

export class Sync extends Base {
  private pubnub: any
  private channel: string

  constructor(send: Lia.Send) {
    super(send)

    this.channel = ''
  }

  async connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {
    super.connect(data)

    if (window.PubNub) {
      this.init(true)
    } else {
      this.load(['//cdn.pubnub.com/sdk/javascript/pubnub.4.21.6.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.PubNub) {
      this.channel = btoa(this.uniqueID())

      this.pubnub = new PubNub({
        publishKey: process.env.PUBNUB_PUBLISH,
        subscribeKey: process.env.PUBNUB_SUBSCRIBE,
      })

      this.pubnub.subscribe({ channels: [this.channel] })

      let self = this

      this.pubnub.addListener({
        message: function (event) {
          self.send(event.message)
        },
      })

      this.sync('connect', this.token)
    }
  }

  disconnect() {
    this.publish(this.syncMsg('leave', this.token))

    this.sync('disconnect')
  }

  publish(message: Object) {
    if (this.pubnub) {
      this.pubnub.publish(
        { channel: this.channel, message: message },
        function (status, response) {}
      )
    }
  }
}

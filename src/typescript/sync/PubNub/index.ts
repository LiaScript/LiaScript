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
      this.load(['//cdn.pubnub.com/sdk/javascript/pubnub.4.33.1.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.PubNub) {
      this.channel = btoa(this.uniqueID())

      this.pubnub = new PubNub({
        publishKey: process.env.PUBNUB_PUBLISH,
        subscribeKey: process.env.PUBNUB_SUBSCRIBE,
        uuid: this.token,
        heartbeatInterval: 30,
        // logVerbosity: true,
        // heartbeatInterval: 10,
        // presenceTimeout: 30,
      })

      this.pubnub.subscribe({
        channels: [this.channel],
        withPresence: true,
        restore: false,
      })

      let self = this

      this.pubnub.addListener({
        status: function (statusEvent: any) {
          //console.log('PUBNUB status:', statusEvent)
          //if (statusEvent.category === "PNConnectedCategory") {
          //    publishSampleMessage();
          //}
        },
        message: function (event: any) {
          // prevent return of self send messages
          if (event.publisher !== self.token) {
            //console.log('SUB:', JSON.stringify(event.message.message))
            self.send(event.message)
          }
        },
        presence: function (event: any) {
          //console.log('presence: ', event)
          switch (event.action) {
            case 'leave': {
              self.send(self.syncMsg('leave', event.uuid))
            }
          }
        },
      })

      this.sync('connect', this.token)
    }
  }

  disconnect() {
    this.publish(this.syncMsg('leave', this.token))
    if (this.pubnub) {
      this.pubnub.unsubscribeAll()
      this.pubnub.stop()
    }

    this.sync('disconnect')
  }

  publish(message: Object) {
    if (this.pubnub) {
      //console.log('PUB: ', message.message)
      this.pubnub.publish(
        {
          channel: this.channel,
          message: message,
          storeInHistory: false,
        },
        function (status: any, response: any) {
          //console.log('PUBNUB publish', status, response)
        }
      )
    }
  }
}

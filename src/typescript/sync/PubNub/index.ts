import * as Base from '../Base/index'
import log from '../../liascript/log'

export class Sync extends Base.Sync {
  private pubnub: any
  private channel: string = ''
  private publishKey?: string
  private subscribeKey?: string

  destroy() {
    if (this.pubnub) {
      this.pubnub.unsubscribeAll()
      this.pubnub.stop()
    }

    super.destroy()
  }

  async connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    super.connect(data)

    this.publishKey = data.config.publishKey
    this.subscribeKey = data.config.subscribeKey

    if (window['PubNub']) {
      this.init(true)
    } else {
      this.load(['//cdn.pubnub.com/sdk/javascript/pubnub.4.33.1.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (!this.publishKey || !this.subscribeKey) {
      return this.sendDisconnectError(
        'You have to provide a valid pair of keys'
      )
    }

    const id = this.uniqueID()

    if (ok && window['PubNub'] && id) {
      this.channel = btoa(id)

      // @ts-ignore
      this.pubnub = new PubNub({
        publishKey: this.publishKey,
        subscribeKey: this.subscribeKey,
        uuid: this.token,
        heartbeatInterval: 30,
        // logVerbosity: true,
        // heartbeatInterval: 10,
        // presenceTimeout: 30,
        cipherKey: this.password,
      })

      this.pubnub.subscribe({
        channels: [this.channel],
        withPresence: true,
        restore: false,
      })

      let self = this

      this.pubnub.addListener({
        status: function (statusEvent: any) {
          log.info('PUBNUB status:', statusEvent)
          if (statusEvent.category === 'PNConnectedCategory') {
            self.sendConnect()
          } else if (statusEvent.category === 'PNBadRequestCategory') {
            self.sendDisconnectError(statusEvent.errorData.message)
          }
        },
        message: function (event: any) {
          // prevent return of self send messages
          if (event.publisher !== self.token) {
            //console.log('SUB:', JSON.stringify(event.message))
            const [state, message] = event.message

            if (state) {
              self.applyUpdate(Base.base64_to_unit8(message))
            } else {
              self.pubsubReceive(Base.base64_to_unit8(message))
            }
          }
        },
        presence: function (event: any) {
          // console.log('presence: ', event)
          switch (event.action) {
            case 'leave': {
              self.db.removePeer(event.uuid)
            }
          }
        },
      })
    }
  }

  broadcast(state: boolean, data: Uint8Array): void {
    if (this.pubnub) {
      //console.log('PUB: ', message.message)
      this.pubnub.publish(
        {
          channel: this.channel,
          message: [state, Base.uint8_to_base64(data)],
          storeInHistory: false,
        },
        function (status: any, response: any) {
          // console.log('PUBNUB publish', status, response)
        }
      )
    }
  }
}

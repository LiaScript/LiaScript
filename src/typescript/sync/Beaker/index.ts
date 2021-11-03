import Lia from '../../liascript/types/lia.d'
import Beaker from './beaker.d'

import { Sync as Base } from '../Base/index'

function encode(json: object) {
  return new TextEncoder().encode(JSON.stringify(json))
}

function decode(message: Uint8Array) {
  let string = new TextDecoder().decode(message)

  try {
    return JSON.parse(string)
  } catch (e) {
    console.warn('Sync(Beaker): ', e)
  }
}

export function isSupported() {
  return window.beaker && window.location.protocol === 'hyper' ? true : false
}

export class Sync extends Base {
  private peerIds: Set<number>
  private peerChannelIds: Set<number>

  private peerEvent?: Beaker.Event
  private peerChannelEvent?: Beaker.UserEvent

  constructor() {
    super()

    this.peerIds = new Set()
    this.peerChannelIds = new Set()
  }

  connect(
    send: Lia.Send,
    data: {
      course: string
      room: string
      username: string
      password?: string
    }
  ) {
    if (!window.beaker) return

    super.connect(send, data)

    let self = this

    this.peerIds = new Set()
    this.peerChannelIds = new Set()

    this.peerEvent = window.beaker.peersockets.watch()

    this.peerEvent.addEventListener('join', (e: Beaker.Message) => {
      self.peerIds.add(e.peerId)

      self.sendTo(e.peerId, self.syncMsg('join'))
    })
    this.peerEvent.addEventListener('leave', (e: Beaker.Message) => {
      self.peerIds.delete(e.peerId)
    })

    this.peerChannelEvent = window.beaker.peersockets.join(this.uniqueID())
    this.peerChannelEvent.addEventListener(
      'message',
      function (event: Beaker.Message) {
        let message = decode(event.message)

        if (message) {
          if (message.route.length == 3) {
            switch (message.route[2].topic) {
              case 'join': {
                if (!self.peerChannelIds.has(event.peerId)) {
                  self.peerChannelIds.add(event.peerId)
                  self.sendTo(event.peerId, self.syncMsg('join'))
                }

                message.message = JSON.stringify(event.peerId)
                break
              }
              case 'leave': {
                self.peerChannelIds.delete(event.peerId)
                message.message = JSON.stringify(event.peerId)
                break
              }
            }
          }

          send(message)
        }
      }
    )

    this.publish(this.syncMsg('join'))

    this.sync('connect', true)
  }

  disconnect() {
    //if (this.peerEvent) this.peerEvent.close()

    this.publish(this.syncMsg('leave'))
    this.sync('disconnect')
  }

  sync(topic: string, message: any = null) {
    if (this.send) {
      this.send(this.syncMsg(topic, message))
    }
  }

  syncMsg(topic: string, message: any = null) {
    return {
      route: [
        { topic: 'sync', id: null },
        { topic: 'sync', id: null },
        { topic: topic, id: null },
      ],
      message: message,
    }
  }

  publish(message: Object) {
    if (this.peerChannelEvent) {
      let msg = encode(message)

      for (let peerId of this.peerIds) {
        this.peerChannelEvent.send(peerId, msg)
      }
    }
  }

  sendTo(peerId: number, message: Object) {
    if (this.peerChannelEvent) {
      this.peerChannelEvent.send(peerId, encode(message))
    }
  }
}

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

export function isSupported(): boolean {
  return window.beaker && window.location.protocol === 'hyper:' ? true : false
}

export class Sync extends Base {
  private peerIds: Set<number>

  private peerEvent?: Beaker.Event
  private peerChannelEvent?: Beaker.UserEvent

  constructor(send: Lia.Send) {
    super(send)

    this.peerIds = new Set()
  }

  connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {
    if (!window.beaker) return

    super.connect(data)

    let self = this

    this.peerIds = new Set()

    this.peerEvent = window.beaker.peersockets.watch()

    this.peerEvent.addEventListener('join', (e: Beaker.Message) => {
      self.peerIds.add(e.peerId)
    })
    this.peerEvent.addEventListener('leave', (e: Beaker.Message) => {
      self.peerIds.delete(e.peerId)
      self.sync('leave', e.peerId)

      console.warn('LEAVE', e)
    })

    this.peerChannelEvent = window.beaker.peersockets.join(this.uniqueID())
    this.peerChannelEvent.addEventListener(
      'message',
      function (event: Beaker.Message) {
        let message = decode(event.message)

        if (message) {
          self.send(message)
        }
      }
    )

    this.sync('connect', this.token)
  }

  disconnect() {
    this.publish(this.syncMsg('leave', this.token))

    if (this.peerChannelEvent) this.peerChannelEvent.close()

    this.sync('disconnect')
  }

  sync(topic: string, message: any = null) {
    this.send(this.syncMsg(topic, message))
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
    console.warn('BEAKER', message)
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

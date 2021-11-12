import Lia from '../../liascript/types/lia.d'
import Beaker from './beaker.d'

import { Sync as Base } from '../Base/index'

/* This function is only required to generate a random string, that is used
as a personal ID for every peer, since it is not possible at the moment to
get the own peer ID from the beaker browser.
*/
function random(length: number = 16) {
  // Declare all characters
  let chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  // Pick characters randomly
  let str = ''
  for (let i = 0; i < length; i++) {
    str += chars.charAt(Math.floor(Math.random() * chars.length))
  }

  return str
}

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

  private id: string

  constructor(send: Lia.Send) {
    super(send)

    this.id = random()

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

    this.sync('connect', this.id)
  }

  disconnect() {
    this.publish(this.syncMsg('leave'))

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

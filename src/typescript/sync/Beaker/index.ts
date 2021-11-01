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

export class Sync extends Base {
  private peerIds?: Set<number>

  private peerEvent?: Beaker.Event
  private userEvent?: Beaker.UserEvent

  isSupported() {
    return window.beaker && window.location.protocol === 'hyper' ? true : false
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

    let peerIds: Set<number> = new Set()
    this.peerIds = peerIds

    this.peerEvent = window.beaker.peersockets.watch()

    this.peerEvent.addEventListener('join', (e: Beaker.Message) => {
      peerIds.add(e.peerId)
    })
    this.peerEvent.addEventListener('leave', (e: Beaker.Message) => {
      peerIds.delete(e.peerId)
    })

    this.userEvent = window.beaker.peersockets.join(this.uniqueID())
    this.userEvent.addEventListener(
      'message',
      function (event: Beaker.Message) {
        let message = decode(event.message)

        if (message) send(message)
      }
    )

    if (this.send)
      this.send({
        route: [
          { topic: 'sync', id: null },
          { topic: 'sync', id: null },
          { topic: 'connect', id: null },
        ],
        message: true,
      })
  }

  disconnect() {
    if (this.send)
      this.send({
        route: [
          { topic: 'sync', id: null },
          { topic: 'sync', id: null },
          { topic: 'disconnect', id: null },
        ],
        message: null,
      })
  }

  publish(message: Object) {
    if (this.peerIds && this.userEvent) {
      let msg = encode(message)

      for (let peerId of this.peerIds) {
        this.userEvent.send(peerId, msg)
      }
    }
  }
}

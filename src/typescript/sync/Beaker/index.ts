import Beaker from './beaker.d'

import * as Base from '../Base/index'

/*
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
*/

export function isSupported(): boolean {
  return window.beaker && window.location.protocol === 'hyper:' ? true : false
}

export class Sync extends Base.Sync {
  private peerIds: Set<number> = new Set()

  private peerEvent?: Beaker.Event
  private peerChannelEvent?: Beaker.UserEvent

  destroy() {
    if (this.peerChannelEvent) {
      this.peerChannelEvent.close()
    }
    super.destroy()
  }

  connect(data: {
    course: string
    room: string
    password?: string
    config?: any
  }) {
    if (!window.beaker) return

    super.connect(data)

    this.peerIds = new Set()

    this.peerEvent = window.beaker.peersockets.watch()

    let self = this
    this.peerEvent.addEventListener('join', (e: Beaker.Message) => {
      self.peerIds.add(e.peerId)
    })
    this.peerEvent.addEventListener('leave', (e: Beaker.Message) => {
      self.peerIds.delete(e.peerId)

      console.warn('LEAVE', e)
    })

    const id = this.uniqueID()

    if (id) {
      this.peerChannelEvent = window.beaker.peersockets.join(id)
      this.peerChannelEvent.addEventListener(
        'message',
        function (event: Beaker.Message) {
          if (event.message) {
            self.applyUpdate(event.message)
          }
        }
      )

      this.sendConnect()
    }
  }

  broadcast(data: Uint8Array): void {
    if (this.peerChannelEvent) {
      for (let peerId of this.peerIds) {
        this.peerChannelEvent.send(peerId, data)
      }
    }
  }
}

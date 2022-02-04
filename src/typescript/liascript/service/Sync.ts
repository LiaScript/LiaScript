import * as Beaker from '../../sync/Beaker/index'
import * as Jitsi from '../../sync/Jitsi/index'
import * as Matrix from '../../sync/Matrix/index'
import * as PubNub from '../../sync/PubNub/index'
import * as GUN from '../../sync/Gun/index'

import log from '../log'

var sync: any
var elmSend: Lia.Send | null

const Service = {
  PORT: 'sync',

  supported: function (allowSync: boolean) {
    return allowSync
      ? [
          // beaker is only supported within the beaker-browser
          Beaker.isSupported() ? 'beaker' : '',
          // remove these strings if you want to enable or disable certain sync support
          'gun',
          'jitsi',
          'matrix',
          'pubnub',
        ]
      : []
  },

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'connect': {
        if (sync) sync = undefined

        if (elmSend) {
          // for what so ever reason perform a deep-copy
          const event_ = { ...event }
          const cbConnection = function (topic: string, msg: any) {
            event_.message.cmd = topic
            event_.message.param = msg
            event_.reply = true

            console.warn(event_)

            elmSend(event_)
          }

          switch (event.message.param.backend) {
            case 'beaker':
              sync = new Beaker.Sync(elmSend)
              break

            case 'gun':
              sync = new GUN.Sync(cbConnection, elmSend)
              break

            case 'jitsi':
              sync = new Jitsi.Sync(elmSend)
              break

            case 'matrix':
              sync = new Matrix.Sync(elmSend)
              break

            case 'pubnub':
              sync = new PubNub.Sync(elmSend)
              break

            default:
              log.error('could not load =>', event.message)
          }
        }

        if (sync) sync.connect(event.message.param.config)

        break
      }

      case 'disconnect': {
        if (sync) {
          event.message.cmd = 'leave'
          sync.disconnect(event)

          sync = null

          if (elmSend) {
            event.message.cmd = 'disconnect'
            elmSend(event)
          }
        }

        break
      }

      default: {
        if (sync) {
          sync.publish(event)
        } else {
          log.warn('(Service Sync) unknown message =>', event.message)
        }
      }
    }
  },
}

export default Service

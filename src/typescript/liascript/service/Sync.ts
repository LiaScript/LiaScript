import log from '../log'

var sync: any
var elmSend: Lia.Send | null

var Beaker
var Edrys
var Jitsi
var Matrix
var PubNub
var Gun

const Service = {
  PORT: 'sync',

  supported: [
    // beaker is only supported within the beaker-browser
    window.beaker && window.location.protocol === 'hyper:' ? 'beaker' : '',
    // remove these strings if you want to enable or disable certain sync support
    'edrys',
    'gun',
    'jitsi',
    //'matrix',
    'pubnub',
  ],

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: async function (event: Lia.Event) {
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

            if (elmSend) elmSend(event_)
          }

          switch (event.message.param.backend) {
            case 'beaker':
              if (!Beaker) {
                import('../../sync/Beaker/index').then((e) => {
                  Beaker = e
                  Service.handle(event)
                })
                return
              }

              sync = new Beaker.Sync(cbConnection, elmSend)
              break

            case 'edrys':
              if (!Edrys) {
                import('../../sync/Edrys/index').then((e) => {
                  Edrys = e
                  Service.handle(event)
                })
                return
              }

              sync = new Edrys.Sync(cbConnection, elmSend)

              break

            case 'gun':
              if (!Gun) {
                import('../../sync/Gun/index').then((e) => {
                  Gun = e
                  Service.handle(event)
                })
                return
              }

              sync = new Gun.Sync(cbConnection, elmSend)
              break

            case 'jitsi':
              if (!Jitsi) {
                import('../../sync/Jitsi/index').then((e) => {
                  Jitsi = e
                  Service.handle(event)
                })
                return
              }

              sync = new Jitsi.Sync(cbConnection, elmSend)
              break

            // case 'matrix':
            //   if (!Matrix) {
            //     import('../../sync/Matrix/index').then((e) => {
            //       Matrix = e
            //       Service.handle(event)
            //     })
            //     return
            //   }

            //   sync = new Matrix.Sync(cbConnection, elmSend)
            //   break

            case 'pubnub':
              if (!PubNub) {
                import('../../sync/PubNub/index').then((e) => {
                  PubNub = e
                  Service.handle(event)
                })
                return
              }

              sync = new PubNub.Sync(cbConnection, elmSend)
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
          sync.disconnect()

          sync = undefined

          /*
          if (elmSend) {
            event.message.cmd = 'disconnect'
            elmSend(event)
          }
          */
        }

        break
      }

      default: {
        if (sync) {
          sync.publish(event)
        }
      }
    }
  },
}

export default Service

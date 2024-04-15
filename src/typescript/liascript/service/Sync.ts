import log from '../log'

var sync: any
var elmSend: Lia.Send | null

var Edrys
// var Jitsi
// var Matrix
var PubNub
var Gun
var P2PT
var Trystero

function hasRTCPeerConnection() {
  return !!(
    window.RTCPeerConnection ||
    // @ts-ignore
    window.mozRTCPeerConnection ||
    // @ts-ignore
    window.webkitRTCPeerConnection
  )
}

const Service = {
  PORT: 'sync',

  supported: [
    // remove these strings if you want to enable or disable certain sync support
    'edrys',
    'gun',
    //'jitsi',
    //'matrix',
    'mqtt',
    'nostr',
    'pubnub',
    hasRTCPeerConnection() ? 'p2pt' : '',
    'torrent',
  ],

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_

    if (window['LIA']) {
      window['LIA']['classroom'] = {
        connected: false,

        publish,
        subscribe,
        unsubscribe,
        on,
      }
    }
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
            /*
          const backend = event.message.param.backend

          switch (backend) {
            case 'edrys':
              if (!Edrys) {
                import('../../sync/Edrys/index').then((e) => {
                  Edrys = e
                  Service.handle(event)
                })
                return
              }

              sync = new Edrys.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true
              )

              break

            case 'gun':
              if (!Gun) {
                import('../../sync/Gun/index').then((e) => {
                  Gun = e
                  Service.handle(event)
                })
                return
              }

              sync = new Gun.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false
              )
              break

            case 'mqtt':
            case 'nostr':
            case 'torrent': {
              if (!Trystero) {
                import('../../sync/Trystero/index').then((e) => {
                  Trystero = e
                  Service.handle(event)
                })
                return
              }

              sync = new Trystero.Sync(
                backend as 'mqtt' | 'nostr' | 'torrent',
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true
              )

              break
            }

            // case 'jitsi':
            //   if (!Jitsi) {
            //     import('../../sync/Jitsi/index').then((e) => {
            //       Jitsi = e
            //       Service.handle(event)
            //     })
            //     return
            //   }

            //   sync = new Jitsi.Sync(
            //     cbConnection,
            //     elmSend,
            //     onConnect,
            //     onReceive,
            //     true
            //   )
            //   break

            case 'matrix':
              if (!Matrix) {
                import('../../sync/Matrix/index').then((e) => {
                  Matrix = e
                  Service.handle(event)
                })
                return
              }

              sync = new Matrix.Sync(cbConnection, elmSend)
              break

            case 'pubnub':
              if (!PubNub) {
                import('../../sync/PubNub/index').then((e) => {
                  PubNub = e
                  Service.handle(event)
                })
                return
              }

              sync = new PubNub.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true
              )
              break

            case 'p2pt':
              if (!P2PT) {
                import('../../sync/P2PT/index').then((e) => {
                  P2PT = e
                  Service.handle(event)
                })
                return
              }

              sync = new P2PT.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true
              )
              break
            */
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

          window.LIA.classroom.publish = publish
          window.LIA.classroom.connected = false
          CALLBACK.disconnect.forEach((cb) => cb())
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

//*************************************************************************

type Subscription = {
  id: number
  callback: (message: any) => void
}

// Container for all subscriptions
var SUBSCRIPTIONS: { [topic: string]: Subscription[] } = {}
var BACKUP: { [topic: string]: any } = {}

// Connection change callback container
var CALLBACK: {
  connect: (() => void)[]
  disconnect: (() => void)[]
} = {
  connect: [],
  disconnect: [],
}

function publish(topic: string, message: any) {
  console.warn(
    'Classroom: not connected, cannot publish topic => ' + { topic, message }
  )
}

function subscribe(topic: string, callback: (message: any) => void): number {
  const id = Math.round(Math.random() * 1000000000)

  if (!SUBSCRIPTIONS[topic]) {
    SUBSCRIPTIONS[topic] = []
  }
  SUBSCRIPTIONS[topic].push({ id, callback })

  if (BACKUP[topic]) {
    setTimeout(() => callback(BACKUP[topic]), 100)
  }

  return id
}

function unsubscribe(id: number) {
  for (const topic in SUBSCRIPTIONS) {
    SUBSCRIPTIONS[topic] = SUBSCRIPTIONS[topic].filter((sub) => sub.id !== id)
  }
}

function on(event: 'connect' | 'disconnect', callback: () => void) {
  switch (event) {
    case 'connect': {
      CALLBACK.connect.push(callback)
      break
    }

    case 'disconnect': {
      CALLBACK.disconnect.push(callback)
      break
    }

    default: {
      console.warn('Classroom: unknown event -> ' + event)
    }
  }
}

function onReceive(topic: string, message: any) {
  BACKUP[topic] = message

  if (SUBSCRIPTIONS[topic]) {
    SUBSCRIPTIONS[topic].forEach((sub) => sub.callback(message))
  }
}

function onConnect() {
  window.LIA.classroom.connected = true

  window.LIA.classroom.publish = function (topic: string, message: any) {
    if (sync) {
      if (window.LIA.classroom.connected) {
        sync.pubsubSend(topic, message)
      } else {
        publish(topic, message)
      }
    }
  }

  CALLBACK.connect.forEach((cb) => cb())
}

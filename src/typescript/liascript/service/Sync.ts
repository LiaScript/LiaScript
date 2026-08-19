import log from '../log'
import { docId } from '../../sync/Base/persist'

var sync: any
var elmSend: Lia.Send | null
var Database: any

var Edrys
// var Jitsi
// var Matrix
var PubNub
var Gun
var Local
var P2PT
var Trystero
var WebSocket_
var PeerJS_
var SimplePeer_

/** Report a failure back into Elm, reusing the same "error" channel that is
 * also used for connection errors, see `Lia.Sync.Update`.
 */
function sendError(event: Lia.Event, message: string) {
  if (elmSend) {
    elmSend({
      ...event,
      message: { cmd: 'error', param: message },
      reply: true,
    })
  }
}

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
    'ipfs',
    'local',
    'mqtt',
    'nostr',
    'pubnub',
    // hasRTCPeerConnection() ? 'p2pt' : '',
    hasRTCPeerConnection() ? 'peerjs' : '',
    hasRTCPeerConnection() ? 'simplepeer' : '',
    'torrent',
    'websocket',
  ],

  init: function (elmSend_: Lia.Send, database_: any) {
    elmSend = elmSend_
    Database = database_

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
                true,
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
                false,
              )
              break

            case 'local':
              if (!Local) {
                import('../../sync/Local/index').then((e) => {
                  Local = e
                  Service.handle(event)
                })
                return
              }

              sync = new Local.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false,
              )
              break

            case 'ipfs':
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
                backend as 'mqtt' | 'nostr' | 'torrent' | 'ipfs',
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true,
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

            /*
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
            */

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
                true,
              )
              break
            /*
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
                true,
              )
              break
*/
            case 'peerjs':
              if (!PeerJS_) {
                import('../../sync/PeerJS/index').then((e) => {
                  PeerJS_ = e
                  Service.handle(event)
                })
                return
              }

              sync = new PeerJS_.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false,
              )
              break

            case 'simplepeer':
              if (!SimplePeer_) {
                import('../../sync/SimplePeer/index').then((e) => {
                  SimplePeer_ = e
                  Service.handle(event)
                })
                return
              }

              sync = new SimplePeer_.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false,
              )
              break

            case 'websocket':
              if (!WebSocket_) {
                import('../../sync/WebSocket/index').then((e) => {
                  WebSocket_ = e
                  Service.handle(event)
                })
                return
              }

              sync = new WebSocket_.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                false,
              )
              break

            default:
              log.error('could not load =>', event.message)
          }
        }

        if (sync) {
          sync.connect(event.message.param.config)

          const config = event.message.param.config

          // the "Own Notes" classroom still gets its "updated" timestamp
          // recorded here; the UI pins it to its own tile instead of
          // rendering it as a deletable entry in the saved-classrooms list
          if (config.persistent && Database) {
            // a failing save must not tear down an otherwise working
            // connection, thus this is only reported to the console
            Database.saveClassroom(config.uidDB || config.course, {
              room: config.room,
              backend: config.fullBackend,
              password: config.password,
              name: config.name,
            })?.catch((e: any) => {
              log.warn('could not save classroom ->', e?.message || e)
            })
          }
        }

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

      case 'list_classrooms': {
        const course = event.message.param

        try {
          const list = Database ? await Database.getClassrooms(course) : []

          if (elmSend) {
            elmSend({
              ...event,
              message: { cmd: 'classrooms', param: list },
              reply: true,
            })
          }
        } catch (e: any) {
          log.warn('could not list classrooms ->', e?.message || e)
          sendError(event, `could not load classrooms: ${e?.message || e}`)
        }

        break
      }

      case 'delete_classroom': {
        const { course, room, backend } = event.message.param

        try {
          if (Database) {
            await Database.deleteClassroom(course, room, backend)
            await Database.clearYjsUpdates(course, docId(course, room, backend))
          }
        } catch (e: any) {
          log.warn('could not delete classroom ->', e?.message || e)
          sendError(event, `could not delete classroom: ${e?.message || e}`)
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
    'Classroom: not connected, cannot publish topic => ' + { topic, message },
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

      // if the callback is added after the connection was established
      if (window.LIA.classroom.connected) {
        callback()
      }

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

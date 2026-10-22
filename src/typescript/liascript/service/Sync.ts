import log from '../log'
import { docId } from '../../sync/Base/persist'
import * as peerCrypto from '../../sync/Base/peerCrypto'
import type { TemplateLayer } from '../../sync/Base/db'

var sync: any
var elmSend: Lia.Send | null
var Database: any

var Edrys
// var Jitsi
// var Matrix
var Ably
var PubNub
var Gun
var Local
var P2PT
var Trystero
var Nostr
var WebSocket_
var PeerJS_
var SimplePeer_

/** Report a failure of the local classroom bookkeeping (saved-classrooms
 * table) back into Elm. This deliberately uses the advisory "warning"
 * channel, not "error": "error" is reserved for the connection itself and
 * makes Elm reset its state to Disconnected - while the TS sync instance
 * here would keep running, leaving Elm believing it is offline (no own
 * answers synced, no summaries shown) although data still flows. A failed
 * IndexedDB write must not do that, see `Lia.Sync.Update`.
 */
function sendWarning(event: Lia.Event, message: string) {
  if (elmSend) {
    elmSend({
      ...event,
      message: { cmd: 'warning', param: message },
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
    'ably',
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

        layer,
        array: shared('getArray'),
        map: shared('getMap'),
        text: shared('getText'),
      }
    }
  },

  handle: async function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'connect': {
        // A reconnect (password/room/backend/mode change, etc.) previously
        // just dropped the reference here without tearing down the old
        // instance - its WebSocket/transport, timers and GenericProvider
        // stayed alive indefinitely. Harmless-ish when payloads were
        // plaintext (a stray duplicate Yjs update is a no-op), but now that
        // encrypted backends hard-fail on a mismatched key, a leaked old
        // connection can spam decrypt-failure warnings forever.
        BACKUP = {}
        if (sync) {
          sync.disconnect()
          sync = undefined
          // until the new room is synced, nothing may be mirrored into it
          window.LIA.classroom.connected = false
        }

        if (elmSend) {
          const cbConnection = function (topic: string, msg: any) {
            if (elmSend)
              elmSend({
                ...event,
                message: { cmd: topic, param: msg },
                reply: true,
              })
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
            // 'nostr' used to be Trystero's WebRTC-signaling-over-Nostr
            // strategy - retired in favor of the real Nostr-relay backend
            // below (see case 'nostr').
            case 'torrent': {
              if (!Trystero) {
                import('../../sync/Trystero/index').then((e) => {
                  Trystero = e
                  Service.handle(event)
                })
                return
              }

              sync = new Trystero.Sync(
                backend as 'mqtt' | 'torrent' | 'ipfs',
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true,
              )

              break
            }

            case 'nostr':
              if (!Nostr) {
                import('../../sync/Nostr/index').then((e) => {
                  Nostr = e
                  Service.handle(event)
                })
                return
              }

              sync = new Nostr.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true,
              )
              break

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

            case 'ably':
              if (!Ably) {
                import('../../sync/Ably/index').then((e) => {
                  Ably = e
                  Service.handle(event)
                })
                return
              }

              sync = new Ably.Sync(
                cbConnection,
                elmSend,
                onConnect,
                onReceive,
                true,
              )
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
          // an old connection may still finish a re-check after teardown
          const db = sync.db
          db.onTemplate = (
            name: string,
            layers: TemplateLayer[],
            ownTime: number,
          ) => {
            if (sync?.db === db && window.LIA.classroom.connected) {
              roomChanged(name, layers, ownTime)
            }
          }
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
              title: config.title,
              notes: config.notes,
              mode: config.mode,
              ownerTokenHash: config.ownerTokenHash,
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
          BACKUP = {}

          window.LIA.classroom.publish = publish
          window.LIA.classroom.connected = false
          for (const name in LAYERS) emitLayers(name, localView(name))
          CALLBACK.disconnect.forEach((cb) => cb())
        }

        break
      }

      // Gates the actual connect for a join: Elm withholds 'connect' until
      // this resolves (see the "password_ok" case in Lia.Sync.Update), so a
      // wrong password never opens the room, not even for an instant.
      // Deterministic check against the room's `pwCheck` hint (see
      // peerCrypto.verifyPasswordCheck), unlike the P2P empty-room heuristic
      // in Base/index.ts. A crypto failure (malformed salt/hint, near-never
      // in practice) fails open rather than stranding the user in Pending
      // forever - the same leniency plaintext connects already had before
      // this check existed.
      case 'check_password': {
        const { password, pwSalt, pwCheck } = event.message.param

        let ok = true
        try {
          ok = await peerCrypto.verifyPasswordCheck(password, pwSalt, pwCheck)
        } catch (e: any) {
          log.warn('password check failed ->', e?.message || e)
        }

        if (elmSend) {
          elmSend({
            ...event,
            message: ok
              ? { cmd: 'password_ok', param: null }
              : { cmd: 'error', param: 'Wrong classroom password.' },
            reply: true,
          })
        }

        break
      }

      // Lets the creator mint the room's owner secret before ever
      // connecting - ownership only ever comes from explicitly generating
      // one here (or from following an owner-link carrying one), never
      // implicitly from just being first to connect (see
      // db.ts resolveOwnerToken()).
      case 'generate_owner_token': {
        try {
          const token = peerCrypto.randomBytesBase64(32)
          const hash = await peerCrypto.sha256Base64(token)

          if (elmSend) {
            elmSend({
              ...event,
              message: { cmd: 'owner_token', param: { token, hash } },
              reply: true,
            })
          }
        } catch (e: any) {
          log.warn('owner token generation failed ->', e?.message || e)
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
          sendWarning(event, `could not load classrooms: ${e?.message || e}`)
        }

        break
      }

      case 'update_classroom_meta': {
        const { course, room, backend, title, notes, name, owner, ownerTokenHash } =
          event.message.param

        try {
          if (Database) {
            await Database.updateClassroomMeta(course, room, backend, {
              title,
              notes,
              name,
              owner,
              ownerTokenHash,
            })
          }
        } catch (e: any) {
          log.warn('could not update classroom ->', e?.message || e)
          sendWarning(event, `could not update classroom: ${e?.message || e}`)
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
          sendWarning(event, `could not delete classroom: ${e?.message || e}`)
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
    'Classroom: not connected, cannot publish topic =>',
    topic,
    message,
  )
}

function subscribe(topic: string, callback: (message: any) => void): number {
  const id = Math.round(Math.random() * 1000000000)

  if (!SUBSCRIPTIONS[topic]) {
    SUBSCRIPTIONS[topic] = []
  }
  SUBSCRIPTIONS[topic].push({ id, callback })

  if (topic in BACKUP) {
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

  // the room may hold an older or a newer copy of the own layer
  for (const name in LAYERS) reconcile(name)

  CALLBACK.connect.forEach((cb) => cb())
}

//*************************************************************************
// Template state
//
// `layer(name)`: an own layer per peer, kept locally (table `template`) and
// mirrored into the classroom like quiz answers - so authorship and the
// classroom mode decide who sees which layer, see `CRDT.getTemplate`.
//
// `array/map/text(name)`: one shared Yjs type for everyone, only while
// connected, no authorship.

type Layer = {
  own: any[]
  // last change of the own layer, the newer copy wins on a new connection
  time: number
  // `time` of the last state that matched the room, own changes made while
  // offline are newer
  synced: number
  loaded: Promise<void>
  // writes into the classroom, one after another
  queue: Promise<void>
  // writes still waiting in the queue, the room copy is behind `own`
  ops: number
  subs: ((layers: TemplateLayer[], info: { remote: boolean }) => void)[]
  saving?: ReturnType<typeof setTimeout>
  pending: boolean
  // set() before loading finished replaces the stored layer
  replaced: boolean
}

var LAYERS: { [name: string]: Layer } = {}

function layer(name: string) {
  let l = LAYERS[name]

  if (!l) {
    const fresh: Layer = {
      own: [],
      time: 0,
      synced: 0,
      subs: [],
      loaded: Promise.resolve(),
      queue: Promise.resolve(),
      ops: 0,
      replaced: false,
      pending: false,
    }

    fresh.loaded = Promise.resolve(Database?.loadTemplate(name))
      .then((stored: any) => {
        if (!stored || fresh.replaced) return
        // older entries are a plain array
        const values = Array.isArray(stored) ? stored : stored.values
        fresh.own = (values || []).concat(fresh.own)
        fresh.time = Math.max(fresh.time, stored.time || 0)
        fresh.synced = stored.synced || 0
      })
      .catch((e: any) =>
        log.warn('could not load template ->', name, e?.message || e),
      )

    l = LAYERS[name] = fresh
    if (window.LIA.classroom.connected) reconcile(name)
  }

  return {
    push(value: any) {
      if (value === undefined) return
      l.own.push(value)
      const time = (l.time = Date.now())
      changed(name, time, (db) => db.appendTemplate(name, value, time))
    },

    // Replace the own layer (undo, erase, move), or with an `id` the layer
    // of another peer, which only the classroom owner may do.
    set(values: any[], id?: string) {
      values = values.filter((value) => value !== undefined)
      const time = Date.now()

      if (id && id !== ownId()) {
        if (window.LIA.classroom.connected) {
          write(name, (db) => db.writeTemplate(id, name, values, time))
        } else {
          console.warn('Classroom: not connected, cannot change layer of =>', id)
        }
        return
      }

      l.own = values
      l.time = time
      l.replaced = true
      changed(name, time, (db) => db.writeTemplate(ownId(), name, values, time), true)
    },

    // a copy of the own layer
    get(): any[] {
      return l.own.slice()
    },

    on(callback: (layers: TemplateLayer[], info: { remote: boolean }) => void) {
      l.subs.push(callback)
      l.loaded.then(async () =>
        callback(
          window.LIA.classroom.connected && sync
            ? await sync.db.getTemplate(name)
            : localView(name),
          { remote: false },
        ),
      )
    },
  }
}

function changed(
  name: string,
  time: number,
  op: (db: any) => Promise<void>,
  now = false,
) {
  const l = LAYERS[name]

  // store at once, only a stroke (many pushes per second) at most every 300ms
  if (l.saving && !now) l.pending = true
  else save(name)

  if (window.LIA.classroom.connected) write(name, op, time)
  else l.loaded.then(() => emitLayers(name, localView(name)))
}

// `time`: an own change, the room is up to date with it once it is written
function write(name: string, op: (db: any) => Promise<void>, time = 0) {
  const l = LAYERS[name]
  l.ops++

  l.queue = l.queue
    .then(() => l.loaded)
    .then(async () => {
      if (window.LIA.classroom.connected && sync) {
        await op(sync.db)
        l.synced = Math.max(l.synced, time)
      }
    })
    .catch((e: any) =>
      log.warn('could not sync template ->', name, e?.message || e),
    )
    .finally(() => l.ops--)
}

// On a new connection: without own changes made offline the own layer just
// follows the room (the room may still be syncing, writing now would merge an
// old copy into it). With offline changes the newer copy wins.
function reconcile(name: string) {
  const l = LAYERS[name]

  write(name, async (db) => {
    if (l.time <= l.synced) {
      // ponytail: "no layer in the room yet" can also mean "not synced yet",
      // the same assumption quiz answers make on join
      if (!db.hasTemplate(name) && l.own.length > 0) {
        await db.writeTemplate(ownId(), name, l.own.slice(), l.time)
      }
      return
    }

    const newer = await db.reconcileTemplate(name, l.own.slice(), l.time)
    if (newer) {
      l.own = newer.values
      l.time = newer.time
      save(name)
      emitLayers(name, await db.getTemplate(name), { remote: true })
    }
    l.synced = l.time
  })
}

// While connected the room copy is the truth: Yjs merges what the owner and
// the peer itself change at the same time, the own layer follows it as soon
// as no own write is waiting anymore.
function roomChanged(name: string, layers: TemplateLayer[], ownTime: number) {
  const l = LAYERS[name]
  if (!l) return

  let remote = false
  const mine = layers.find((layer) => layer.me)

  if (l.ops === 0 && mine) {
    if (JSON.stringify(mine.values) !== JSON.stringify(l.own)) {
      l.own = mine.values.slice()
      l.time = Math.max(l.time, ownTime)
      remote = true
      save(name)
    }
    l.synced = l.time
  }

  emitLayers(name, layers, { remote })
}

// ponytail: rewrites the whole layer, switch to one row per value if layers
// get really large
function save(name: string) {
  const l = LAYERS[name]
  clearTimeout(l.saving)
  l.pending = false
  l.saving = setTimeout(() => {
    l.saving = undefined
    if (l.pending) save(name)
  }, 300)
  l.loaded
    .then(() =>
      Database?.storeTemplate(name, {
        values: l.own,
        time: l.time,
        synced: l.synced,
      }),
    )
    .catch((e: any) =>
      log.warn('could not store template ->', name, e?.message || e),
    )
}

// do not lose the last strokes when the page is closed while saving waits
window.addEventListener('pagehide', () => {
  for (const name in LAYERS) if (LAYERS[name].pending) save(name)
})

// the same id the classroom uses (see sync/Base), so a layer keeps its id
// and with it its color inside and outside of a classroom
function ownId(): string {
  try {
    return window.localStorage.getItem('lia-token') || ''
  } catch (e) {
    return ''
  }
}

function localView(name: string): TemplateLayer[] {
  return [
    {
      id: ownId(),
      name: '',
      me: true,
      editable: true,
      values: LAYERS[name].own.slice(),
    },
  ]
}

// `remote`: the own layer was changed by someone else (the owner)
function emitLayers(
  name: string,
  layers: TemplateLayer[],
  info = { remote: false },
) {
  LAYERS[name]?.subs.forEach((callback) => callback(layers, info))
}

function shared(kind: 'getArray' | 'getMap' | 'getText') {
  return (name: string) => {
    if (window.LIA.classroom.connected && sync) {
      return sync.db.doc[kind]('tpl:' + name)
    }

    console.warn('Classroom: not connected, no shared state for =>', name)
  }
}

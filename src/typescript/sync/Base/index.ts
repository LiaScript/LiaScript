import Lia from '../../liascript/types/lia.d'
import { GenericProvider } from 'y-generic'
import { DexieTransport } from './dexieTransport'
import * as helper from '../../helper'
import { CRDT } from './db'

import { encode, decode } from 'uint8-to-base64'
import { docId } from './persist'

export function uint8_to_base64(data: Uint8Array): string {
  return encode(data)
}
export function base64_to_unit8(data: string): Uint8Array {
  return decode(data)
}

export { docId }

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

export class Sync {
  public isConnected: boolean = false
  /** A course is defined by the URL, which shall be loaded by all users.
   */
  protected course?: string

  /** Since multiple users can load the same course, an arbitrary room id is
   * required to separate the communication.
   */
  protected room?: string

  /** Messages will be encrypted, if an password is defined.
   */
  protected password?: string

  /** Every user is identified by a unique, anonymous, and random string. This
   * token is stored within the local storage and allows to leave and reconnect
   * to classrooms without new identification
   */
  protected token: string
  protected name: string = ''
  protected mode: number = 0
  /** This is a simple semaphore, used to block any execution until all
   * required JavaScript libraries are loaded.
   */
  private urlCounter: number

  protected cbConnection: (topic: string, msg: string) => void
  protected cbRelay: (data: Lia.Event) => void
  protected onConnect?: () => void

  protected onReceive?: (topic: string, message: any) => void
  protected replyOnReceive: boolean = false

  public db: CRDT
  public provider?: GenericProvider
  protected persistProvider?: GenericProvider

  /** Resolves as soon as the local (IndexedDB) persistence is actually
   * writable, rejects if it could not be opened at all. It resolves
   * immediately, if no persistence was requested.
   *
   * Any update that is produced before this promise settles would be dropped
   * by the transport — and since yjs updates are deltas, a dropped update is
   * unrecoverable. Backends that can, should therefore delay their `connect`
   * notification until this promise resolves.
   */
  public persistReady: Promise<void> = Promise.resolve()

  /** To initialize the communication, two callbacks are required. While the
   * first is used to send configuration messages about successful join or
   * leaving, the second one is only used to relay messages from the network
   * into LiaScript.
   *
   * @param cbConnection - send messages directly to the sync module
   * @param cbRelay - simply relay messages to LiaScript
   * @param useInternalCallback - set this to false when custom y-js update-observers are used
   */
  constructor(
    cbConnection: (topic: string, msg: string) => void,
    cbRelay: (data: Lia.Event) => void,
    onConnect: () => void,
    onReceive: (topic: string, message: any) => void,
    replyOnReceive: boolean = false,
    useInternalCallback: boolean = true,
  ) {
    let token

    try {
      token = window.localStorage.getItem('lia-token')

      if (!token) {
        token = random()

        window.localStorage.setItem('lia-token', token)
      }
    } catch (e) {
      console.warn('cannot write to localStorage')

      token = random()
    }

    this.token = token
    this.urlCounter = 0
    this.cbConnection = cbConnection
    this.cbRelay = cbRelay
    this.onConnect = onConnect
    this.onReceive = onReceive
    this.replyOnReceive = replyOnReceive

    const self = this

    this.db = new CRDT(
      token,
      useInternalCallback
        ? (event, origin) => {
          if (self.db) {
            switch (origin) {
              case 'cursor': {
                this.sync('update', { cmd: 'cursor', param: event })
                break
              }
              case 'peer': {
                this.sync('update', { cmd: 'peer', param: event })
                break
              }
              case 'code': {
                this.sync('update', { cmd: 'code', param: event })
                break
              }
              case 'quiz': {
                this.sync('update', { cmd: 'quiz', param: event })
                break
              }
              case 'survey': {
                this.sync('update', { cmd: 'survey', param: event })
                break
              }
              case 'chat': {
                this.sync('update', { cmd: 'chat', param: event })
                break
              }
              case 'ownership': {
                this.sync('update', { cmd: 'ownership', param: event })
                break
              }
              default: {
                console.warn('Sync unknown origin', origin)
              }
            }
          }
        }
        : undefined,
    )
  }

  /* to have a valid connection 3 things are required:
  
  - a sender to connect to liascript
  - a matching course-url
  - a matching room-id

  the remaining 2 things are optional
  */

  /** This method shall be overwritten, and trigger the connection for the
   * given configuration after all required libraries have been loaded.
   *
   * > The config parameter is not stored here, it should be used to transport
   * > custom settings only required by the subSystem
   *
   * @param data
   */
  connect(data: {
    course: string
    uidDB?: string
    room: string
    password?: string
    persistent?: boolean
    fullBackend?: string
    name: string
    mode: number
    config?: any
  }) {
    this.room = data.room
    this.course = data.course
    this.password = data.password
    this.mode = data.mode

    this.name = data.name.trim()

    this.isConnected = true

    if (data.persistent) {
      const transport = new DexieTransport()
      this.persistProvider = new GenericProvider(this.db.doc, transport)
      this.persistReady = this.persistProvider.connect({
        // the local cache is identified by the local database-name, not by
        // the (possibly normalized) network identity of the course
        room: docId(
          data.uidDB || data.course,
          data.room,
          data.fullBackend || '',
        ),
        uidDB: data.uidDB || data.course,
      })

      // the promise itself is passed on to the subclasses, this only prevents
      // an unhandled rejection, if nobody else is listening
      this.persistReady.catch((e: any) => {
        console.warn('Sync: local persistence unavailable ->', e?.message || e)
      })
    } else {
      this.persistReady = Promise.resolve()
    }
  }

  destroy() {
    this.persistProvider?.disconnect()
    this.persistProvider = undefined
    this.db.destroy()
    this.cbConnection('disconnect', this.token)
    this.isConnected = false
  }

  disconnect() {
    this.db.removePeer()
    this.destroy()
  }

  /** Sometimes it might be required to generate a unique room ID for different
   * courses. This method can be used to generate an ID as a combination of
   * course URL and room name.
   *
   * @returns null if now room and course has been defined, otherwise a string
   */
  uniqueID(salt?: string): string | null {
    // used for literal room names, defined by the user
    let uid = null

    if (
      typeof this.room === 'string' &&
      ((this.room.startsWith('"') && this.room.endsWith('"')) ||
        (this.room.startsWith("'") && this.room.endsWith("'")))
    ) {
      uid = this.room
    }

    // otherwise a combination of course-url and room-name are used
    if (this.course && this.room) {
      uid = JSON.stringify({
        course: this.course,
        room: this.room,
        pw: helper.getHashCode(this.password || ''), // prevent delete from wrong passwords
        mode: this.mode
      })
    }

    if (salt && uid) {
      uid = helper.getHashCode(uid + salt).toString()
    }

    if (!uid) console.warn('Sync: no uniqueID')

    return uid
  }

  /** Not like in the common sense, this method provides and interface to the
   * LiaScript event system. Every received message should be send back by this
   * method.
   *
   * @param event
   */
  sendToLia(event: Lia.Event) {
    this.cbRelay(event)
  }

  sync(topic: string, message: any = null) {
    this.cbConnection(topic, message)
  }

  sendDisconnectError(msg: string) {
    this.sync('error', msg)
  }

  sendConnect() {
    this.sync('connect', this.token)

    if (this.onConnect) this.onConnect()

    // Wait for local persistence too (only `Local` normally awaits
    // persistReady before connecting) — otherwise a reconnecting peer can
    // push itself into an as-yet-unrestored metadata array before the
    // locally cached history (holding the real owner) has merged in, and
    // Yjs has to resolve the resulting concurrent inserts by per-doc client
    // ID rather than by who was actually first.
    Promise.all([
      new Promise((resolve) => setTimeout(resolve, 5000)),
      this.persistReady.catch(() => { }),
    ]).then(() => this.db.claimOwnership())
  }

  pubsubSend(topic: string, message: any) {
    const stringifiedObject = JSON.stringify({ topic, message })
    const encoder = new TextEncoder()
    //this.broadcast(false, encoder.encode(stringifiedObject))
    if (this.replyOnReceive) {
      this.onReceive?.(topic, message)
    }
  }

  pubsubReceive(data: Uint8Array) {
    try {
      const decoder = new TextDecoder()

      const decodedString = decoder.decode(data)
      const object = JSON.parse(decodedString)

      this.onReceive?.(object.topic, object.message)
    } catch (e) {
      console.warn('Sync: pubsubReceive', e.message)
    }
  }

  /** __At first, make sure that the resource has not been loaded before!__ And
   * then invoke this method to load all required resources. After this process
   * it will call the `init` method from the caller, which should be implemented
   * for every child of this class.
   *
   * The init is then called with two parameters:
   *
   * - `ok`: true or false, depending on the outcome
   * - `error`: an optional error string, that can be fed back to inform the
   *    user
   *
   * @param url - a list of URLs to be loaded
   * @param obj - called init after success of failure
   */
  load(url: string[], obj: { init: (ok: boolean, error?: string) => void }) {
    try {
      for (let i = 0; i < url.length; i++) {
        // create a new script-tag at the head of this document
        const tag = document.createElement('script')
        tag.async = false
        tag.defer = true
        tag.src = url[i]

        // increase semaphore
        this.urlCounter++

        let self = this
        tag.onload = function () {
          console.log('successfully loaded =>', url)

          self.urlCounter--

          // all sources have been loaded successfully
          if (self.urlCounter == 0) obj.init(true)
        }
        tag.onerror = function (e: any) {
          console.warn('could not load =>', url, e)

          // preventing the onload callback from sending
          // a positive result
          self.urlCounter = 0

          // TODO: provide a more detailed error message
          obj.init(false, `could not load => ${url}`)
        }

        // start loading the script
        document.head.appendChild(tag)
      }
    } catch (e: any) {
      console.error('load: ', e)
      obj.init(false, e.message)
    }
  }

  publish(event: Lia.Event) {
    switch (event.message.cmd) {
      case 'update': {
        break
      }
      case 'join': {
        this.db.init(event.message.param)
        break
      }

      case 'chat': {
        this.db.addChatMessage(event.message.param)
        break
      }

      case 'quiz': {
        if (event.track?.[0][0] === 'quiz' && event.track?.[1][0] === 'id') {
          this.db.addQuiz(
            event.track[0][1],
            event.track[1][1],
            event.message.param,
          )
        } else {
          console.warn('SyncTX wrong event ->', event)
        }

        break
      }

      case 'survey': {
        if (event.track?.[0][0] === 'survey' && event.track?.[1][0] === 'id') {
          this.db.addSurvey(
            event.track[0][1],
            event.track[1][1],
            event.message.param,
          )
        } else {
          console.warn('SyncTX wrong event ->', event)
        }

        break
      }

      case 'code': {
        if (event.track?.[0][0] === 'code' && event.track?.[1][0] === 'id') {
          this.db.updateCode(
            event.track[0][1],
            event.track[1][1],
            event.message.param.j,
            event.message.param.msg,
          )
        } else {
          console.warn('SyncTX wrong event ->', event)
        }
        break
      }

      case 'codes': {
        if (event.track?.[0][0] === 'code' && event.track.length === 1) {
          for (let i = 0; i < event.message.param.length; i++) {
            for (let j = 0; j < event.message.param[i].length; j++) {
              this.db.initCode(
                event.track[0][1],
                i,
                j,
                event.message.param[i][j],
              )
            }
          }
        } else {
          console.warn('SyncTX wrong event ->', event)
        }
        break
      }

      case 'cursor': {
        if (event.track?.[0][0] == 'code') {
          this.db.setCursor(event.track[0][1], event.message.param, this.name)
        }
        break
      }

      default: {
        console.warn('SyncTX unknown command:', event.message)
      }
    }
  }
}

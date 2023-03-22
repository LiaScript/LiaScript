import Lia from '../../liascript/types/lia.d'

import * as helper from '../../helper'
import { CRDT } from './db'

import { encode, decode } from 'uint8-to-base64'

export function uint8_to_base64(data: Uint8Array): string {
  return encode(data)
}
export function base64_to_unit8(data: string): Uint8Array {
  return decode(data)
}

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

function dynamicGossip(self: Sync) {
  let timerID: number | null = null

  function delay() {
    return (self.db.getPeers().length + 1) * 2000
  }

  function publish() {
    if (!self.isConnected) return
    try {
      self.broadcast(self.db.encode())

      timerID = window.setTimeout(publish, delay())
    } catch (e) {
      timerID = null
    }
  }

  return () => {
    if (timerID) {
      window.clearTimeout(timerID)
    }

    timerID = window.setTimeout(publish, delay())
  }
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

  /** This is a simple semaphore, used to block any execution until all
   * required JavaScript libraries are loaded.
   */
  private urlCounter: number

  protected cbConnection: (topic: string, msg: string) => void
  protected cbRelay: (data: Lia.Event) => void

  public db: CRDT
  public gossip: () => void

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
    useInternalCallback: boolean = true
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

    const self = this

    const gossip = dynamicGossip(self)
    this.gossip = gossip
    const throttleBroadcast = helper.throttle(() => {
      self.broadcast(self.db.encode())
      gossip()
    }, 1000)

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
                case 'exit': {
                  try {
                    origin = null

                    this.broadcast(event)
                    this.destroy()
                  } catch (e) {}
                  break
                }
                default: {
                  console.warn('Sync unknown origin', origin)
                }
              }

              if (origin) throttleBroadcast()
            }
          }
        : undefined
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
    room: string
    password?: string
    config?: any
  }) {
    this.room = data.room
    this.course = data.course
    this.password = data.password

    this.isConnected = true
  }

  destroy() {
    this.db.destroy()
    this.cbConnection('disconnect', this.token)
    this.isConnected = false
  }

  disconnect() {
    this.db.removePeer()
  }

  /** Sometimes it might be required to generate a unique room ID for different
   * courses. This method can be used to generate an ID as a combination of
   * course URL and room name.
   *
   * @returns null if now room and course has been defined, otherwise a string
   */
  uniqueID(): string | null {
    // used for literal room names, defined by the user
    if (
      typeof this.room === 'string' &&
      ((this.room.startsWith('"') && this.room.endsWith('"')) ||
        (this.room.startsWith("'") && this.room.endsWith("'")))
    ) {
      return this.room
    }

    // otherwise a combination of course-url and room-name are used
    if (this.course && this.room) {
      return JSON.stringify({
        course: this.course,
        room: this.room,
      })
    }

    console.warn('Sync: no uniqueID')
    return null
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
  }

  broadcast(data: Uint8Array) {
    console.warn('broadcast needs to be implemented')
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
        this.gossip()
        break
      }

      case 'quiz': {
        if (event.track?.[0][0] === 'quiz' && event.track?.[1][0] === 'id') {
          this.db.addQuiz(
            event.track[0][1],
            event.track[1][1],
            event.message.param
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
            event.message.param
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
            event.message.param.msg
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
                event.message.param[i][j]
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
          this.db.setCursor(event.track[0][1], event.message.param)
        }
        break
      }

      default: {
        console.warn('SyncTX unknown command:', event.message)
      }
    }
  }

  applyUpdate(data: Uint8Array) {
    this.db.applyUpdate(data)
  }
}

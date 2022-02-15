import Lia from '../../liascript/types/lia.d'

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

  /** To initialize the communication, two callbacks are required. While the
   * first is used to send configuration messages about successful join or
   * leaving, the second one is only used to relay messages from the network
   * into LiaScript.
   *
   * @param cbConnection - send messages directly to the sync module
   * @param cbRelay - simply relay messages to LiaScript
   */
  constructor(
    cbConnection: (topic: string, msg: string) => void,
    cbRelay: (data: Lia.Event) => void
  ) {
    let token = window.localStorage.getItem('lia-token')

    if (!token) {
      token = random()
      window.localStorage.setItem('lia-token', token)
    }

    this.token = token
    this.urlCounter = 0
    this.cbConnection = cbConnection
    this.cbRelay = cbRelay
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
  }

  disconnect(event: Lia.Event) {
    console.warn('implement disconnect')
  }

  /** Sometimes it might be required to generate a unique room ID for different
   * courses. This method can be used to generate an ID as a combination of
   * course URL and room name.
   *
   * @returns null if now room and course has been defined, otherwise a string
   */
  uniqueID(): string | null {
    if (this.course && this.room) {
      return JSON.stringify({
        course: this.course,
        room: this.room,
      })
    }

    console.warn('Sync: no uniqueID')
    return null
  }

  publish(event: any) {
    console.warn('overwrite this method')
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

  sendConnect() {
    this.sync('connect', this.token)
  }
  /** Send a connection message to the LiaScript Sync module, this after this
   * LiaScript will start joining, by sending a join message to be published.
   *
   */
  join() {
    this.cbConnection('connect', this.token)
  }

  leave() {
    //this.publish(this.syncMsg('leave', this.token))
    //this.sync('disconnect')
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
}

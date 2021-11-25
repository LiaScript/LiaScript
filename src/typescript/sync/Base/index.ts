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
  protected send: Lia.Send
  protected room?: string
  protected course?: string
  protected username?: string
  protected password?: string

  protected token: string

  private urlCounter: number

  constructor(send: Lia.Send) {
    this.send = send

    let token = window.localStorage.getItem('lia-token')

    if (!token) {
      token = random()
      window.localStorage.setItem('lia-token', token)
    }

    this.token = token
    this.urlCounter = 0
  }

  /* to have a valid connection 3 things are required:
  
  - a sender to connect to liascript
  - a matching course-url
  - a matching room-id

  the remaining 2 things are optional
  */
  connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {
    this.room = data.room
    this.course = data.course

    this.username = data.username
    this.password = data.password
  }

  disconnect() {}

  uniqueID() {
    if (this.course && this.room) {
      return JSON.stringify({
        course: this.course,
        room: this.room,
      })
    }

    console.warn('Sync: no uniqueID')
    return ''
  }

  publish(event: any) {}

  subscribe(topic: string) {}

  sync(topic: string, message: any = null) {
    this.send(this.syncMsg(topic, message))
  }

  syncMsg(topic: string, message: any = null) {
    return {
      route: [
        { topic: 'sync', id: null },
        { topic: 'sync', id: null },
        { topic: topic, id: null },
      ],
      message: message,
    }
  }

  load(url: string[], obj: { init: (ok: boolean, error?: string) => void }) {
    try {
      for (let i = 0; i < url.length; i++) {
        let tag = document.createElement('script')

        tag.async = false
        tag.defer = true
        tag.src = url[i]

        this.urlCounter++

        let self = this

        tag.onload = function () {
          console.log('successfully loaded =>', url)

          self.urlCounter--

          if (self.urlCounter == 0) obj.init(true)
        }
        tag.onerror = function (e) {
          console.warn('could not load =>', url, e)

          self.urlCounter--

          if (self.urlCounter == 0) {
            obj.init(false)
          }
        }

        document.head.appendChild(tag)
      }
    } catch (e) {
      console.error('load: ', e)
    }
  }
}

import Lia from '../../liascript/types/lia.d'

import { Sync as Base } from '../Base/index'

export class Sync extends Base {
  private client: any

  private host: string = "http://localhost:8008"
  private roomId : string = ""
  private roomAlias : string = "#liascript:testserver"
  private connected : boolean = false
  private roomName: string = ""

  private tries = 0

  private login?: {
    user_id: string
    device_id: string
    access_token: string
    home_server: string
  }

  constructor(send: Lia.Send) {
    super(send)
  }

  async connect(data: {
    course: string
    room: string
    username: string
    password?: string
  }) {
    super.connect(data)

    this.roomName = data.room

    if (window.matrixcs) {
      this.init(true)
    } else {
      this.load(['vendor/browser-matrix.min.js'], this)
    }
  }

  init(ok: boolean, error?: string) {
    if (ok && window.matrixcs) {
      const tempClient = window.matrixcs.createClient(this.host)

      let self = this
      
      tempClient.registerGuest({ username: this.token })
        .then((res: any) => {
          return this.client = window.matrixcs.createClient({
            baseUrl: this.host,
            accessToken: res.access_token,
            userId: res.user_id,
            deviceId: res.device_id,
          })
        }).then((res : any) => {
          this.client.setGuest(true)
          this.client.startClient()
        }).then((res : any) => {
          this.client.once('sync', (state: any, prevState: any, res: any) => {})
          this.client.on("Room.timeline", (event: any, room: any, toStartOfTimeline: any) => {
            const content = event.event.content
            if (!content || !content.msgtype) return

            if (content.msgtype.startsWith("lia.data") && content.msgtype.endsWith(this.roomName)) {
              const data = JSON.parse(content.body)
              self.send(data)
            }
          })
          
          // try to find liascript room
          this.client.joinRoom(this.roomAlias).then((room : any) => {
            if (room) {
              this.connected = true
              this.roomId = room.roomId
              this.sync('connect', this.token)
            }
          })
        })
        .catch((err : any) => {
            console.log("Matrix Error: ", err)
        })
    }
  }

  disconnect(): void {
    this.publish(this.syncMsg('leave', this.token))
    setTimeout(() => { this.client.leave(this.roomId) }, 1000)
    this.sync('disconnect')
  }

  publish(message: Object | null) {
    if (!window.matrixcs || !this.connected) return

    const content = {
      "body": JSON.stringify(message),
      "msgtype": `lia.data ${this.roomName}`
    }
  
    this.client.sendEvent(this.roomId, "m.room.message", content, "")
      .catch((err : any) => console.log(err))
  }
}

export class Sync {
  protected send?: Lia.Send
  protected room?: string
  protected course?: string
  protected username?: string
  protected password?: string

  constructor() {}

  /* to have a valid connection 3 things are required:
  
  - a sender to connect to liascript
  - a matching course-url
  - a matching room-id

  the remaining 2 things are optional
  */
  connect(
    send: Lia.Send,
    data: {
      course: string
      room: string
      username: string
      password?: string
    }
  ) {
    this.send = send
    this.room = data.room
    this.course = data.course

    this.username = data.username
    this.password = data.password
  }

  disconnect() {}

  isSupported(): boolean {
    return false
  }

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
}

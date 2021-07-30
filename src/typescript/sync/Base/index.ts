export class Sync {
  protected send?: Lia.Send
  protected room?: string
  protected course?: string

  constructor() {}

  /* to have a valid connection 3 things are required:
  
  - a sender to connect to liascript
  - a matching course-url
  - a matching room-id
  */
  connect(send: Lia.Send, course: string, room: string) {
    this.send = send
    this.room = room
    this.course = course
  }

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

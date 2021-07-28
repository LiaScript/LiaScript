export class Sync {
  protected send: Lia.Send

  constructor() {
    this.send = (_) => null
  }

  connect(send: Lia.Send | null) {
    if (send) this.send = send
  }

  slide(slide: number, effect: number) {}

  style(_: string) {}

  isSupported(): boolean {
    return false
  }
}

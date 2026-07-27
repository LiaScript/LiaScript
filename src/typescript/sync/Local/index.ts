import * as Base from '../Base/index'

/** A classroom backend with no network transport at all. Base.Sync already
 * wires up local IndexedDB persistence when `persistent` is set, so this
 * class only needs to report success immediately — there is no peer
 * handshake to wait for.
 */
export class Sync extends Base.Sync {
  connect(data: {
    course: string
    room: string
    password?: string
    persistent?: boolean
    config?: any
  }) {
    super.connect(data)
    this.sendConnect()
  }
}

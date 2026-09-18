import * as Base from '../Base/index'

/** A classroom backend with no network transport at all. Base.Sync already
 * wires up local IndexedDB persistence when `persistent` is set — there is no
 * peer handshake to wait for, but since IndexedDB is the only storage of this
 * backend, the connection is only reported as successful, after that storage
 * has really been opened. Otherwise every note, that is written before the
 * database is open, would be dropped silently.
 */
export class Sync extends Base.Sync {
  connect(data: {
    course: string
    room: string
    password?: string
    persistent?: boolean
    fullBackend?: string
    config?: any
  }) {
    super.connect(data)

    this.persistReady
      .then(() => {
        this.sendConnect()
      })
      .catch((e: any) => {
        this.sendDisconnectError(
          `local storage is not available: ${e?.message || e}`,
        )
      })
  }
}

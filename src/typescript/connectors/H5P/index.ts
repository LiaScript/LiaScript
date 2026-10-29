/**
 * LiaScript as H5P content: the H5P.LiaScript library (see the
 * LiaScript-Exporter) writes this runtime into an iframe of its own and hands
 * it a bridge as `window.h5pBridge`. The suspend engine does the bookkeeping,
 * against a virtual SCORM 2004 LMS that stores into H5P's user state and
 * reports results to the bridge, which turns them into xAPI events for the
 * platform.
 */

import { SuspendConnector } from '../SCORMSuspend/connector'
import * as Adapter from './adapter'

export class Connector extends SuspendConnector {
  constructor() {
    const bridge: Adapter.Bridge | undefined = (window as any).h5pBridge

    super(
      '2004',
      (warn) => {
        if (!bridge) {
          warn('not started by H5P.LiaScript, nothing will be stored')
          return null
        }
        return Adapter.connect(bridge, warn)
      },
      'H5P'
    )

    if (bridge) bridge.flush = () => this.engine.flush()
  }
}

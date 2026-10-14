import { SuspendConnector } from './connector'

/** SCORM 1.2, all state in cmi.suspend_data */
export class Connector extends SuspendConnector {
  constructor() {
    super('1.2')
  }
}

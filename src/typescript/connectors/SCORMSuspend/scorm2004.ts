import { SuspendConnector } from './connector'

/** SCORM 2004, all state in cmi.suspend_data */
export class Connector extends SuspendConnector {
  constructor() {
    super('2004')
  }
}

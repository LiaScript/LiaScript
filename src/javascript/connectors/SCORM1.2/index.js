import { Connector as Base } from '../Base/index'

const SCORM = require('simplify-scorm/src/scormAPI');

SCORM.scormAPIFunc()

class Connector extends Base {
  constructor() {
    super()
    this.scorm = window.top.API
    window.top.API = null

    console.log("LMSInitialize", this.scorm.LMSInitialize(""))
  }

  connect(send = null) {
    this.send = send
  }

  slide(id) {
    this.scorm.LMSSetValue("cmi.core.lesson_location", id.toString())
    this.scorm.LMSCommit("")
  }
}

export { Connector }

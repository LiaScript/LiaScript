import { Connector as Base } from '../Base/index'

const SCORM = require('simplify-scorm/src/scormAPI');

SCORM.scormAPIFunc()

class Connector extends Base {
  constructor() {
    super()
    this.scorm = window.API_1484_11
    //window.top.API = null

    if(!this.scorm) return

    console.log("LMSInitialize", this.scorm.LMSInitialize(""))

    // store state information only in normal mode
    let mode = this.scorm.LMSGetValue("cmi.core.lesson_mode")
    this.active = mode == "normal"

  //  this.scorm.LMSSetValue(
  //    "cmi.core.lesson_status",
  //    mode == "browse" ? "browsed" : "incomplete"
  //  )

  //  this.scorm.LMSCommit("")

  //  this.restore()
  }

}

export { Connector }

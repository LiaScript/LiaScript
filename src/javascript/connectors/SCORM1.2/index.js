import { Connector as Base } from '../Base/index'

const SCORM = require('simplify-scorm/src/scormAPI');

SCORM.scormAPIFunc()

class Connector extends Base {
  constructor() {
    super()
    this.scorm = window.top.API
    //window.top.API = null

    console.log("LMSInitialize", this.scorm.LMSInitialize(""))
  }

  connect(send = null) {
    this.send = send
  }

  slide(id) {
    this.scorm.LMSSetValue("cmi.core.lesson_location", id.toString())
    this.scorm.LMSCommit("")
  }

  open(uidDB, versionDB, slide){
    slide = parseInt(this.scorm.LMSGetValue("cmi.core.lesson_location"))

    if ( slide )
      this.send({topic: "goto", section: slide, message: null});
  }

  countObjectives() {
    return this.scorm.LMSGetValue("cmi.objectives._count")
  }

  countActivities() {
    return this.scorm.LMSGetValue("cmi.activities._count")
  }

  getObjective(id){
    let val = null

    try {
      val = this.scorm.LMSGetValue("cmi.objectives."+ id +".id")
      console.warn("WWWWWWWWWWWWWWWWW--------------------------------", val, id);

      let [type, sec, i, ...blob] = val.split ("/");

      let data = JSON.parse(decodeURI(blob.join("/")))

      if (type === "survey") {
        data = { submitted: true, state: data }
      }

      return {
        type: type,
        sec: parseInt(sec) - 1,
        i: parseInt(i),
        data: data
      }
    } catch (e) {
      console.warn("getObjective", val , id ,e);
      return null
    }
  }

  setObjective(id, obj) {
    let blob = [obj.type, obj.sec + 1, obj.i].join("/")

    if (obj.type == "survey") {
      // use only the state info to be stored in objectives.id
      blob = blob + "/" + encodeURI(JSON.stringify(obj.data.state))
    } else if(obj.type == "quiz") {
      blob = blob + "/" + encodeURI(JSON.stringify(obj.data))
    }
    
    this.scorm.LMSCommit("")
  }

  store(event) {
    if (event.topic === "code")
      return

    let items = []
    let count = this.countObjectives()

    // search all objectives for the given topics and sections
    for (let i=0; i<count; i++) {
      let item = this.getObjective(i)
      if (!!item) {
        if (item.sec == event.section && item.type == event.topic ) {
          // store only the position to be overwritten
          items.push(i)
        }
      }
    }

    let obj = {
      type: event.topic,
      sec: event.section,
      i: 0,
      data: null
    }

    for (let i=0; i<event.message.length; i++) {
      obj.i = i
      obj.data = event.message[i]

      // insert as new or overwrite existing ones
      this.setObjective(items.length == 0 ? this.countObjectives() : items[i], obj)
    }
  }


  load(event) {
    if (event.topic === "code") {
      event.message = {
        topic: 'restore',
        section: -1,
        message: null
      }
      this.send(event)
      return
    }

    let items = []
    let count = this.countObjectives()

    // search all objectives for the given topics and sections
    for (let i=0; i<count; i++) {
      let item = this.getObjective(i)
      if (!!item) {
        if (item.sec == event.section && item.type == event.topic ) {
          items.push(item)
        }
      }
    }

    if(items.length != 0) {
      event.message = {
        topic: 'restore',
        section: -1,
        message: items.sort((a,b) => a.i - b.i )
                      .map(e => e.data)
      }
      this.send(event)
    }
  }
}

export { Connector }

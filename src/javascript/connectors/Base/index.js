import { LiaStorage } from './storage'
import { SETTINGS, initSettings } from './settings'

class Connector {
  constructor () {
  }

  hasIndex() {
    return false
  }

  connect(send = null) {
    this.send = send
  }

  storage() {
    return new LiaStorage()
  }

  initSettings(data = null, local = false){
    initSettings(this.send, data, local)
  }

  setSettings(data) {
    localStorage.setItem(SETTINGS, JSON.stringify(data))
  }

  getSettings() {
    if (window.innerWidth <= 620) {
      let data

      try{
        data = JSON.parse(localStorage.getItem(SETTINGS))
        data.table_of_contents = false
        this.setSettings(data)
      } catch(e) {

      }

      return data;

    } else {
      return JSON.parse(localStorage.getItem(SETTINGS))
    }
  }

  open(uidDB, versionDB, slide, data = null) { }

  load(event) { }

  store(event) { }

  update(event, id) { }

  slide(id) { }

  getIndex() { }

  deleteFromIndex(msg) { }

  storeToIndex(json) { }

  restoreFromIndex(uidDB, versionDB = null) {}

  reset(uidDB, versionDB = null) {
    this.initSettings(null, true)
  }

  getFromIndex(uidDB) {
    this.send({
      topic: "restore",
      message: null,
      section: -1
    });
  }
}

export { Connector }

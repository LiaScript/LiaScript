import * as Y from 'yjs'
import * as State from './state'

const PEERS = 'peers'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'

window['Y'] = Y

function sanitize(data: object, whitelist: string[]) {
  return whitelist.reduce(
    (result, key) =>
      data[key] !== undefined
        ? Object.assign(result, { [key]: data[key] })
        : result,
    {}
  )
}
export class CRDT {
  protected doc: Y.Doc
  protected peers: Y.Map<any>
  protected length: number
  protected peerID: string

  constructor(
    peerID: string,
    callback: (event: any, origin: null | string) => void
  ) {
    this.doc = new Y.Doc()

    this.doc.on('update', callback)

    this.length = 0
    this.peerID = peerID

    this.peers = this.doc.getMap(PEERS)
    this.peers.set(peerID, true)
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    const self = this
    this.doc.transact(() => {
      for (let i = 0; i < data.length; i++) {
        self.initMap(QUIZ, i, data[i][QUIZ])
        self.initMap(SURVEY, i, data[i][SURVEY])
        self.initText(i, data[i][CODE])
      }
    }, this.peerID)
  }

  encode() {
    return Y.encodeStateAsUpdate(this.doc)
  }

  destroy() {
    this.doc.destroy()
  }

  applyUpdate(update: Uint8Array) {
    Y.applyUpdate(this.doc, update)
  }

  log() {
    console.warn('*********** PEERS ***********')
    console.warn(this.peers.toJSON())
    console.warn('*********** STATE ***********')
    console.warn(this.doc.toJSON())
    /*console.warn('*********** DATA ************')
    console.warn(this.doc)
    */
  }

  protected initMap(key: string, id: number, data: State.Data[]) {
    if (data.length === 0) return

    let state
    for (let i = 0; i < data.length; i++) {
      state = this.getMap(key, id, i)

      for (const identifier in data[i]) {
        state.set(identifier, data[i][key])
      }
    }
  }

  protected initText(id: number, data: State.Data[]) {
    if (data.length === 0) return

    for (let i = 0; i < data.length; i++) {
      for (let j = 0; j < data[i].length; j++) {
        this.initCode(id, i, j, data[i][j])
      }
    }
  }

  diff(state: Uint8Array) {
    return Y.encodeStateAsUpdate(this.doc, state)
  }

  toJSON(): State.Vector {
    let vector: State.Vector = []

    for (let i = 0; i < this.length; i++) {
      vector.push({
        s: this.getAllMaps(SURVEY, i),
        q: this.getAllMaps(QUIZ, i),
        c: this.getAllTexts(i),
      })
    }

    return vector
  }

  getPeers() {
    const peers = this.peers.toJSON()

    if (peers) {
      return Object.entries(peers)
        .filter(([_, value]) => value)
        .map(([key, _]) => key)
    }

    return []
  }

  removePeer() {
    this.doc.transact(() => {
      this.peers.set(this.peerID, false)
    }, 'exit')
  }

  id(key: string, id1: number, id2: number, id3?: number) {
    if (id3 === undefined) {
      return key + ':' + id1 + ',' + id2
    }

    return key + ':' + id1 + ',' + id2 + ',' + id3
  }

  has(key: string, id: number, i: number, j?: number) {
    return this.doc.share.has(this.id(key, id, i, j))
  }

  getMap(key: string, id: number, i: number): Y.Map<any> {
    return this.doc.getMap(this.id(key, id, i))
  }

  getText(key: string, id: number, i: number, j: number): Y.Text {
    return this.doc.getText(this.id(key, id, i, j))
  }

  getAllMaps(key: string, id: number): any[] {
    let vector: any[] = []
    let obj: any

    for (let i = 0; this.has(key, id, i); i++) {
      obj = this.getMap(key, id, i)
      vector.push(obj.toJSON())
    }

    return vector
  }

  getAllTexts(id: number): string[][] {
    let vector: string[][] = []
    let obj: undefined | Y.Text

    for (let i = 0; this.has(CODE, id, i, 0); i++) {
      let subVector: string[] = []

      for (let j = 0; this.has(CODE, id, i, j); j++) {
        obj = this.getText(CODE, id, i, j)

        subVector.push(obj.toString())
      }

      vector.push(subVector)
    }

    return vector
  }

  addQuiz(id: number, i: number, value: any) {
    this.addRecord(QUIZ, id, i, value)
  }

  addSurvey(id: number, i: number, value: any) {
    this.addRecord(SURVEY, id, i, value)
  }

  addRecord(key: string, id: number, i: number, value: any) {
    let record = this.getMap(key, id, i)

    if (record.toJSON()[this.peerID] === undefined)
      record.set(this.peerID, value)
  }

  initCode(id: number, i: number, j: number, value: string) {
    if (!this.has(CODE, id, i, j)) {
      const code = this.getText(CODE, id, i, j)
      const backup = this.doc.clientID
      this.doc.clientID = 0
      code.insert(0, value)
      this.doc.clientID = backup
    }
  }

  updateCode(
    id: number,
    i: number,
    j: number,
    msg: {
      action: 'insert' | 'remove'
      index: number
      content: string
    }
  ) {
    if (this.has(CODE, id, i, j)) {
      const code = this.getText(CODE, id, i, j)

      switch (msg.action) {
        case 'insert': {
          code.insert(msg.index, msg.content)
          break
        }
        case 'remove': {
          code.delete(msg.index, msg.content.length)
          break
        }
        default: {
          console.warn('Sync code, unknown action ->', msg)
        }
      }
    }
  }
}

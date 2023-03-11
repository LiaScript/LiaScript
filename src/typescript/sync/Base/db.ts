import * as Y from 'yjs'
import * as State from './state'
import * as helper from '../../helper'

const PEERS = 'peers'
const CURSORS = 'cursors'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'

export class CRDT {
  public doc: Y.Doc
  protected peers: Y.Map<boolean>
  protected cursors: Y.Map<State.Cursor>
  protected length: number
  protected peerID: string
  protected color?: string

  constructor(
    peerID: string,
    callback?: (event: any, origin: null | string) => void
  ) {
    this.doc = new Y.Doc()

    if (callback) {
      this.doc.on('update', callback)
    }

    this.length = 0
    this.peerID = peerID

    this.peers = this.doc.getMap(PEERS)
    this.cursors = this.doc.getMap(CURSORS)

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
    this.doc.transact(() => {
      // this is required to update the online settings, if the user has been offline
      // or if the system had determined that he is offline
      if (this.peers.get(this.peerID) === false) {
        this.peers.set(this.peerID, true)
      }
      Y.applyUpdate(this.doc, update)
    })
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

  getCursors(keys: string[]) {
    const cursors: State.Cursor[] = []
    const json = this.cursors.toJSON()

    for (let key of keys) {
      if (key === this.peerID || json[key] === undefined) continue

      cursors.push(json[key])
    }

    return cursors
  }

  getPeers(): string[] {
    const peers = this.peers.toJSON()

    if (peers) {
      return Object.entries(peers)
        .filter(([_, value]) => value)
        .map(([key, _]) => key)
    }

    return []
  }

  removePeer(peerID?: string) {
    this.doc.transact(
      () => {
        this.peers.set(peerID || this.peerID, false)
      },
      peerID ? undefined : 'exit'
    )
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
    messages: Array<{
      action: 'insert' | 'remove'
      index: number
      content: string
    }>
  ) {
    if (this.has(CODE, id, i, j)) {
      this.doc.transact(() => {
        const code = this.getText(CODE, id, i, j)

        for (let msg of messages) {
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
      }, 'code')
    }
  }

  getColor(): string {
    if (!this.color) {
      this.color = helper.getColorFor(this.peerID)
    }
    return this.color
  }

  setCursor(
    section: number,
    cursor: {
      project: number
      file: number
      state: {
        position: { row: number; column: number }
        selection: [] | [number, number, number, number]
      }
    }
  ) {
    this.doc.transact(() => {
      this.cursors.set(this.peerID, {
        id: this.peerID,
        section: section,
        project: cursor.project,
        file: cursor.file,
        state: cursor.state,
        color: this.getColor(),
      })
    }, 'cursor')
  }

  removeCursor() {
    this.cursors.delete(this.peerID)
  }
}

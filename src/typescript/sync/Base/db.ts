import * as Y from 'yjs'
import * as State from './state'
import * as helper from '../../helper'

const PEERS = 'peers'
const CURSORS = 'cursors'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'

export class CRDT {
  protected callback: (event: any, origin: null | string) => void
  public doc: Y.Doc

  protected peers: Y.Map<boolean>
  protected cursors: Y.Map<State.Cursor>
  protected codes: Y.Map<Y.Text>
  protected quizzes: Y.Map<State.Data>
  protected surveys: Y.Map<State.Data>

  protected length: number
  protected peerID: string
  protected color?: string

  constructor(
    peerID: string,
    callback?: (event: any, origin: null | string) => void
  ) {
    this.doc = new Y.Doc()
    this.callback =
      callback ||
      ((e, origin) => {
        console.warn('SyncDB: no callback provided')
      })

    this.length = 0
    this.peerID = peerID

    this.peers = this.doc.getMap(PEERS)
    this.cursors = this.doc.getMap(CURSORS)
    this.codes = this.doc.getMap(CODE)
    this.quizzes = this.doc.getMap(QUIZ)
    this.surveys = this.doc.getMap(SURVEY)

    if (callback) {
      this.peers.observe((event: Y.YMapEvent<boolean>) => {
        const peers = this.getPeers()
        callback(peers, 'peer')
      })

      this.cursors.observe((event: Y.YMapEvent<State.Cursor>) => {
        const peers = this.getPeers()
        callback(this.getCursors(peers), 'cursor')
      })

      this.quizzes.observeDeep((event: Y.YEvent<any>[]) => {
        callback(this.getQuiz(), 'quiz')
      })

      this.surveys.observeDeep((event: Y.YEvent<any>[]) => {
        callback(this.getSurvey(), 'survey')
      })

      this.codes.observeDeep((events: Y.YEvent<Y.Text>[]) => {
        callback(this.getCode(), 'code')
      })
    }

    this.peers.set(peerID, true)
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    const self = this

    this.doc.transact(() => {
      for (let i = 0; i < data.length; i++) {
        self.initMap(this.quizzes, i, data[i][QUIZ])
        self.initMap(this.surveys, i, data[i][SURVEY])
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

  protected initMap(map: Y.Map<State.Data>, id: number, data: State.Data[]) {
    if (data.length === 0) return

    let state
    const backup = this.doc.clientID

    for (let i = 0; i < data.length; i++) {
      state = map.get(this.id(id, i))

      if (!state) {
        this.doc.clientID = 0
        state = new Y.Map()
        map.set(this.id(id, i), state)
        this.doc.clientID = backup
      }

      for (const key in data[i]) {
        state.set(key, data[i][key])
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
        s: [], //this.getAllMaps(SURVEY, i),
        q: [], //this.getAllMaps(QUIZ, i),
        c: this.getAllTexts(i),
      })
    }

    return vector
  }

  getCode(): string[][][] {
    let vector: string[][][] = []
    for (let i = 0; i < this.length; i++) {
      vector.push(this.getAllTexts(i))
    }
    return vector
  }

  getQuiz(): State.Data[][][] {
    let vector: State.Data[][][] = []
    for (let i = 0; i < this.length; i++) {
      vector.push(this.getAllMaps(this.quizzes, i))
    }
    return vector
  }

  getSurvey(): State.Data[][][] {
    let vector: State.Data[][][] = []
    for (let i = 0; i < this.length; i++) {
      vector.push(this.getAllMaps(this.surveys, i))
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
    this.doc.transact(() => {
      this.peers.set(peerID || this.peerID, false)
    })

    if (peerID === undefined) {
      this.callback(this.encode(), 'exit')
    }
  }

  id(id1: number, id2: number, id3?: number) {
    if (id3 === undefined) {
      return id1 + ':' + id2
    }

    return id1 + ':' + id2 + ',' + id3
  }

  getMap(key: string, id: number, i: number): Y.Map<any> {
    return this.doc.getMap(this.id(id, i))
  }

  getAllMaps(map: Y.Map<State.Data>, id: number): any[] {
    let vector: any[] = []
    let obj: any

    for (let i = 0; map.has(this.id(id, i)); i++) {
      obj = map.get(this.id(id, i))
      vector.push(obj.toJSON())
    }

    return vector
  }

  getAllTexts(id: number): string[][] {
    let vector: string[][] = []
    let obj: undefined | Y.Text

    for (let i = 0; this.codes.has(this.id(id, i, 0)); i++) {
      let subVector: string[] = []

      for (let j = 0; this.codes.has(this.id(id, i, j)); j++) {
        obj = this.codes.get(this.id(id, i, j))

        subVector.push(obj?.toString() || '')
      }

      vector.push(subVector)
    }

    return vector
  }

  addQuiz(id: number, i: number, value: any) {
    this.addRecord(this.quizzes, id, i, value)
  }

  addSurvey(id: number, i: number, value: any) {
    this.addRecord(this.surveys, id, i, value)
  }

  addRecord(map: Y.Map<State.Data>, id: number, i: number, value: any) {
    let record = map.get(this.id(id, i))

    if (!record) {
      const backup = this.doc.clientID
      this.doc.clientID = 0
      record = new Y.Map()
      map.set(this.id(id, i), record)
      this.doc.clientID = backup
    }

    if (!record.has(this.peerID)) {
      record.set(this.peerID, value)
    }
  }

  initCode(id: number, i: number, j: number, value: string) {
    if (!this.codes.has(this.id(id, i, j))) {
      const backup = this.doc.clientID

      this.doc.clientID = 0

      const code = new Y.Text()
      code.insert(0, value)
      this.codes.set(this.id(id, i, j), code)

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
    if (this.codes.has(this.id(id, i, j))) {
      this.doc.transact(() => {
        const code = this.codes.get(this.id(id, i, j))

        if (code === undefined) return

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

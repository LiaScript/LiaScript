import * as Y from 'yjs'
import * as State from './state'
import * as helper from '../../helper'

import { YKeyValue } from 'y-utility/y-keyvalue'

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
  protected quizzes: YKeyValue<State.Data>
  protected surveys: YKeyValue<State.Data>
  protected chat: YKeyValue<{ message: String; color: String; user: String }>

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

    this.quizzes = new YKeyValue(this.doc.getArray(QUIZ))
    this.surveys = new YKeyValue(this.doc.getArray(SURVEY))
    this.chat = new YKeyValue(this.doc.getArray('chat'))

    if (callback) {
      this.peers.observe((event: Y.YMapEvent<boolean>) => {
        const peers = this.getPeers()
        callback(peers, 'peer')
      })

      this.cursors.observe((event: Y.YMapEvent<State.Cursor>) => {
        const peers = this.getPeers()
        callback(this.getCursors(peers), 'cursor')
      })

      this.quizzes.on('change', (changes) => {
        const updates = this.getUpdates(this.quizzes, changes)

        if (updates) {
          callback(updates, 'quiz')
        }
      })

      this.surveys.on('change', (changes) => {
        const updates = this.getUpdates(this.surveys, changes)

        if (updates) {
          callback(updates, 'survey')
        }
      })

      this.chat.on('change', (changes) => {
        const vector = []

        let obj
        for (let [id, op] of changes) {
          if (op.action === 'add') {
            obj = op.newValue
            obj['id'] = parseInt(id)
            vector.push(obj)
          }
        }

        if (vector.length > 0) callback(vector, 'chat')
      })

      this.codes.observeDeep((events: Y.YEvent<Y.Text>[]) => {
        const ids: Set<number> = new Set()

        for (const event of events) {
          const keys = event.currentTarget.keys()

          for (const key of keys) {
            try {
              const [id] = JSON.parse(key)
              ids.add(id)
            } catch (e) {}
          }
        }

        if (ids.size > 0) {
          callback(this.getCode(ids), 'code')
        }
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

  protected initMap(
    map: YKeyValue<State.Data>,
    id: number,
    data: State.Data[]
  ) {
    if (data.length === 0) return

    let state

    for (let i = 0; i < data.length; i++) {
      state = map.get(this.id(id, i))

      if (!state) {
        state = {}
      }

      for (const key in data[i]) {
        state[key] = data[i][key]
      }

      map.set(this.id(id, i), state)
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

  getCode(ids: Set<number>): { id: number; data: string[][] }[] {
    let vector: { id: number; data: string[][] }[] = []

    for (const id of ids) {
      vector.push({ id: id, data: this.getAllTexts(id) })
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
      return JSON.stringify([id1, id2])
    }

    return JSON.stringify([id1, id2, id3])
  }

  getMap(key: string, id: number, i: number): Y.Map<any> {
    return this.doc.getMap(this.id(id, i))
  }

  getAllMaps(map: YKeyValue<State.Data>): State.Data[][][] {
    const vector: State.Data[][][] = []

    for (let i = 0; i < this.length; i++) {
      let sub = []
      for (let j = 0; map.has(this.id(i, j)); j++) {
        // @ts-ignore
        sub.push(map.get(this.id(i, j)))
      }
      vector.push(sub)
    }

    return vector
  }

  getMaps(id: number, map: YKeyValue<State.Data>): State.Data[][] {
    const vector: State.Data[][] = []

    for (let i = 0; map.has(this.id(id, i)); i++) {
      // @ts-ignore

      vector.push(map.get(this.id(id, i)))
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

  addRecord(map: YKeyValue<State.Data>, id: number, i: number, value: any) {
    let record = map.get(this.id(id, i))

    if (!record) {
      record = {}
    }

    //if (record[this.peerID] == undefined) {
    record[this.peerID] = value
    //}

    map.set(this.id(id, i), record)
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

  addChatMessage(msg: string) {
    this.chat.set('' + Date.now(), {
      color: this.getColor(),
      message: msg,
      user: this.peerID,
    })
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

  getUpdates(maps, changes): { id: number; data: State.Data[][] }[] | null {
    const ids: Set<number> = new Set()
    const updates: [string, any][] = []

    for (const [id, data] of changes) {
      switch (data.action) {
        case 'update': {
          if (
            JSON.stringify(Object.keys(data.oldValue).sort()) !==
            JSON.stringify(Object.keys(data.newValue).sort())
          ) {
            updates.push([id, { ...data.oldValue, ...data.newValue }])
            continue
          }
        }
        case 'add': {
          try {
            const [key] = JSON.parse(id)
            ids.add(key)
          } catch (e) {}
        }
      }
    }

    const vector: { id: number; data: State.Data[][] }[] = []
    for (const id of ids) {
      vector.push({ id: id, data: this.getMaps(id, maps) })
    }

    for (const [id, value] of updates) {
      maps.set(id, value)
    }

    if (vector.length > 0) {
      return vector
    }

    return null
  }
}

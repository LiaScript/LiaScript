import * as Y from 'yjs'

import * as State from './state'

function encode(data: Uint8Array) {
  return Array.from(data)
}

function decode(data: number[]) {
  return Uint8Array.from(data)
}

const PEERS = 'peers'
const QUIZ = 'q'
const SURVEY = 's'
const DB = 'DB'

export class CRDT {
  protected doc: Y.Doc
  protected db: Y.Map<any>
  protected length: number

  constructor(peerID: string) {
    this.doc = new Y.Doc()
    this.db = this.doc.getMap(DB)
    this.length = 0

    const peers = new Y.Map()
    peers.set(peerID, true)
    this.db.set(PEERS, peers)
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    for (let i = 0; i < data.length; i++) {
      this.initMap(QUIZ, i, data[i][QUIZ])
      this.initMap(SURVEY, i, data[i][SURVEY])
    }
  }

  encode() {
    return encode(Y.encodeStateAsUpdate(this.doc))
  }

  destroy() {
    console.warn('TODO: destroy')
  }

  apply(update: number[]) {
    Y.applyUpdate(this.doc, decode(update))
  }

  protected initMap(key: string, id: number, data: State.Data[]) {
    for (let i = 0; i < data.length; i++) {
      const newID = this.id(key, id, i)
      const state = this.db.has(newID) ? this.db.get(newID) : new Y.Map()

      for (const key in data[i]) {
        state.set(key, data[i][key])
      }
      this.db.set(newID, state)
    }
  }

  toJSON(): State.Vector {
    let data = this.db.toJSON()
    let vector = []

    for (let i = 0; i < this.length; i++) {
      vector.push({
        SURVEY: this.getAllObjects(SURVEY, i),
        QUIZ: this.getAllObjects(QUIZ, i),
      })
    }

    return vector
  }

  getPeers() {
    const peers = this.db.get(PEERS).toJSON()

    if (peers) {
      return Object.entries(peers)
        .filter(([_, value]) => value)
        .map(([key, _]) => key)
    }

    return []
  }

  removePeer(peerID: string) {
    const peers = this.db.get(PEERS)
    peers.set(peerID, false)
    this.db.set(PEERS, peers)
  }

  id(key: string, id1: number, id2: number) {
    return key + ':' + id1 + ',' + id2
  }

  has(key: string, id: number, i: number) {
    return this.db.has(this.id(key, id, i))
  }

  get(key: string, id: number, i: number) {
    return this.db.get(this.id(key, id, i))
  }

  getAllObjects(key: string, id: number) {
    let vector = []

    for (let i = 0; this.has(key, id, i); i++) {
      const obj = this.get(key, id, i)

      vector.push(obj.toJSON())
    }

    return vector
  }
}

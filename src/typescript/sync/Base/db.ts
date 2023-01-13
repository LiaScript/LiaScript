import * as Y from 'yjs'

import * as State from './state'

import { encode, decode } from 'uint8-to-base64'

const PEERS = 'peers'
const DB = 'DB'

export const QUIZ = 'q'
export const SURVEY = 's'

export class CRDT {
  protected doc: Y.Doc
  protected db: Y.Map<any>
  protected peers: Y.Map<any>
  protected length: number
  protected peerID: string

  constructor(peerID: string, callback: (event: any) => void) {
    this.doc = new Y.Doc()

    this.doc.on('afterTransaction', callback)

    this.db = this.doc.getMap(DB)
    this.length = 0

    this.peers = this.doc.getMap(PEERS)
    this.peers.set(peerID, true)
    //this.db.set(PEERS, peers)

    this.peerID = peerID
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

  apply(update: string) {
    Y.applyUpdate(this.doc, decode(update))
  }

  protected initMap(key: string, id: number, data: State.Data[]) {
    let newID
    let state

    for (let i = 0; i < data.length; i++) {
      newID = this.id(key, id, i)
      state = this.db.has(newID) ? this.db.get(newID) : new Y.Map()

      for (const key in data[i]) {
        state.set(key, data[i][key])
      }
      this.db.set(newID, state)
    }
  }

  toJSON(): State.Vector {
    let vector: State.Vector = []

    for (let i = 0; i < this.length; i++) {
      vector.push({
        s: this.getAllObjects(SURVEY, i),
        q: this.getAllObjects(QUIZ, i),
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

  set(key: string, id: number, i: number, value: any) {
    try {
      this.db.set(this.id(key, id, i), value)
    } catch (e) {
      console.warn('sync db set:', e)
    }
  }

  getAllObjects(key: string, id: number): any {
    let vector: any[] = []
    let obj: any

    for (let i = 0; this.has(key, id, i); i++) {
      obj = this.get(key, id, i)

      vector.push(obj.toJSON())
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
    let record = this.get(key, id, i)

    if (record) {
      record.set(this.peerID, value)
    } else {
      record = new Y.Map()
      record.set(this.peerID, value)
      this.set(key, id, i, record)
    }
  }
}
